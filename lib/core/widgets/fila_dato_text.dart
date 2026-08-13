import 'package:flutter/material.dart';

class FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  
  const FilaDato({
    super.key, 
    required this.etiqueta, 
    required this.valor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta, 
            style: const TextStyle(
              color: Color.fromARGB(255, 37, 37, 37), 
              fontWeight: FontWeight.w500, 
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor, 
              style: const TextStyle(
                fontWeight: FontWeight.w500, 
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}