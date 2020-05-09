import 'plugin/index.dart';

class Assist {
  static final List<String> plugins = [];

  static void use<T>(Plugin<T> plugin, {T options}) {
    String pluginName = plugin.toString();
    assert(!plugins.contains(pluginName), '插件$pluginName已经安装，请勿重复安装');

    plugin.init(options: options);
    plugins.add(pluginName);
  }
}
