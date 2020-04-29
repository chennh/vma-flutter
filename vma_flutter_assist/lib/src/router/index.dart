import 'package:flutter/material.dart';

/// 前置拦截处理器
typedef RouterBeforeHandler = RouterBeforeHandlerResult Function(
  RouteSettings settings,
  WidgetBuilder builder,
  Router router,
);

class RouterBeforeHandlerResult {
  final bool result;
  final WidgetBuilder redirectTo;

  RouterBeforeHandlerResult(
    /// true - 继续执行下一个拦截器，false - 返回redirectTo
    this.result, {
    this.redirectTo,
  });
}

class RouterBeforeHandlerListener {
  Router _router;
  RouterBeforeHandler _handler;

  RouterBeforeHandlerListener(this._router, this._handler)
      : assert(_router != null && _handler != null);

  void dispose() {
    if (_router.beforeHandlers != null &&
        _router.beforeHandlers.contains(_handler)) {
      _router.beforeHandlers.remove(_handler);
    }
  }
}

class Router extends StatefulWidget {
  /// 所有已注册的路由映射，通过[Router.registry]注册，可通过[Router.namespace]或[Router.getRouter]读取
  static final Map<String, Router> _namespaceRouterMap = {};
  /// 对应[Navigator]的initialRoute
  final String initialRoute;
  /// 对应[Navigator]的routes
  final Map<String, WidgetBuilder> routes;
  /// 对应[Navigator]的onUnknownRoute
  final RouteFactory onUnknownRoute;
  /// 对应[Navigator]的observers
  final List<NavigatorObserver> observers;
  /// 路由前置拦截处理器
  final List<RouterBeforeHandler> beforeHandlers;

  Router({
    Key key,
    this.initialRoute,
    @required this.routes,
    this.onUnknownRoute,
    this.observers = const [],
    this.beforeHandlers = const [],
  })  : assert(routes != null),
        super(key: key) {
    if (key != null) {
      Router._namespaceRouterMap[key.toString()] = this;
    }
  }

  Router.registry(
    String namespace, {
    Key key,
    this.initialRoute,
    @required this.routes,
    this.onUnknownRoute,
    this.observers = const [],
    this.beforeHandlers = const [],
  })  : assert(namespace != null),
        assert(routes != null),
        super(key: key) {
    assert(!Router._namespaceRouterMap.containsKey(namespace),
        '命名空间[$namespace]已存在');
    Router._namespaceRouterMap[namespace] = this;
  }

  /// 使用该方法要求必须在构造函数中定义key
  NavigatorState get navigatorState {
    if (key == null) {
      throw Exception('必须在构造函数中指定key');
    }
    return ((key as GlobalKey).currentState as RouterState).navigatorState;
  }

  /// 获取命名空间map
  static Map<String, Router> get namespace => _namespaceRouterMap;

  /// 根据命名空间获取特定的路由对象
  static Router getRouter(String namespace) => _namespaceRouterMap[namespace];

  /// 获取[RouterState]
  static RouterState of(BuildContext context) =>
      context.findAncestorStateOfType<RouterState>();

  /// 获取路由参数
  static Object getArgs(BuildContext context) {
    return ModalRoute.of(context).settings.arguments;
  }

  /// 添加前置拦截器
  RouterBeforeHandlerListener addBeforeHandler(RouterBeforeHandler handler) {
    beforeHandlers.add(handler);
    return RouterBeforeHandlerListener(this, handler);
  }

  @override
  RouterState createState() => RouterState();
}

class RouterState extends State<Router> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// 获取[NavigatorState]
  NavigatorState get navigatorState {
    return _navigatorKey.currentState;
  }

  /// 前置拦截
  ///
  /// 拦截处理器返回非true时中断页面跳转，并跳转至[RouterBeforeHandler.redirectTo]
  WidgetBuilder _beforeRouter(
    RouteSettings settings,
    WidgetBuilder builder,
    Router router,
  ) {
    if (widget.beforeHandlers != null && widget.beforeHandlers.length > 0) {
      for (RouterBeforeHandler before in widget.beforeHandlers) {
        RouterBeforeHandlerResult result = before(settings, builder, widget);
        if (result.result != true) {
          return result.redirectTo;
        }
      }
    }
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: widget.initialRoute,
      onUnknownRoute: widget.onUnknownRoute,
      observers: widget.observers,
      onGenerateRoute: (settings) {
        if (widget.routes.containsKey(settings.name)) {
          return MaterialPageRoute(
            builder:
                _beforeRouter(settings, widget.routes[settings.name], widget),
            settings: settings,
          );
        }
        return widget.onUnknownRoute(settings);
      },
    );
  }
}
