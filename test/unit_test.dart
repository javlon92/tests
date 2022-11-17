import 'package:flutter_test/flutter_test.dart';
import 'package:tests/providers/home_page_provider.dart';
import 'package:tests/providers/search_provider.dart';
import 'package:tests/services/log_service.dart';

void main(){

  final homePr = HomePageProvider();
  final searchPr = SearchProvider();

  test("unit_test", () async {

    await homePr.apiUnSplashSearch("All");
    expect(homePr.listSplash, isNotEmpty);
    expect(homePr.listSplash.length, 15);

    await homePr.apiUnSplashSearch("All");
    expect(homePr.listSplash.length, 30);

  });

  test("unit_test search", () async {

    await searchPr.apiUnSplashSearch("Football");
    expect(searchPr.listSplash.length, 15);
    expect(searchPr.listSplash.first.tags!.first.title!, "Football".toLowerCase());

  });
  tearDown((){
    Log.i("Yakunlandi");
  });

}