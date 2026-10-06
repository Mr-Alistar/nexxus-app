import 'package:flutter/material.dart';

// ViewModel para la gestión del Dashboard, como si fueran Tabs o pestañas
class DashboardViewModel extends ChangeNotifier {
  int _indiceActual = 0;
  int get indiceActual => _indiceActual;

  //Cambia el índice de la "tab" seleccionada y notifica a la vista.
  void cambiarIndice(int nuevoIndice) {
    if (nuevoIndice != _indiceActual) {
      _indiceActual = nuevoIndice;
      notifyListeners();
    }
  }
}
