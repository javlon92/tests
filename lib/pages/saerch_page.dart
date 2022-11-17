import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/providers/search_provider.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';
import 'package:provider/provider.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  static String id="/search_page";
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin{

  late final ScrollController _scrollController;
  late final provider = Provider.of<SearchProvider>(context,listen: false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    provider.apiUnSplashSearch(provider.searching);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels.toInt()-50 == _scrollController.position.maxScrollExtent.toInt()) {
        if(provider.listSplash.length<=470){
         await  provider.apiUnSplashSearch(provider.searching);
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
    return SafeArea(
      child: Consumer<SearchProvider>(
        builder: (context,search,_) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(double.infinity,65),
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 15,),
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted:(text) {
                      search.apiUnSplashSearch(text);
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search,color: Colors.black,),
                    border: InputBorder.none,
                    hintText: "Search",
                    suffixIcon: Icon(Icons.camera_alt,color: Colors.black,)
                  ),
                ),
              ),

            ),
            body: MasonryGridView.count(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              itemCount: search.listSplash.length,
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              itemBuilder: (context, index) {
                return  buildBody(search,context, index);
              },
            ),
          );
        }
      ),
    );
  }
  Widget buildBody(SearchProvider search,BuildContext context, int index) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute (builder: (BuildContext context) => DetailPage(unsplash:search.listSplash[index]),
              ),);
            },
            child: CachedNetworkImage(
              imageUrl: search.listSplash[index].urls!.regular!,
              placeholder: (context, url) => AspectRatio(
                  aspectRatio: search.listSplash[index].width!/search.listSplash[index].height!,
                  child: ColoredBox(color: Color(int.parse(search.listSplash[index].color!.replaceFirst("#", "0xFF"))),)),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              search.listSplash[index].description == null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: 30,width: 30, fit: BoxFit.cover,
                  imageUrl: search.listSplash[index].user!.profileImage!.medium!,
                  placeholder: (context, url) => AspectRatio(
                      aspectRatio: search.listSplash[index].width!/search.listSplash[index].height!,
                      child: ColoredBox(color: Color(int.parse(search.listSplash[index].color!.replaceFirst("#", "0xFF"))),)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
                  : Flexible(
                child: Text(search.listSplash[index].description!,maxLines: 2,overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
              ),
              //Spacer(),
              const Icon(Icons.more_horiz,color: Colors.black,),
            ],
          ),
        ),
      ],
    );
  }
}
