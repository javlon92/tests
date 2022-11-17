import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:tests/main.dart';
import 'package:tests/pages/HomePage.dart';
import 'package:tests/pages/main_page.dart';
import 'package:tests/providers/home_page_provider.dart';
import 'package:tests/providers/search_provider.dart';

/// flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/app_test.dart

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Intro", (WidgetTester tester) async{
     await tester.pumpWidget(const MyApp());
     // final searchPr = SearchProvider();
     await Future.delayed(const Duration(seconds: 10));
     await tester.tap(find.byKey(const Key("category2")));
     await tester.pumpAndSettle();

     await Future.delayed(const Duration(seconds: 10));
     // await tester.tap(find.byType(BottomNavigationBar).at(2));
     // await tester.pumpAndSettle();
     //
     // await Future.delayed(const Duration(seconds: 10));

     // expect(searchPr.listSplash, isEmpty);
     expect(find.byType(HomePage), findsOneWidget);
     expect(find.byType(MainPage), findsOneWidget);

  });

}