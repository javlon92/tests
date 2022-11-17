import 'package:flutter/material.dart';

class MainProvider extends ChangeNotifier{
  int selectedIndex = 0, selected = 0;


   Future<void> changeIndex(int index)async {
     selected = index;
     notifyListeners();
   }

    Future<void> changeIndexCategory(int index)async {
      selectedIndex = index;
      notifyListeners();
    }

}