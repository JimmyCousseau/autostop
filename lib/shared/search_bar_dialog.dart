import 'package:autostop/shared/parameter_dialog.dart';
import 'package:flutter/material.dart';

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
                  return [];
                }
                return _osmService.searchCities(textEditingValue.text);
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
            // Throws an error
            City city = (await _osmService.searchCities(selectedCity)).first;
            widget.onSelected(city);
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
              return ListTile(
                title: Text(city.name),
                subtitle: Text(city.moreInfo),
                onTap: () {
                  onSelected(city);
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
}
