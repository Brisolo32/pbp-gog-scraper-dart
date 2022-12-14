import 'dart:convert';
import 'dart:io';
import "package:http/http.dart" as http;
import "package:path/path.dart" as path;

String returnString() {
  print('Cache location wasn\'t provided, using: "./"');
  return "./";
}

void main(List<String> args) async {
  // Checks if no arguments were provided
  if (args.isEmpty) {
    print(
        'Usage: "Game query (ex: terraria)" "Cache location (defaults to: "./")"\nProgram didn\'t run because no arguments were provided');
    exit(1);
  }

  // Arguments
  String query = args[0];
  String cache = !args.asMap().containsKey(1) ? returnString() : args[1];

  Map uriData = {
    'uri': 'embed.gog.com',
    'endpoint': '/games/ajax/filtered',
    'params': {'mediaType': 'game', 'search': query}
  };

  // Fetches data
  Uri url = Uri.https(uriData['uri'], uriData['endpoint'], uriData['params']);
  var res = await http.get(url);
  Map json = jsonDecode(res.body);
  dynamic products = json['products'];

  // If 'products' is empty print an error message
  // And exit with error code 1
  if (products.isEmpty) {
    print("No games were found, perhaps you typed it wrong");
    exit(1);
  }

  Map<String, dynamic> resData = {'response': []};

  // Runs over a loop of all 'products' entries
  // Then adds the data to a Map and adds it to resData
  for (int i = 0; i < products.length; i++) {
    Map prod = json['products'][i];
    Map data = {
      'title': prod['title'],
      'urls': ["https://gog.com${prod["url"]}"]
    };

    resData['response'].add(data);
  }

  // Writes the file to the cache and then logs a message
  dynamic file = File(path.join(cache, "results.json"));
  file.writeAsString(jsonEncode(resData));
}
