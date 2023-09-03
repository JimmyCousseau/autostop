import 'dart:convert';

import 'package:autostop/shared/parameter_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/osm_service.dart';

class SearchBarDialog extends StatefulWidget {
  const SearchBarDialog(
      {super.key,
      required this.onSelected,
      this.rounded = 20.0,
      this.showParameterIcon = true});

  final Function(City) onSelected;
  final double rounded;
  final bool showParameterIcon;

  @override
  State<SearchBarDialog> createState() => _SearchBarDialogState();
}

class _SearchBarDialogState extends State<SearchBarDialog> {
  final OsmService _osmService = OsmService();
  final double _padding = 8.0;
  final int _limitSearchedCities = 3;
  final int _limitCitiesShowed = 5;

  late final SharedPreferences _preferences;
  List<City> _previousSearchedCities = [];

  @override
  void initState() {
    super.initState();
    _loadRememberedSearchs();
  }

  void _loadRememberedSearchs() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      final List<String> cityListData =
          _preferences.getStringList('cityList') ?? [];
      _previousSearchedCities = cityListData.map((cityData) {
        final Map<String, dynamic> cityMap = jsonDecode(cityData);
        return City(cityMap['pos'], cityMap['name'], cityMap['moreInfo']);
      }).toList();
    });
  }

  void _saveRememberedSearchs(City newSearch) {
    if (_previousSearchedCities.contains(newSearch)) {
      return;
    }
    setState(() {
      if (_previousSearchedCities.length < _limitSearchedCities) {
        _previousSearchedCities.add(newSearch);
      } else if (_previousSearchedCities.length == _limitSearchedCities) {
        _previousSearchedCities[_limitSearchedCities] = newSearch;
      } else {
        return;
      }
      _preferences.setStringList('cityList',
          _previousSearchedCities.map((e) => jsonEncode(e)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildAutoComplete(context);
  }

  Widget _buildAutoComplete(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(_padding, 20.0, _padding, _padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<City>(
              displayStringForOption: (option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _previousSearchedCities;
                }
                final sanitizedInput = _sanitizeText(textEditingValue.text);
                return _osmService.searchCities(sanitizedInput,
                    limit: _limitCitiesShowed);
              },
              onSelected: widget.onSelected,
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<City> onSelected,
                  Iterable<City> options) {
                return _buildAutoCompleteOptions(
                  context,
                  options,
                  onSelected,
                );
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return _buildAutoCompleteFormField(
                    context, textEditingController, focusNode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoCompleteFormField(BuildContext context,
      TextEditingController textEditingController, FocusNode focusNode) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.rounded),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: TextField(
          style: const TextStyle(fontSize: 18),
          controller: textEditingController,
          focusNode: focusNode,
          onSubmitted: (selectedCity) async {
            try {
              City city = (await _osmService.searchCities(selectedCity,
                      limit: _limitCitiesShowed))
                  .first;
              widget.onSelected(city);
              _saveRememberedSearchs(city);
            } on StateError catch (_) {
              // Search gave an empty response
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          },
          onTapOutside: (pointer) {
            focusNode.unfocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _getSuffixIcon(textEditingController),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoCompleteOptions(BuildContext context, Iterable<City> options,
      AutocompleteOnSelected<City> onSelected) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - _padding * 2,
        ),
        child: Card(
          child: ListView.builder(
            itemCount: options.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              City city = options.elementAt(index);
              List<Widget> iconText = _previousSearchedCities.contains(city)
                  ? [
                      const Icon(Icons.watch_later_outlined),
                      const SizedBox(width: 8)
                    ]
                  : [];
              iconText.add(Text(city.name));
              return ListTile(
                title: Row(
                  children: iconText,
                ),
                subtitle: Text(city.moreInfo),
                onTap: () {
                  onSelected(city);
                  _saveRememberedSearchs(city);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getSuffixIcon(TextEditingController textEditingController) {
    if (textEditingController.text.isNotEmpty) {
      return IconButton(
        onPressed: () {
          setState(() {
            textEditingController.clear();
          });
        },
        icon: const Icon(Icons.clear),
      );
    } else if (widget.showParameterIcon) {
      return IconButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => ParameterDialog());
        },
        icon: const Icon(Icons.menu),
      );
    }
    return const Text("");
  }

  String _sanitizeText(String input) {
    final sanitizedInput = input.trim();

    // Validate the length of the input
    if (sanitizedInput.length > 50) {
      showDialog(
        context: context,
        builder: (_) => const Text("La recherche est trop longue"),
      );
    }
    // Define a map of characters and their corresponding HTML entities
    final htmlEntities = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;',
      '/': '&#x2F;',
    };

    // Replace characters with their HTML entities
    return sanitizedInput.replaceAllMapped(RegExp('[&<>"\'/]'), (match) {
      return htmlEntities[match.group(0)]!;
    });
  }
}
