import 'package:flutter/material.dart';

class Counter extends StatelessWidget {

  final int numberOfTodos;
  final int totalCompletions;

  Counter({
    required this.numberOfTodos,
    required this.totalCompletions
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(40),
      child:Text(
         "$totalCompletions/$numberOfTodos",
         style: TextStyle(
           fontWeight: FontWeight.normal,
           fontSize:60,
           color: totalCompletions == numberOfTodos ? Colors.green : Colors.black,
         ),
      ),
    );
  }
}