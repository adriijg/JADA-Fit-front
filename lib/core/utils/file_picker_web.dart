import 'dart:async';
import 'dart:html';

Future<String?> pickImage() async {
  final completer = Completer<String?>();

  final input = FileUploadInputElement()
    ..accept = 'image/*';

  final s = input.style;
  s
    ..position = 'fixed'
    ..top = '-100px'
    ..left = '-100px'
    ..width = '1px'
    ..height = '1px'
    ..opacity = '0';

  document.body!.append(input);

  void complete(String? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  input.onChange.listen((Event event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      complete(Url.createObjectUrl(files.first));
    } else {
      complete(null);
    }
  });

  input.addEventListener('cancel', (Event event) => complete(null));

  input.addEventListener('blur', (Event event) {
    Future.delayed(Duration(seconds: 1), () {
      if (input.files == null || input.files!.isEmpty) {
        complete(null);
      }
    });
  });

  input.click();

  return completer.future.whenComplete(() {
    input.remove();
  });
}
