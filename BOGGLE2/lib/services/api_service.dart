// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:boggle/models/post.dart';

// class ApiService {
//   final String baseUrl = 'http://127.0.0.1:8000/api/posts/';

//   Future<List<Post>> fetchPosts() async {
//     final response = await http.get(Uri.parse(baseUrl));

//     if (response.statusCode == 200) {
//       List jsonResponse = json.decode(response.body);
//       return jsonResponse.map((post) => Post.fromJson(post)).toList();
//     } else {
//       throw Exception('Failed to load posts');
//     }
//   }

//   Future<void> uploadPost(String title, String content, File image) async {
//     var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
//     request.fields['title'] = title;
//     request.fields['content'] = content;
//     request.files.add(await http.MultipartFile.fromPath('image', image.path));

//     var res = await request.send();
//     if (res.statusCode != 201) {
//       throw Exception('Failed to upload post');
//     }
//   }
// }
