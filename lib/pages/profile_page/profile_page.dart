import 'dart:io';
import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _nameTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  var _alamatTextController = TextEditingController();
  var _noHpTextController = TextEditingController();

  var _isLoading = false;
  var _loadingMsg = '';
  var _picker = ImagePicker();
  UserData? _user;

  Future<void> _populateForm() async {
    var email = fireAuth.currentUser!.email!;

    await firestore
        .collection('/users')
        .where(
          'email',
          isEqualTo: email,
        )
        .get()
        .then((col) => col.docs.first)
        .then((doc) {
      _user = UserData.fromJSON({
        'id': doc.id,
        ...doc.data(),
      });

      setState(() {
        _nameTextController.text = _user!.name;
        _emailTextController.text = email;
        _alamatTextController.text = _user!.alamat;
        _noHpTextController.text = _user!.noHp;
      });
    });
  }

  Future<void> _updateAndSave() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMsg = 'Updating data, please wait...';
      });
    }

    await firestore
        .collection('/users')
        .where(
          'email',
          isEqualTo: fireAuth.currentUser!.email,
        )
        .get()
        .then((col) async {
      _user!.name = _nameTextController.text;
      _user!.alamat = _alamatTextController.text;
      _user!.noHp = _noHpTextController.text;

      await col.docs.first.reference.update(_user!.toJSON()).then((_) {
        if (mounted) {
          setState(() {
            _loadingMsg = 'Success !';
          });
        }
      }).onError((error, stackTrace) {
        if (mounted) {
          setState(() {
            _loadingMsg = 'Update failed !';
          });
        }
      });

      await Future.delayed(
        Duration(seconds: 2),
        () {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadingMsg = '';
            });
          }
        },
      );
    });
  }

  Future<void> _pickPhoto(BuildContext context) async {
    var pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    var pickedImage = File(pickedFile.path);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Upload Profile Picture'),
        content: Text('Are you sure ?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
                _loadingMsg = 'Uploading Profile Pic...';
              });

              /// ambil data user

              var ref = firestorage
                  .refFromURL('gs://apollo_bengkel.appspot.com/user_photos');

              /// upload file ke firebase storage
              await ref
                  .child(_user!.id!)
                  .putFile(pickedImage)
                  .then((taskSnapshot) async {
                var photoURL = await taskSnapshot.ref.getDownloadURL();

                var doc =
                    await firestore.collection('/users').doc(_user!.id).get();

                /// update di collection users url fotonya
                await doc.reference.update({
                  'photo_url': photoURL,
                }).then((_) {
                  /// jika sukses tulis di layar 'sukses'
                  setState(() {
                    _loadingMsg = 'Success...';
                  });
                });
              }).catchError((_) {
                /// kalo nggak sukses
                setState(() {
                  _loadingMsg = 'Failed Uploading Profile Picture...';
                });
              });

              /// setelah kelar baru hapus loading screen
              await Future.delayed(
                Duration(seconds: 1),
                () {
                  setState(() {
                    _isLoading = false;
                    _loadingMsg = '';
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// untuk AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: Text(
          'Profile',
        ),
      ),

      /// komponen paling atas
      body: RefreshIndicator(
        onRefresh: _populateForm,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    children: [
                      /// untuk foto profil dan nama user
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// foto profil dapat di ubah
                          Container(
                            width: 70.0,
                            height: 70.0,
                            child: GestureDetector(
                              onTap: () => _pickPhoto(context),
                              child: Stack(
                                children: <Widget>[
                                  Opacity(
                                    opacity: 0.5,
                                    child: CircleAvatar(
                                      child: _user?.photoURL != null
                                          ? Image.network(_user!.photoURL!)
                                          : Image.asset('assets/logo.png'),
                                      radius: 40,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: Icon(
                                        Icons.edit,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// field untuk nama user
                          SizedBox(
                            width: 200,
                            child: TextField(
                              enabled: !_isLoading,
                              controller: _nameTextController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: UnderlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// input untuk email user (tidak dapat di edit karena 1 user harus 1 email permanent)
                      SizedBox(
                        width: 300,
                        child: TextField(
                          enabled: !_isLoading,
                          controller: _emailTextController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      /// input untuk alamat user
                      SizedBox(
                        width: 300,
                        child: TextField(
                          enabled: !_isLoading,
                          controller: _alamatTextController,
                          decoration: InputDecoration(
                            labelText: 'Alamat',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      /// input untuk nomer HP
                      SizedBox(
                        width: 300,
                        child: TextField(
                          enabled: !_isLoading,
                          controller: _noHpTextController,
                          decoration: InputDecoration(
                            labelText: 'No. HP',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                      ),

                      /// Tombol save
                      Container(
                        margin: const EdgeInsets.all(
                          10.0,
                        ),
                        width: 300.0,
                        child: MaterialButton(
                          child: Text(
                            'Update and Save',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _isLoading ? null : _updateAndSave,
                          color: Theme.of(context).buttonColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      _loadingMsg,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
