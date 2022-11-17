import 'package:flutter/cupertino.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';

class DetailProvider extends ChangeNotifier{
  List<Unsplash> listSplash = [];
  List<Unsplash> oldListSplash = [];
  String searching = "For you";
  int page = 1;
  bool loadMoreData = true;

  set changeLoadMoreData(bool loadMoreData) {
    this.loadMoreData = loadMoreData;
    notifyListeners();
  }


  Future<void> apiUnSplashSearch(String search) async{
    if(searching != search) {
      listSplash.clear();
      searching = search;
      page = 1;
    }

    await Network.GET(Network.API_SEARCH, Network.paramsSearch(search, page++)).then((response) {
      if(response != null){
          listSplash.addAll(Network.parseUnSplashListSearch(response));
          loadMoreData = false;
        notifyListeners();
        Log.w("DetailPage length: ${listSplash.length}");
      }
    });

  }
}