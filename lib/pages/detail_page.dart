import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tests/models/unsplash_multi_model.dart';
import 'package:tests/providers/detail_provider.dart';
import 'package:tests/providers/search_provider.dart';
import 'package:tests/services/http_service.dart';
import 'package:tests/services/log_service.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  static String id = "/detail_page";
  final Unsplash unsplash;
  const DetailPage({Key? key,required this.unsplash}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with AutomaticKeepAliveClientMixin{

  late String searching = (widget.unsplash.tags !=null && widget.unsplash.tags!.isNotEmpty)? widget.unsplash.tags?.first.title??"All":"For you";
  late final ScrollController _scrollController;
  late final provider = Provider.of<DetailProvider>(context,listen: false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
      provider.listSplash.clear();
      provider.apiUnSplashSearch(searching);

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels.toInt()-50 == _scrollController.position.maxScrollExtent.toInt()) {
        if(provider.listSplash.length<=470){
          provider.loadMoreData = true;
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
    return SafeArea(
      child: Consumer<DetailProvider>(
        builder: (context,detail,_) {
          return Scaffold(
            backgroundColor: Colors.black,
            extendBody: true,
            body: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  children: [
                    Hero(
                      tag: widget.unsplash,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: CachedNetworkImage(
                          imageUrl: widget.unsplash.urls!.regular!,
                          placeholder: (context, url) => AspectRatio(
                              aspectRatio: widget.unsplash.width!/widget.unsplash.height!,
                              child: ColoredBox(color: Color(int.parse(widget.unsplash.color!.replaceFirst("#","0xFF"))),)),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(widget.unsplash.user!.profileImage!.medium!),
                        ),
                        title: Text(widget.unsplash.user!.name!),
                        subtitle: Text("${widget.unsplash.likes} Followers"),
                        trailing: TextButton(onPressed: () {  },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
                          ),
                          child: const Text("Follow",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                      )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 30,),
                      width: double.infinity,
                      color: Colors.white,
                      child: Center(child: Text(widget.unsplash.description ?? "")),
                    ),
                    /// #Save and Visit
                    buildSaveVisit(),

                    /// #Comments
                    buildComments(),

                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
                      ),
                      padding: const EdgeInsets.only(top: 20,bottom: 15),
                      child: const Text("More like this",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),),),

                    /// #GridView
                    Container(
                          color: Colors.white,
                      child: MasonryGridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: detail.listSplash.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        itemBuilder: (context, index) {
                          return  buildBody(detail,context, index);
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      height: 50,width: MediaQuery.of(context).size.width,
                      child: Visibility(
                          visible: detail.loadMoreData,
                          child: const Center(child: CupertinoActivityIndicator(radius: 20,))),
                    ),
                  ],
                ),

                TextButton(onPressed: ()async{
                  Navigator.of(context).pop();
                }, child: const Icon(Icons.arrow_back_sharp,color: Colors.white,),
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black.withOpacity(0.1),
                  ),),
              ],
            ),
          );
        }
      ),
    );
  }

  Container buildSaveVisit() {
    return Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.chat_bubble_fill),
                const Spacer(),
                TextButton(onPressed: () {  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 18),
                  ),
                  child: const Text("Visit",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                ),
                const SizedBox(width: 20,),
                TextButton(onPressed: () {  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 18),
                  ),
                  child: const Text("Save",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
                const Spacer(),
                const Icon(Icons.share),
              ],
            ),
          );
  }

  Container buildComments() {
    return Container(
            margin: const EdgeInsets.only(bottom: 4,top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const Text("Comments",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                const SizedBox(height: 15),
                Text("Love this Pin? Let ${widget.unsplash.user!.name!} know!"),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      child: const Text("N",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.black),),
                    ),
                    const SizedBox(width: 15,),
                    const Text("Add a comment"),
                  ],
                ),
              ],
            ),
          );
  }

  Widget buildBody(DetailProvider detail,BuildContext context, int index) {
    return Column(
      children: [
        InkWell(
          onTap: ()async{
            Navigator.of(context).pushReplacement(MaterialPageRoute (builder: (BuildContext context) => DetailPage(unsplash: detail.listSplash[index]),
            ),);
          },
          child: Hero(
            transitionOnUserGestures: true,
            tag: "detail$index",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: detail.listSplash[index].urls!.regular!,
                placeholder: (context, url) => AspectRatio(
                    aspectRatio: detail.listSplash[index].width!/detail.listSplash[index].height!,
                    child: ColoredBox(color: Color(int.parse(detail.listSplash[index].color!.replaceFirst("#","0xFF"))),)),
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
              detail.listSplash[index].description == null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: 30,width: 30, fit: BoxFit.cover,
                  imageUrl: detail.listSplash[index].user!.profileImage!.medium!,
                  placeholder: (context, url) => AspectRatio(
                      aspectRatio: detail.listSplash[index].width!/detail.listSplash[index].height!,
                      child: ColoredBox(color: Color(int.parse(detail.listSplash[index].color!.replaceFirst("#","0xFF"))),)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
                  : Flexible(
                child: Text(detail.listSplash[index].description!,maxLines: 2,overflow: TextOverflow.ellipsis,
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
