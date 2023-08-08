import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatx/helper/helper.dart';
import 'package:chatx/pages/home/calls_tab.dart';
import 'package:chatx/pages/home/chat_tab.dart';
import 'package:chatx/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../api/api.dart';
import '../../helper/dialogs.dart';
import '../../models/chat_user.dart';
import '../../resources/assets.dart';
import '../../widgets/chat_user_card.dart';
import '../../widgets/profile_image_icon.dart';
import '../welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  /// for storing all users
  List<ChatUser> _list = [];

  ///for storing searched items
  final List<ChatUser> _searchList = [];

  ///for storing search status
  bool _isSearching = false;

  ///profile Image from Firebase Firestore
  late final _myFirestoreData;

  ///Tab Controller
  late TabController _tabController;

  ///Tabs List
  final List<Tab> tabsList = [
    ///ChatTabIcon
    Tab(
      height: 5.h,
      child: Lottie.asset(
        Assets.chats,
        height: 5.h,
        frameRate: FrameRate(60),
        onWarning: (p0) => const Text("Chats"),
      ),
    ),

    ///CallsTabIcon
    Tab(
      height: 5.5.h,
      child: Lottie.asset(
        Assets.calls,
        height: 5.5.h,
        frameRate: FrameRate(60),
        onWarning: (p0) => const Text("Calls"),
      ),
    ),
  ];

  ///Current Tab
  int currentTab = 0;

  /*********************************************
   * Method:  _initState()          *
   * - Author: Furqan Uddin                     *
   * - Date: 05-Aug-2023                        *
   * - Description: This method will ...*
   *   functionality to...  ...  *
   *********************************************/

  @override
  void initState() {
    
    _myFirestoreData =
        APIs.firestore.collection("users").doc(APIs.cuser.email).snapshots();
    super.initState();

    ///Hide Keyboard if it has on screen
    FocusManager.instance.primaryFocus!.unfocus();

    ///TabController
    _tabController = TabController(
        length: tabsList.length, vsync: this, initialIndex: currentTab);

    //FOr setting user status to active
    APIs.updateActiveStatus(true);

    ///for updating user active status according to lifecycle events
    ///resume -- active or online
    ///pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print("${Future.value()}");

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(false);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }

      return Future.value();
    });
  }

  /*********************************************
   * Method:  build          *
   * - Author: Furqan Uddin                     *
   * - Date: 05-Aug-2023                        *
   * - Description: This method will ...*
   *   functionality to...  ...  *
   *********************************************/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      ///if search is on & back button is pressed then close search
      ///or else simple close current screen on back button click
      onWillPop: () => _onWillPop(),

      child: Scaffold(
        ///APPBAR SECTION
        appBar: _appBar(context),

        ///Floating Action Button
        floatingActionButton: const _FloatingActionButton(),

        ///IF SEARCHING IS TRUE SHOW THIS STREAMBUILDER
        body: _isSearching
            ? StreamBuilder(

                ///Get all users from Firestore except me
                stream: APIs.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    ///If data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CupertinoActivityIndicator());

                    ///If some are all data is loaded
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data!
                          .map((e) => ChatUser.fromJson(e.data()))
                          .toList();
                  }

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.only(top: 0.8.h),

                      ///TO Preserve Scroll Position
                      key: const PageStorageKey<String>("Page"),
                      itemCount: _searchList.length,
                      itemBuilder: (context, index) =>
                          ChatUserCard(user: _searchList[index]),
                    );
                  } else {
                    return const Center(
                      child: Text("No Connection found!"),
                    );
                  }
                })

            ///IF SEARCHING IS FALSE THEN SHOW TABBARVIEW
            : TabBarView(
                physics: const BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                    ///Chat Tab/////
                    ChatsTab(list: _list),

                    ///Calls Tab///
                    const CallsTab()
                  ]),
      ),
    );
  }

  ////////////////////////////////////////////////
  /////////////***METHODS***/////////////////////
  ///////////////////////////////////////////////

  /*********************************************
   * WidgetName:  _onWillPop          *
   * - Author: Furqan Uddin                     *
   * - Date: 05-Aug-2023                        *
   * - Description: This widget will ...*
   *   functionality to...  ...  *
   *********************************************/
  _onWillPop() {
    if (_isSearching) {
      setState(() {
        _isSearching = !_isSearching;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  /*********************************************
   * WidgetName:  _appBar          *
   * - Author: Furqan Uddin                     *
   * - Date: 05-Aug-2023                        *
   * - Description: This widget provides the AppBar*
   *   functionality to...  TabBar, Profile Button, SearchField etc.  *
   *********************************************/
  AppBar _appBar(BuildContext context,) {
    return AppBar(
      toolbarHeight: _isSearching ? 9.h : 6.h,

      ///ChatX LOGO
      leadingWidth: 40.w,
      leading: _isSearching
          ? null
          : Container(
              padding: EdgeInsets.only(left: 4.w),
              alignment: Alignment.centerLeft,
              child: AnimatedTextKit(repeatForever: true, animatedTexts: [
                ColorizeAnimatedText(
                  'ChatX',
                  colors: [Colors.white70, Colors.grey, Colors.white],
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.w),
                )
              ]),
            ),
      elevation: 5,
      automaticallyImplyLeading: false,

      ///TextField
      title: _isSearching

          ///Top SearchField when true
          ? TextField(
              ///Hide Keyboard
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus!.unfocus(),

              style: TextStyle(letterSpacing: 0.3.w, fontSize: 17.5.sp),
              autofocus: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Name, Email ...",
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                        });
                      },
                      icon: const Icon(CupertinoIcons.clear_fill)),
                  hintStyle:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400)),

              ///when search text changes then update search List
              onChanged: (value) {
                _searchList.clear();

                ///_list is basically list of ChatUser
                ///So i is value stored in ChatUser (eg. we stored name, email, id, about etc.)
                for (var i in _list) {
                  if (i.name!.toLowerCase().contains(value.toLowerCase()) ||
                      i.email!.toLowerCase().contains(value.toLowerCase())) {
                    ///If user typed value is contains in _list of Chat then add that value to search list
                    _searchList.add(i);
                  }

                  ///Now update the state
                  setState(() {
                    _searchList;
                  });
                }
              },
            )
          : null,
      actions: [
        ///Search User
        ///Hide TabBar when searching button is clicked
        Visibility(
          visible: !_isSearching,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearching = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  Assets.searchUser,
                  alignment: Alignment.center,
                  height: 3.5.h,
                  color: Colors.white,
                ),
              )),
        ),

        ////

        ///Profile
        if (!_isSearching)

          ///POP Menu Button
          PopupMenuButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              ///Profile Page Popup Menu Item
              PopupMenuItem(
                enabled: true,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    ///Navigate to Profile Page
                    Helper.naviagteToScreen( ProfilePage(), context);
                  },
                  title: Text(
                    "Profile",
                    style: GoogleFonts.robotoSlab(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  trailing:

                      ///Profile Image
                      ProfileImageIcon(myFirestoreData: _myFirestoreData),
                ),
              ),

              //Divider
              const PopupMenuDivider(
                height: 1,
              ),

              ///Logout Popup Menu Item
              PopupMenuItem(
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      ///Logout Fuction
                      showLogoutDialog(context);
                    },
                    title: Text(
                      "Logout",
                      style: GoogleFonts.robotoSlab(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(
                      MdiIcons.logout,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
      ],

      ///TabBar
      bottom: _tabBar(),
    );
  }

  /*********************************************
   * method:  showLogoutDialog          *
   * - Author: Furqan Uddin                     *
   * - Date: 07-Aug-2023                        *
   * - Description: This widget provides the TabBaWhen user tap on logout button call this methodr*
   *   functionality: to show logout Dialog  *
   *********************************************/
  showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          height: 20.h,
          width: 70.w,
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 2,
              ),
              Text(
                "Are you sure?",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.sp),
              ),
              SizedBox(
                height: 6.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "No",
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.black),
                            )),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          ///If user is signout then set activeStatus to offline
                          await APIs.updateActiveStatus(false);

                          ///Sign out from app
                          Dialogs.showCircularProgressBar(context);
                          await APIs.auth.signOut().then((value) {
                            Navigator.pop(context);
                            Helper.navigateReplaceToScreen(
                                const WelcomePage(), context);
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white),
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*********************************************
   * WidgetName:  _tabBar          *
   * - Author: Furqan Uddin                     *
   * - Date: 05-Aug-2023                        *
   * - Description: This widget provides the TabBar*
   *   functionality to...  ...  *
   *********************************************/

  PreferredSize _tabBar() {
    return PreferredSize(
      preferredSize: Size(double.infinity, _isSearching ? 0 : 6.h),

      ///Hide TabBar when searching is On
      child: Visibility(
        visible: !_isSearching,
        child: TabBar(
          onTap: (index) {
            currentTab = index;
          },
          tabs: tabsList,
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _tabController,
          unselectedLabelColor: Colors.white54,
          labelPadding: EdgeInsets.all(0.2.h),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),

      //////
    );
  }
}

/*********************************************
 * WidgetName:  _FloatingActionButton          *
 * - Author: Furqan Uddin                     *
 * - Date: 05-Aug-2023                        *
 * - Description: This widget provides the Floating Action Button*
 *   functionality to...  show DialogBox to add user for conversation  *
 *********************************************/
class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
      child: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 1,
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            Assets.addUser,
            color: Colors.white,
            height: 3.h,
          ),
        ),
      ),
    );
  }
}
