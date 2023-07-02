import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyListComponent extends StatelessWidget {

  final String text;
  final IconData icon;

  const EmptyListComponent({Key? key, this.text = "data kosong!", this.icon = CupertinoIcons.cube_box}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey,),
          Text(text,
            style: const TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
