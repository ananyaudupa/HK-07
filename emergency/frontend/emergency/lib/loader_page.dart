// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart'; // Import the Lottie package
// import 'login_page.dart';
// import 'register_page.dart';
//
// class LoaderPage extends StatelessWidget { // Rename class to PascalCase
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.green.shade50, Colors.blue.shade500],
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Center(
//                   child: Container(
//                     child: Image.asset(
//                       'assets/Logo.png',
//                       width: 200,
//                       semanticLabel: 'Heart with medical cross',
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'Emergency Wave',
//                   style: TextStyle(
//                     fontSize: 45,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Container( // Use Lottie to render the JSON animation
//                   child: Lottie.asset(
//                     'assets/emergency.json',
//                     width: 200,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class LoaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Simple loader animation
      ),
    );
  }
}

