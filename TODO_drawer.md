Navigation Drawer Breakdown:
1. [ ] Add to _GemziHomeState: late GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(); bool isMenuOpen = false;
2. [ ] Update initState: scaffoldKey = GlobalKey<ScaffoldState>();
3. [ ] Change Scaffold: key: scaffoldKey, drawer: _buildDrawer(),
4. [ ] Update _buildTopHeader: Add GestureDetector(onTap: () { scaffoldKey.currentState!.openDrawer(); }, child: Icon(Icons.menu, color: richGold))
5. [ ] Add Widget _buildDrawer(): Drawer( child: Column(children: [ if logged UserAccountsDrawerHeader, ListView ListTile menu ]) )
6. [ ] Test
