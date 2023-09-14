import 'package:http/http.dart' as http;

//api call
class api_service {
  location_api(context) async {
    try {
      var url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?destination=Montreal&origin=Toronto&key=AIzaSyBth_plK8TfuSkD4zw8R8EZpuiXfQztr7k');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer '
        },
      );
      print(response.body);
      print(response.statusCode);
    } catch (e) {
      print('errors:$e');
    }
  }
}
