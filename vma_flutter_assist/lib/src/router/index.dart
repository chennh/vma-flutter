import 'package:flutter/material.dart';

import '../listener/listener.dart';
import '../model/model.dart';

/// 前置拦截器
typedef VRouterBeforeInterceptor = VRouterBeforeInterceptorResult Function(
  RouteSettings settings,
  WidgetBuilder builder,
    VRouter router,
);

class VRouterBeforeInterceptorResult {
  final bool result;
  final WidgetBuilder redirectTo;

  VRouterBeforeInterceptorResult(
    /// true - 继续执行下一个拦截器，false - 返回redirectTo
    this.result, {
    this.redirectTo,
  }) : assert(result != false || redirectTo != null);
}

/// 前置拦截跟踪器，可用于注销拦截器
class VRouterBeforeInterceptorTracker implements Tracker {
  final VRouter _router;
  final VRouterBeforeInterceptor _interceptor;

  VRouterBeforeInterceptorTracker(this._router, this._interceptor)
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
class VRouteTracker implements Tracker {
  final VRouter _router;
  final String _name;

  VRouteTracker(this._router, this._name)
      : assert(_router != null && _name != null);

  @override
  void dispose() {
    if (_router.routes != null && _router.routes.containsKey(_name)) {
      _router.routes.remove(_name);
    }
  }
}

class VRouter extends StatefulWidget {
  /// 所有已注册的路由映射，通过[VRouter.registry]注册，可通过[VRouter.namespace]或[VRouter.getRouter]读取
  static final Map<String, VRouter> _namespaceRouterMap = {};

  /// 对应[Navigator]的initialRoute
  final String initialRoute;

  /// 对应[Navigator]的routes
  final Map<String, WidgetBuilder> routes;

  /// 对应[Navigator]的onUnknownRoute
  final RouteFactory onUnknownRoute;

  /// 对应[Navigator]的observers
  final List<NavigatorObserver> observers;

  /// 路由前置拦截处理器
  final List<VRouterBeforeInterceptor> beforeHandlers;

  VRouter({
    Key key,
    this.initialRoute,
    @required this.routes,
    this.onUnknownRoute,
    this.observers = const [],
    this.beforeHandlers = const [],
  })  : assert(routes != null),
        super(key: key) {
    if (key != null) {
      VRouter._namespaceRouterMap[key.toString()] = this;
    }
  }

  VRouter.registry(
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
    assert(!VRouter._namespaceRouterMap.containsKey(namespace),
        '命名空间[$namespace]已存在');
    VRouter._namespaceRouterMap[namespace] = this;
  }

  /// 获取命名空间map
  static Map<String, VRouter> get namespace => _namespaceRouterMap;

  /// 根据命名空间获取特定的路由对象
  static VRouter getNSRouter(String namespace) => _namespaceRouterMap[namespace];

  /// 获取路由参数
  static Object getArgs(BuildContext context) {
    return ModalRoute.of(context).settings.arguments;
  }

  /// 获取路由参数
  static M getArgsModel<M extends Model>(
          BuildContext context, Model<M> model) =>
      model.fromJson(getArgs(context));

  /// 获取[VRouterState]
  static VRouterState of(BuildContext context) =>
      context.findAncestorStateOfType<VRouterState>();

  /// 获取widget对应的[VRouterState]
  /// 使用该方法要求必须在构造函数中定义key
  VRouterState get routerState {
    if (key == null) {
      throw Exception('必须在构造函数中指定key');
    }
    return (key as GlobalKey).currentState;
  }

  /// 获取widget对应的[NavigatorState]
  /// 使用该方法要求必须在构造函数中定义key
  NavigatorState get navigatorState => routerState.navigatorState;

  /// 添加前置拦截器
  VRouterBeforeInterceptorTracker addBeforeInterceptor(
      VRouterBeforeInterceptor interceptor) {
    beforeHandlers.add(interceptor);
    return VRouterBeforeInterceptorTracker(this, interceptor);
  }

  /// 移除前置拦截器
  void removeBeforeInterceptor(VRouterBeforeInterceptor interceptor) {
    if (beforeHandlers.contains(interceptor)) {
      beforeHandlers.remove(interceptor);
    }
  }

  /// 添加路由
  VRouteTracker addRoute(String routeName, WidgetBuilder builder) {
    assert(routes.containsKey(routeName), '路由名称已被使用，请勿重复定义');
    routes[routeName] = builder;
    return VRouteTracker(this, routeName);
  }

  /// 移除路由
  void removeRoute(String routeName) {
    if (routes.containsKey(routeName)) {
      routes.remove(routeName);
    }
  }

  @override
  VRouterState createState() => VRouterState();
}

class VRouterState extends State<VRouter> {
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
    VRouter router,
  ) {
    if (widget.beforeHandlers != null && widget.beforeHandlers.length > 0) {
      for (VRouterBeforeInterceptor before in widget.beforeHandlers) {
        VRouterBeforeInterceptorResult result =
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
