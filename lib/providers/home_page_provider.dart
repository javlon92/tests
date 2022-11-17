import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class HomePageProvider extends ChangeNotifier{
  List category = ["For you","Today","Football","Following","Health","Recipes","Car"];
  List<Unsplash> listSplash = [];
  String searching = "All";
  int  page = 1; //selected = 0;
  double downloadPercent = 0;
  bool showDownloadIndicator = false, loadMoreData = false;

  set changeLoadMoreData(bool loadMoreData){
    this.loadMoreData = loadMoreData;
    notifyListeners();
  }



  Future<void> apiUnSplashSearch(String search) async{

    if(searching != search) {
      searching = search; listSplash.clear(); page = 1;
    }
    if(listSplash.isNotEmpty) {
      loadMoreData = true;
      notifyListeners();
    }
    await Network.GET(Network.API_SEARCH, Network.paramsSearch(searching, page++)).then((response) {
      if(response != null){
          listSplash.addAll(Network.parseUnSplashListSearch(response));
          loadMoreData = false;
        notifyListeners();
        Log.w("HomePage length: ${listSplash.length}");
      }
    });
  }

  void downloadFile(BuildContext context,String url,String filename) async {
    var permission = await _getPermission(Permission.storage);
    try{
      if(permission != false){

        var httpClient = http.Client();
        var request = http.Request('GET', Uri.parse(url));
        var res = httpClient.send(request);
        final response = await get(Uri.parse(url));
        Directory generalDownloadDir = Directory('/storage/emulated/0/Download');
        List<List<int>> chunks = [];
        int downloaded = 0;

        res.asStream().listen((http.StreamedResponse r) {
          r.stream.listen((List<int> chunk) {
            // Display percentage of completion

              chunks.add(chunk);
              downloaded += chunk.length;
              showDownloadIndicator = true;
              downloadPercent = (downloaded / r.contentLength!) * 100;
              debugPrint("${downloadPercent.floor()}");
            notifyListeners();

          }, onDone: () async {
            // Display percentage of completion
            debugPrint('downloadPercentage: $downloadPercent');
            //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Downloaded!"),));

              downloadPercent = 0;
              showDownloadIndicator = false;
              showSnackBar(context,"Downloaded!");
            notifyListeners();
            // Save the file
            File imageFile = File("${generalDownloadDir.path}/$filename.jpg");
            Log.w(generalDownloadDir.path);
            await imageFile.writeAsBytes(response.bodyBytes);
            return;
          });
        });
      }
      else {
        Log.i("Permission Denied");
      }
    }
    catch(e){
      Log.e(e.toString());
    }
  }

  void showSnackBar(BuildContext context,String str){
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
        SnackBar(content: Text(str),
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.70,left: 15,right: 15),
        ));
  }

  Future<bool> _getPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();

      if (result == PermissionStatus.granted) {
        return true;
      } else {
        Log.w(result.toString());
        return false;
      }
    }
  }
}