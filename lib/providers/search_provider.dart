import 'package:flutter/cupertino.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';

class SearchProvider extends ChangeNotifier{
  List<Unsplash> listSplash = [];
  String searching = "";
  int page = 1;


  Future<void> apiUnSplashSearch(String search) async{

    if(searching != search) {
      searching = search;
      listSplash.clear();
      page = 1;
      notifyListeners();
    }
    await Network.GET(Network.API_SEARCH, Network.paramsSearch(search, page++)).then((response) {
      if(response != null){
        listSplash.addAll(Network.parseUnSplashListSearch(response));
        Log.w("SearchPage length: ${listSplash.length}");
        notifyListeners();
      }
    });
  }

}