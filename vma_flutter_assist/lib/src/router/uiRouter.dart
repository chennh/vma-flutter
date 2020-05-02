import 'package:flutter/material.dart';

import 'index.dart';

class UIRouter extends Router {
  final String _uiName;

  UIRouter.registry(
    String namespace, {
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
          builder: (context, child) => Container(
            child: Stack(
              children: <Widget>[
                child,
                Positioned(
                  left: 20,
                  bottom: 50,
                  child: FloatingActionButton.extended(
                    label: Text('UI'),
                    onPressed: () {
                      Router.getNSRouter(namespace)
                          .routerState
                          .pushReplacementNamed('UI_$namespace');
                    },
                  ),
                ),
              ],
            ),
          ),
        ) {
    final List<Widget> children = [];
    routes.forEach((name, builder) {
      children.add(RaisedButton(
        child: Text(name),
        onPressed: () {
          routerState.pushNamed(name);
        },
      ));
    });
    this.addRoute(
      _uiName,
      (context) => Container(
        child: GridView(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          children: children,
        ),
      ),
    );
  }
}
