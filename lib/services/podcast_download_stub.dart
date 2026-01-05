// Stub file để thay thế dart:html khi chạy trên mobile/desktop
// Các class này sẽ không được sử dụng thực tế trên mobile

// Stub Window class
class Window {
  final Storage localStorage = Storage();
}

// Stub Storage class
class Storage {
  final Map<String, String> _data = {};
  
  bool containsKey(String key) => _data.containsKey(key);
  String? operator [](String key) => _data[key];
  void operator []=(String key, String value) => _data[key] = value;
  void remove(String key) => _data.remove(key);
  void forEach(void Function(String key, String value) action) {
    _data.forEach(action);
  }
}

// Stub Document class
class Document {
  BodyElement? body = BodyElement();
}

// Stub BodyElement class
class BodyElement {
  void append(dynamic element) {}
}

// Stub AnchorElement class
class AnchorElement {
  final String? href;
  String? download;
  String? target;
  
  AnchorElement({this.href});
  
  void click() {}
  void remove() {}
}

// Global stubs
final Window window = Window();
final Document document = Document();

