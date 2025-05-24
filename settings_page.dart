// import 'package:flutter/material.dart';
// import '../main.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   bool get _isDarkMode => themeNotifier.value == ThemeMode.dark;

//   String _language = 'Tiếng Việt';
//   double _fontSize = 16.0;

//   void _toggleDarkMode(bool value) {
//     setState(() {
//       themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Cài Đặt'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             SwitchListTile(
//               title: const Text('Chế Độ Tối'),
//               value: _isDarkMode,
//               onChanged: _toggleDarkMode,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Ngôn Ngữ',
//                 border: OutlineInputBorder(),
//               ),
//               value: _language,
//               items: const [
//                 DropdownMenuItem(
//                   value: 'Tiếng Việt',
//                   child: Text('Tiếng Việt'),
//                 ),
//                 DropdownMenuItem(value: 'English', child: Text('English')),
//               ],
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _language = value;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Cỡ Chữ: ${_fontSize.toStringAsFixed(0)}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Slider(
//               value: _fontSize,
//               min: 12.0,
//               max: 24.0,
//               divisions: 6,
//               label: _fontSize.toStringAsFixed(0),
//               onChanged: (value) {
//                 setState(() {
//                   _fontSize = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.logout),
//                 label: const Text('Đăng Xuất'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
