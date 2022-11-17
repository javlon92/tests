import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/pages/detail_page.dart';
import 'package:tests/pages/saerch_page.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/home_page_provider.dart';

class HomePage extends StatefulWidget {
  static String id = "/home_page";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
   late final ScrollController _scrollController;
   late final provider = Provider.of<HomePageProvider>(context,listen: false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    provider.apiUnSplashSearch("All");
    _scrollController.addListener(() async {
      debugPrint("${_scrollController.position.pixels.toInt()} ${_scrollController.position.maxScrollExtent.toInt() - 50} HomePage");
      if (_scrollController.position.pixels.toInt() >= _scrollController.position.maxScrollExtent.toInt()-50) {
        if(provider.listSplash.length <= 470 && !provider.loadMoreData) {
          provider.changeLoadMoreData = true;
          await provider.apiUnSplashSearch(provider.searching);
        }
      }
    });
  }

   @override
   // TODO: implement wantKeepAlive
   bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Consumer<HomePageProvider>(
          builder: (context,home,_) {
            return Column(
              children: [
                Visibility(
                    visible: home.listSplash.isEmpty,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    )),
                Expanded(
                  child: MasonryGridView.count(
                    key: const PageStorageKey<String>("HomePage"),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    itemCount: home.listSplash.length,
                    crossAxisCount: 2,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    itemBuilder: (context, index) {
                      return  buildBody(home,context, index);
                    },
                  ),
                ),
                Visibility(
                    visible: home.loadMoreData,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    )),
              ],
            );
          }
      ),
    );
  }

  Widget buildBody(HomePageProvider home,BuildContext context, int index) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute (builder: (BuildContext context) => DetailPage(unsplash: home.listSplash[index],),
            ),);
          },
          child: Hero(
            transitionOnUserGestures: true,
            tag: home.listSplash[index],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: home.listSplash[index].urls!.regular!,
                placeholder: (context, url) => AspectRatio(
                    aspectRatio: home.listSplash[index].width!/home.listSplash[index].height!,
                child: ColoredBox(color: Color(int.parse(home.listSplash[index].color!.replaceFirst("#","0xFF"))),)),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              home.listSplash[index].description == null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                   child: CachedNetworkImage(
                    height: 30,width: 30, fit: BoxFit.cover,
                    imageUrl: home.listSplash[index].user!.profileImage!.medium!,
                    placeholder: (context, url) => AspectRatio(
                      aspectRatio: home.listSplash[index].width!/home.listSplash[index].height!,
                      child: ColoredBox(color: Color(int.parse(home.listSplash[index].color!.replaceFirst("#","0xFF"))),)),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                  )
                  : Flexible(
                  child: Text(home.listSplash[index].description!,maxLines: 2,overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
              ),
              //Spacer(),
              InkWell(
                child: const Icon(Icons.more_horiz,color: Colors.black,),
                onTap: () {
                  //Log.e("BottomSheet");
                  showModalBottomSheet(context: context, builder: (context) {
                    return buildBottomSheet(home,context,index);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBottomSheet(HomePageProvider home,var context,int index) {
    return Container(
      color: Colors.white,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20,top: 10),
            child: Text("Share to",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                MaterialButton(onPressed: (){
                  launch("sms:?body=${home.listSplash[index].urls!.full!}");
                }, child: Image.asset("assets/images/message.png",height: 60,),
                ),
                MaterialButton(onPressed: (){
                  launch("https://t.me/share/url?url=${home.listSplash[index].urls!.full!}");
                }, child: Image.asset("assets/images/facebook.png",height: 60,),
                ),
                MaterialButton(onPressed: (){
                  launch("mailto:?body=${home.listSplash[index].urls!.full!}");
                }, child: Image.asset("assets/images/gmail.png",height: 60,),
                ),
                MaterialButton(onPressed: (){
                  launch("https://t.me/share/url?url=${home.listSplash[index].urls!.full!}");
                }, child: Image.asset("assets/images/telegram.png",height: 60,),
                ),
                MaterialButton(onPressed: (){
                  launch("https://api.whatsapp.com/send?text=${home.listSplash[index].urls!.full!}");
                }, child: Image.asset("assets/images/whatsapp.png",height: 60,),
                ),
                MaterialButton(onPressed: () async{
                  await Clipboard.setData(ClipboardData(text: home.listSplash[index].urls!.full!));
                  Navigator.of(context).pop();
                  home.showSnackBar(context,"Link Copied!");

                }, child: Image.asset("assets/images/copy_link.png",height: 60,),),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          MaterialButton(
              onPressed: () {
            home.downloadFile(context,home.listSplash[index].urls!.small!, DateTime.now().toString());
            Navigator.of(context).pop();
          },
              child: const Text("Download image",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),

          MaterialButton(
              onPressed: () {
            setState(() {
              home.listSplash.removeAt(index);
              Navigator.of(context).pop();
            });
          },
              child: const Text("Hide Pin",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),

          MaterialButton(onPressed: () {  },
              child: const Text("Report Pin",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),

          const Text("    This goes against Pinterest's community guidelines"),
        ],
      ),
    );

  }


}
