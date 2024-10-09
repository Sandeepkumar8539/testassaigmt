//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(home: StudentManagementSystem()));
// }
//
// class Student {
//   String? id;
//   String name;
//   String className;
//   String imageUrl;
//   String gender;
//   int age;
//   String address;
//
//   Student({
//     this.id,
//     required this.name,
//     required this.className,
//     required this.imageUrl,
//     required this.gender,
//     required this.age,
//     required this.address,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'className': className,
//       'imageUrl': imageUrl,
//       'gender': gender,
//       'age': age,
//       'address': address,
//     };
//   }
// }
//
// class StudentManagementSystem extends StatefulWidget {
//   @override
//   _StudentManagementSystemState createState() => _StudentManagementSystemState();
// }
//
// class _StudentManagementSystemState extends State<StudentManagementSystem> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   final _formKey = GlobalKey<FormState>();
//   String? _editingStudentId;
//
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _classController = TextEditingController();
//   TextEditingController _ageController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   String _selectedGender = 'Male';
//   File? _imageFile;
//   String? _currentImageUrl;
//
//   void _resetForm() {
//     _editingStudentId = null;
//     _nameController.clear();
//     _classController.clear();
//     _ageController.clear();
//     _addressController.clear();
//     _selectedGender = 'Male';
//     _imageFile = null;
//     _currentImageUrl = null;
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<String> _uploadImage() async {
//     if (_imageFile == null) return '';
//
//     final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     final Reference ref = _storage.ref().child('student_images/$fileName');
//     final UploadTask uploadTask = ref.putFile(_imageFile!);
//     final TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }
//
//   Future<void> _saveStudent() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     String imageUrl = _currentImageUrl ?? '';
//     if (_imageFile != null) {
//       imageUrl = await _uploadImage();
//     }
//
//     final student = Student(
//       name: _nameController.text,
//       className: _classController.text,
//       imageUrl: imageUrl,
//       gender: _selectedGender,
//       age: int.parse(_ageController.text),
//       address: _addressController.text,
//     );
//
//     if (_editingStudentId != null) {
//       // Update existing student
//       await _firestore.collection('students').doc(_editingStudentId).update(student.toMap());
//     } else {
//       // Add new student
//       await _firestore.collection('students').add(student.toMap());
//     }
//
//     _resetForm();
//     Navigator.pop(context);
//   }
//
//   void _editStudent(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     setState(() {
//       _editingStudentId = doc.id;
//       _nameController.text = data['name'];
//       _classController.text = data['className'];
//       _ageController.text = data['age'].toString();
//       _addressController.text = data['address'];
//       _selectedGender = data['gender'];
//       _currentImageUrl = data['imageUrl'];
//     });
//     _showStudentForm();
//   }
//
//   Future<void> _deleteStudent(String id, String imageUrl) async {
//     await _firestore.collection('students').doc(id).delete();
//     if (imageUrl.isNotEmpty) {
//       try {
//         await _storage.refFromURL(imageUrl).delete();
//       } catch (e) {
//         print('Error deleting image: $e');
//       }
//     }
//   }
//
//   void _showStudentForm() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(_editingStudentId != null ? 'Edit Student' : 'Add Student'),
//         content: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: _imageFile != null
//                         ? Image.file(_imageFile!, fit: BoxFit.cover)
//                         : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
//                         ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
//                         : Icon(Icons.add_a_photo),
//                   ),
//                 ),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(labelText: 'Name'),
//                   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 TextFormField(
//                   controller: _classController,
//                   decoration: InputDecoration(labelText: 'Class'),
//                   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedGender,
//                   items: ['Male', 'Female', 'Other']
//                       .map((gender) => DropdownMenuItem(
//                     value: gender,
//                     child: Text(gender),
//                   ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedGender = value!;
//                     });
//                   },
//                   decoration: InputDecoration(labelText: 'Gender'),
//                 ),
//                 TextFormField(
//                   controller: _ageController,
//                   decoration: InputDecoration(labelText: 'Age'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) return 'Required';
//                     if (int.tryParse(value!) == null) return 'Invalid age';
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(labelText: 'Address'),
//                   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _resetForm();
//             },
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: _saveStudent,
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Management System'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('students').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final doc = snapshot.data!.docs[index];
//               final data = doc.data() as Map<String, dynamic>;
//
//               return Card(
//                 margin: EdgeInsets.all(8),
//                 child: ListTile(
//                   leading: data['imageUrl'].isNotEmpty
//                       ? ClipOval(
//                     child: Image.network(
//                       data['imageUrl'],
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                       : CircleAvatar(child: Icon(Icons.person)),
//                   title: Text(data['name']),
//                   subtitle: Text('Class: ${data['className']} | Age: ${data['age']}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () => _editStudent(doc),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () => _deleteStudent(doc.id, data['imageUrl']),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showStudentForm,
//         child: Icon(Icons.add),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _classController.dispose();
//     _ageController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'HomeScreen.dart';


class AddStudent extends StatefulWidget {
  final String? studentId;
  final String? name;
  final String? className;
  final String? gender;
  final int? age;
  final String? address;
  final String? imageUrl;

  AddStudent({
    this.studentId,
    this.name,
    this.className,
    this.gender,
    this.age,
    this.address,
    this.imageUrl,
  });

  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _classController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  String _selectedGender = 'Male';
  File? _imageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _nameController.text = widget.name ?? '';
      _classController.text = widget.className ?? '';
      _ageController.text = widget.age?.toString() ?? '';
      _addressController.text = widget.address ?? '';
      _selectedGender = widget.gender ?? 'Male';
      _currentImageUrl = widget.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) return '';

    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = _storage.ref().child('student_images/$fileName');
    final UploadTask uploadTask = ref.putFile(_imageFile!);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    String imageUrl = _currentImageUrl ?? '';
    if (_imageFile != null) {
      imageUrl = await _uploadImage();
    }

    final student = Student(
      name: _nameController.text,
      className: _classController.text,
      imageUrl: imageUrl,
      gender: _selectedGender,
      age: int.parse(_ageController.text),
      address: _addressController.text,
    );

    if (widget.studentId != null) {
      // Update existing student
      await _firestore
          .collection('students')
          .doc(widget.studentId)
          .update(student.toMap());
    } else {
      // Add new student
      await _firestore.collection('students').add(student.toMap());
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId != null ? 'Edit Student' : 'Add Student'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : _currentImageUrl != null &&
                                _currentImageUrl!.isNotEmpty
                            ? Image.network(_currentImageUrl!,
                                fit: BoxFit.cover)
                            : Icon(Icons.add_a_photo),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),

                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _classController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    labelText: 'Class',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Enter your class',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    filled: true,  // Background color
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 30,),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem<String>(
                    value: gender,
                    child: Text(
                      gender,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ))
                      .toList(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.male,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Gender',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Select Gender',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),

                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Age',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Enter Age',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),  // Rounded corners
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),  // Error border styling
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),  // Border when error
                    ),
                  ),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
                ),

                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.home,
                      color: Colors.blueAccent,
                    ),
                    labelText: 'Address',
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Enter Address',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),  // Rounded corners
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveStudent,
                  child: Text(
                    widget.studentId != null ? 'Update Student' : 'Add Student',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 60), backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Student {
  String? id;
  String name;
  String className;
  String imageUrl;
  String gender;
  int age;
  String address;

  Student({
    this.id,
    required this.name,
    required this.className,
    required this.imageUrl,
    required this.gender,
    required this.age,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'imageUrl': imageUrl,
      'gender': gender,
      'age': age,
      'address': address,
    };
  }
}

class StudentManagementSystem extends StatefulWidget {
  @override
  _StudentManagementSystemState createState() =>
      _StudentManagementSystemState();
}

class _StudentManagementSystemState extends State<StudentManagementSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _deleteStudent(String id, String imageUrl) async {
    await _firestore.collection('students').doc(id).delete();
    if (imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }

  void _editStudent(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudent(
          studentId: doc.id,
          name: data['name'],
          className: data['className'],
          gender: data['gender'],
          age: data['age'],
          address: data['address'],
          imageUrl: data['imageUrl'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('HomePage',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>DriverDashboard() ,));
          }, icon: Icon(Icons.add,color: Colors.white,size: 20,))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                elevation: 10, // Heavy shadow effect for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20), // More pronounced rounded corners
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.0), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ), // Gradient background
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: data['imageUrl'].isNotEmpty
                              ? Image.network(
                                  data['imageUrl'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  width: 80,
                                  height: 80,
                                  child: Icon(Icons.person,
                                      size: 40, color: Colors.white),
                                ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Name: ${data['name']} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Class: ${data['className']}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          'Gender: ${data['gender']} ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),

                        Text(
                          'Address: ${data['address']} ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 0),
                        Text(
                          'Age: ${data['age']} years',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 20),
                        // Extra space for visual balance

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              icon: Icon(Icons.edit, color: Colors.white),
                              label: Text(
                                'Edit',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _editStudent(doc),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              icon: Icon(Icons.delete, color: Colors.white),
                              label: Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () =>
                                  _deleteStudent(doc.id, data['imageUrl']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudent(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
