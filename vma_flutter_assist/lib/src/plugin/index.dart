abstract class Plugin<T> {
  void init({T options});
}

abstract class Initializer<T> implements Plugin<T> {}
