import 'package:flutter/material.dart';

import '../services/osm_service.dart';
import 'map_search_bar.dart';

class SearchCityFormField extends StatefulWidget {
  final Function(City?) onChanged;

  const SearchCityFormField({super.key, required this.onChanged});

  @override
  State<SearchCityFormField> createState() => _SearchCityFormFieldState();
}

class _SearchCityFormFieldState extends State<SearchCityFormField> {
  City? _city;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Destination", style: Theme.of(context).textTheme.titleLarge),
        if (_city == null)
          MapSearchBar(
            onSelected: widget.onChanged,
            showParameterIcon: false,
          ),
        if (_city != null)
          Row(children: [
            Text(_city!.name),
            IconButton(
              onPressed: () => widget.onChanged(null),
              icon: const Icon(Icons.delete),
            )
          ]),
      ],
    );
  }
}
