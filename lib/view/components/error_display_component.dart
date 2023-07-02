import 'package:flutter/material.dart';

class ErrorDisplayComponent extends StatelessWidget {

  final VoidCallback onPressed;
  final bool isOnlyButton;
  final String? errorMsg;

  const ErrorDisplayComponent({Key? key, this.errorMsg, required this.onPressed, this.isOnlyButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? errorMessage;
    if (errorMsg != null) {
      errorMessage = errorMsg!.length > 150 ? errorMsg!.substring(0, 150) : errorMsg!;
    }
    return Center(
      child: isOnlyButton ? TextButton.icon(
        icon: const Icon(Icons.refresh,
          color: Colors.yellow,
        ),
        onPressed: onPressed,
        label: const Text("refresh",
          style: TextStyle(
            color: Colors.yellow,
          ),
        ),
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bug_report),
          Text(errorMessage ?? "Opps!, something went wrong!",
            textAlign: TextAlign.center,
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.yellow,),
            onPressed: onPressed,
            label: const Text("refresh",
              style: TextStyle(
                color: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
