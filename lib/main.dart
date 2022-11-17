import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/pages/HomePage.dart';
import 'package:tests/pages/detail_page.dart';
import 'package:tests/pages/main_page.dart';
import 'package:tests/pages/picker_image_page.dart';
import 'package:tests/pages/saerch_page.dart';
import 'package:tests/providers/detail_provider.dart';
import 'package:tests/providers/home_page_provider.dart';
import 'package:tests/providers/main_privoder.dart';
import 'package:tests/providers/search_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  /// #Orintationni bloklash uchun
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      builder: (context,_) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MainPage(),
          routes: {
            HomePage.id: (context) => const HomePage(),
            SearchPage.id: (context) => const SearchPage(),
            DetailPage.id: (context) => DetailPage(unsplash: Unsplash(),),
            ImagePickerPage.id: (context) => const ImagePickerPage(),
          },
        );
      }, providers: [
      ChangeNotifierProvider(create: (context) => MainProvider()),
      ChangeNotifierProvider(create: (context) => HomePageProvider()),
      ChangeNotifierProvider(create: (context) => SearchProvider()),
      ChangeNotifierProvider(create: (context) => DetailProvider()),
    ],
    );
  }
}


