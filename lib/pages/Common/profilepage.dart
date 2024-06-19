import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tutorinsa/pages/Common/home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late String userId;
  bool isLoading = true;
  String name = 'John';
  String lastName = 'Doe';
  String insaAddress = 'insa@example.com';
  String filiere = 'Computer Science';
  String annee = '3rd Year';
  String imageUrl = '';
  String Password ='';

  bool isEditingName = false;
  bool isEditingLastName = false;
  bool isEditingInsaAddress = false;
  bool isEditingFiliere = false;
  bool isEditingAnnee = false;
  bool isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     userId = prefs.getString('userId')!;


    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    var doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (doc.exists) {
      setState(() {
        name = doc['Nom'];
        lastName = doc['Prénom'];
        insaAddress = doc['Email'];
        filiere = doc['Filiere'];
        annee = doc['Annee'];
        imageUrl = doc['Image'];
        isLoading = false;
        Password= doc['Password'];
      });
    }
  }

  Future<void> _updateUserProfile() async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'Nom': name,
      'Prénom': lastName,
      'Email': insaAddress,
      'Filiere': filiere,
      'Annee': annee,
      'Image': imageUrl,
      'Password': Password,
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    var storageRef = FirebaseStorage.instance.ref().child('user_images/$userId');
    var uploadTask = storageRef.putFile(_image!);
    var imageUrl = await (await uploadTask).ref.getDownloadURL();

    setState(() {
      this.imageUrl = imageUrl;
    });
    _updateUserProfile();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF5F67EA),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: imageUrl.isEmpty
                            ? const AssetImage('assets/images/nopicture.png')
                            : NetworkImage(imageUrl) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: getImage,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildEditableField('Nom', name, isEditingName, (value) {
                  setState(() {
                    name = value;
                  });
                }, () {
                  setState(() {
                    isEditingName = !isEditingName;
                  });
                  _updateUserProfile();
                }),
                const SizedBox(height: 16),
                _buildEditableField('Prénom', lastName, isEditingLastName, (value) {
                  setState(() {
                    lastName = value;
                  });
                }, () {
                  setState(() {
                    isEditingLastName = !isEditingLastName;
                  });
                  _updateUserProfile();
                }),
                const SizedBox(height: 16),
                _buildEditableField('Adresse INSA', insaAddress, isEditingInsaAddress, (value) {
                  setState(() {
                    insaAddress = value;
                  });
                }, () {
                  setState(() {
                    isEditingInsaAddress = !isEditingInsaAddress;
                  });
                  _updateUserProfile();
                }),
                const SizedBox(height: 16),
                _buildEditableField('Filière', filiere, isEditingFiliere, (value) {
                  setState(() {
                    filiere = value;
                  });
                }, () {
                  setState(() {
                    isEditingFiliere = !isEditingFiliere;
                  });
                  _updateUserProfile();
                }),
                const SizedBox(height: 16),
                _buildEditableField('Année', annee, isEditingAnnee, (value) {
                  setState(() {
                    annee = value;
                  });
                }, () {
                  setState(() {
                    isEditingAnnee = !isEditingAnnee;
                  });
                  _updateUserProfile();
                }),
                const SizedBox(height: 16),
                _buildEditableField('Mot de passe', '******', isEditingPassword, (value) {
                  // Gérer la mise à jour du mot de passe
                   setState(() {
                     Password = value;
                   });
                }, () {
                  setState(() {
                    isEditingPassword = !isEditingPassword;
                  });
                }, isPassword: true),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  title: const Text('Déconnexion'),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Supprimer le compte'),
                  leading: const Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    // Supprimer le compte de l'utilisateur
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, bool isEditing, ValueChanged<String> onChanged, VoidCallback onEditPressed, {bool isPassword = false}) {
    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            obscureText: isPassword,
            onChanged: onChanged,
          )
              : ListTile(
            subtitle: Text(label),
            title: Text(value),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: onEditPressed,
          child: Text(
            isEditing ? 'Sauvegarder' : 'Changer',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}