import 'package:flutter/material.dart';

import '../listener/listener.dart';
import '../model/model.dart';

/// 前置拦截器
typedef RouterBeforeInterceptor = RouterBeforeInterceptorResult Function(
  RouteSettings settings,
  WidgetBuilder builder,
  Router router,
);

class RouterBeforeInterceptorResult {
  final bool result;
  final WidgetBuilder redirectTo;

  RouterBeforeInterceptorResult(
    /// true - 继续执行下一个拦截器，false - 返回redirectTo
    this.result, {
    this.redirectTo,
  }) : assert(result != false || redirectTo != null);
}

/// 前置拦截跟踪器，可用于注销拦截器
class RouterBeforeInterceptorTracker implements Tracker {
  final Router _router;
  final RouterBeforeInterceptor _interceptor;

  RouterBeforeInterceptorTracker(this._router, this._interceptor)
      : assert(_router != null && _interceptor != null);

  @override
  void dispose() {
    if (_router.beforeHandlers != null &&
        _router.beforeHandlers.contains(_interceptor)) {
      _router.beforeHandlers.remove(_interceptor);
    }
  }
}

/// 路由跟踪器，可用于注销路由
class RouteTracker implements Tracker {
  final Router _router;
  final String _name;

  RouteTracker(this._router, this._name)
      : assert(_router != null && _name != null);

  @override
  void dispose() {
    if (_router.routes != null && _router.routes.containsKey(_name)) {
      _router.routes.remove(_name);
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
  final List<RouterBeforeInterceptor> beforeHandlers;

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

  /// 获取命名空间map
  static Map<String, Router> get namespace => _namespaceRouterMap;

  /// 根据命名空间获取特定的路由对象
  static Router getNSRouter(String namespace) => _namespaceRouterMap[namespace];

  /// 获取路由参数
  static Object getArgs(BuildContext context) {
    return ModalRoute.of(context).settings.arguments;
  }

  /// 获取路由参数
  static M getArgsModel<M extends Model>(
          BuildContext context, Model<M> model) =>
      model.fromJson(getArgs(context));

  /// 获取[RouterState]
  static RouterState of(BuildContext context) =>
      context.findAncestorStateOfType<RouterState>();

  /// 获取widget对应的[RouterState]
  /// 使用该方法要求必须在构造函数中定义key
  RouterState get routerState {
    if (key == null) {
      throw Exception('必须在构造函数中指定key');
    }
    return (key as GlobalKey).currentState;
  }

  /// 获取widget对应的[NavigatorState]
  /// 使用该方法要求必须在构造函数中定义key
  NavigatorState get navigatorState => routerState.navigatorState;

  /// 添加前置拦截器
  RouterBeforeInterceptorTracker addBeforeInterceptor(
      RouterBeforeInterceptor interceptor) {
    beforeHandlers.add(interceptor);
    return RouterBeforeInterceptorTracker(this, interceptor);
  }

  /// 移除前置拦截器
  void removeBeforeInterceptor(RouterBeforeInterceptor interceptor) {
    if (beforeHandlers.contains(interceptor)) {
      beforeHandlers.remove(interceptor);
    }
  }

  /// 添加路由
  RouteTracker addRoute(String routeName, WidgetBuilder builder) {
    assert(routes.containsKey(routeName), '路由名称已被使用，请勿重复定义');
    routes[routeName] = builder;
    return RouteTracker(this, routeName);
  }

  /// 移除路由
  void removeRoute(String routeName) {
    if (routes.containsKey(routeName)) {
      routes.remove(routeName);
    }
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

  /// 同[NavigatorState.pushNamed]
  /// 入参必须继承自[Model]
  @optionalTypeArgs
  Future<T> pushNamed<T extends Object, M extends Model>(
    String routeName, {
    Model<M> arguments,
  }) =>
      navigatorState.pushNamed(
        routeName,
        arguments: arguments?.toJson(),
      );

  /// 同[NavigatorState.pushReplacementNamed]
  /// 入参必须继承自[Model]
  @optionalTypeArgs
  Future<T> pushReplacementNamed<T extends Object, TO extends Object,
          M extends Model>(
    String routeName, {
    TO result,
    Model<M> arguments,
  }) =>
      navigatorState.pushReplacementNamed(
        routeName,
        result: result,
        arguments: arguments?.toJson(),
      );

  /// 同[NavigatorState.popAndPushNamed]
  /// 入参必须继承自[Model]
  @optionalTypeArgs
  Future<T>
      popAndPushNamed<T extends Object, TO extends Object, M extends Model>(
    String routeName, {
    TO result,
    Model<M> arguments,
  }) =>
          navigatorState.popAndPushNamed(
            routeName,
            result: result,
            arguments: arguments?.toJson(),
          );

  /// 同[NavigatorState.pushNamedAndRemoveUntil]
  /// 入参必须继承自[Model]
  @optionalTypeArgs
  Future<T> pushNamedAndRemoveUntil<T extends Object, M extends Model>(
    String newRouteName,
    RoutePredicate predicate, {
    Model<M> arguments,
  }) =>
      navigatorState.pushNamedAndRemoveUntil(
        newRouteName,
        predicate,
        arguments: arguments?.toJson(),
      );

  /// 前置拦截
  ///
  /// 拦截处理器返回非true时中断页面跳转，并跳转至[RouterBeforeInterceptor.redirectTo]
  WidgetBuilder _beforeRouter(
    RouteSettings settings,
    WidgetBuilder builder,
    Router router,
  ) {
    if (widget.beforeHandlers != null && widget.beforeHandlers.length > 0) {
      for (RouterBeforeInterceptor before in widget.beforeHandlers) {
        RouterBeforeInterceptorResult result =
            before(settings, builder, widget);
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
