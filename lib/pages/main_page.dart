import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tests/pages/HomePage.dart';
import 'package:tests/providers/home_page_provider.dart';
import 'package:tests/providers/main_privoder.dart';
import 'package:provider/provider.dart';

import 'saerch_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<MainProvider,HomePageProvider>(
          builder: (context,main,home,_) {
            return Scaffold(
              extendBody: true,
              /// #Category
              appBar:  main.selected == 0? buildCategory(main,home) : null,
              /// #Body
              body: PageView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  /// #HomePage
                  HomePage(),
                  /// #SearchPage
                  SearchPage(),
                  /// #ChatPage
                  Center(child: Text("Chat Page")),
                  /// #Profile
                  Center(child: Text("Profile Page")),
                ],
              ),
              /// #BottomNavigationBar
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white
                ),
                margin: const EdgeInsets.only(left: 50,right: 50,bottom: 10),
                child: BottomNavigationBar(
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey.shade600,
                  currentIndex: main.selected,
                  onTap: (index)async{
                    await main.changeIndex(index);
                    _pageController.animateToPage(main.selected, curve: Curves.easeInOut, duration: const Duration(milliseconds: 500));

                  },
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_alt), label: "",),
                    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: "",),
                    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble), label: "",),
                    BottomNavigationBarItem(icon: home.listSplash.isEmpty ?
                    const CircleAvatar(radius: 13,backgroundImage: AssetImage("assets/images/back_image.png")):
                    CircleAvatar(radius: 13,backgroundImage: NetworkImage(home.listSplash.first.user!.profileImage!.medium!)),label: ""),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
  PreferredSize buildCategory(MainProvider main,HomePageProvider home) {
    return PreferredSize(
      preferredSize: const Size(double.infinity,55),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(7),
          itemCount: home.category.length,
          itemBuilder: (context,index){
            return InkWell(
              key: Key("category$index"),
              onTap: () async{
                  await main.changeIndexCategory(index);
                  home.apiUnSplashSearch(index == 0 ? "All" : home.category[index]);

              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: main.selectedIndex == index ? Colors.black : Colors.white,
                ),
                child: Center(
                    child: Text(home.category[index],style: TextStyle(color:main.selectedIndex == index ? Colors.white : Colors.black),)),
              ),
            );
          }
      ),
    );
  }
}
