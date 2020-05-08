import 'package:flutter/material.dart';

import 'index.dart';

class UIRouter extends Router {
  static final List<UIRouter> uiRouterList = [];
  final String _uiName;

  UIRouter.registry(String namespace, {
    Key key,
    String initialRoute,
    Map<String, WidgetBuilder> routes,
    RouteFactory onUnknownRoute,
    List<NavigatorObserver> observers = const [],
    List<RouterBeforeInterceptor> beforeHandlers = const [],
  })  : _uiName = 'UI_$namespace',
        super.registry(
        namespace,
        key: key,
        initialRoute: 'UI_$namespace',
        routes: routes,
        onUnknownRoute: onUnknownRoute,
        observers: observers,
        beforeHandlers: beforeHandlers,
        builder: (context, child) =>
            Container(
              child: Stack(
                children: <Widget>[
                  child,
                  Positioned(
                    left: 20,
                    bottom: 20 + 30 * (uiRouterList.length + 1).toDouble(),
                    child: FloatingActionButton.extended(
                      label: Text('UI $namespace'),
                      onPressed: () {
                        Router
                            .getNSRouter(namespace)
                            .routerState
                            .pushReplacementNamed('UI_$namespace');
                      },
                    ),
                  ),
                ],
              ),
            ),
      ) {
    Map<String, List<String>> group = _group(routes);
    final List<Widget> children = [];
    group.forEach((title, list) {
      children.add(Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Wrap(
              children: list
                  .map((name) =>
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: _uiItem(name, routes[name])))
                  .toList(),
            )
          ],
        ),
      ));
    });
    this.addRoute(
      _uiName,
          (context) =>
          Scaffold(
            backgroundColor: Colors.grey,
            body: ListView(
              children: children,
            ),
          ),
    );
    uiRouterList.add(this);
  }

  /// UI分组
  Map<String, List<String>> _group(Map<String, WidgetBuilder> routes) {
    String unName = '未分组';
    Map<String, List<String>> group = {unName: []};
    Map<String, String> alongMap = {};
    routes.forEach((name, builder) {
      List<String> names = name.split('/');
      if (names.length == 1) {
        alongMap[names[0]] = name;
      } else {
        if (!group.containsKey(names[0])) {
          group[names[0]] = [];
        }
        group[names[0]].add(name);
      }
    });
    alongMap.forEach((name, widget) {
      if (group.containsKey(name)) {
        group[name].add(widget);
      } else {
        group[unName].add(widget);
      }
    });
    return group;
  }

  Widget _uiItem(String name, WidgetBuilder builder) =>
      RaisedButton(
        child: Text(name),
        onPressed: () {
          routerState.pushNamed(name);
        },
      );
}
