import 'package:flutter/material.dart';

import 'components/empty_list_component.dart';

class FilterScreen extends StatefulWidget {

  static const routeName = "/filter-screen";

  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  final _searchController = TextEditingController();

  bool _isInit = true;
  late List _data;
  List _filteredData = [];
  late String _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      _data = args['data'];
      _filteredData = _data;
      _name = args['name'];
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            suffixIcon: _searchController.text.isEmpty ? const Icon(Icons.search, color: Colors.white,) : GestureDetector(
              onTap: () {
                _searchController.clear();
                _filteredData = _data;
                setState(() {});
              },
              child: const Icon(Icons.clear, color: Colors.white,),
            ),
            border: InputBorder.none,
            hintText: "search...",
            hintStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: 1,
          onChanged: (val) {
            _filteredData = _data.where((el) => el[_name].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
            setState(() {});
          },
        ),
      ),
      body: SafeArea(
        child: _filteredData.isEmpty ? EmptyListComponent() : ListView.separated(
          itemCount: _filteredData.length,
          separatorBuilder: (_, __) {
            return Container(
              color: Colors.grey,
              width: double.infinity,
              height: 0.5,
            );
          },
          itemBuilder: (ctx, pos) {
            return ListTile(
              onTap: () {
                Navigator.of(context).pop(_filteredData[pos]);
              },
              title: Text(_filteredData[pos][_name]),
            );
          },
        ),
      ),
    );
  }
}
