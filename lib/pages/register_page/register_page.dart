import 'package:apollo_bengkel/firebase.dart';
import 'package:apollo_bengkel/models/UserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var _formKey = GlobalKey<FormState>();

  var _namaTextController = TextEditingController();
  var _noHpTextController = TextEditingController();
  var _alamatTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();

  var _obscurePassword = true;
  var _isFetchingData = false;
  var _fetchingMsg = '';
  var _isErrorRegister = false;

  /// atur blur password
  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// validator input field form
  String? _validateNama(String? nama) {
    if (nama!.isEmpty) {
      return 'Nama cannot be empty';
    }

    return null;
  }

  String? _validateNoHp(String? noHp) {
    return null;
  }

  String? _validateAlamat(String? alamat) {
    if (alamat!.isEmpty) {
      return 'Alamat cannot be empty';
    }

    return null;
  }

  String? _validateEmail(String? email) {
    if (email!.isEmpty) {
      return 'Email cannot be empty';
    }

    /// pola email harus mengikuti regex ini
    var emailRegex = RegExp(
      r'^(([^<>()\\[\]\\.,;:\s@"]+(\.[^<>()\\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Email not valid';
    }

    return null;
  }

  String? _validatePassword(String? password) {
    if (password!.isEmpty) {
      return 'Password cannot be empty';
    }

    var passwordRegex = RegExp(
      r'(?=.{6,})',
    );

    if (!passwordRegex.hasMatch(password)) {
      return 'Password must at least 6 characters long';
    }

    return null;
  }

  String? _validatePasswordConfirmation(String? password) {
    var _password = _passwordTextController.text;

    if (_password != password) {
      return 'Password confirmation must be the same as password';
    }

    return null;
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      var nama = _namaTextController.text;
      var noHp = _noHpTextController.text;
      var alamat = _alamatTextController.text;
      var email = _emailTextController.text;
      var password = _passwordTextController.text;

      var userData = UserData(
        email: email,
        name: nama,
        noHp: noHp,
        alamat: alamat,
      );

      userData.checkoutItems = [];

      try {
        setState(() {
          _isFetchingData = true;
          _fetchingMsg = 'Registering user, please wait...';
        });

        await fireAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        print(e.code);

        setState(() {
          _isErrorRegister = true;
          _fetchingMsg = 'Invalid form data, please try again.';
        });
      }

      // jika sukses register user, bikin data user di firestore
      if (!_isErrorRegister) {
        await firestore
            .collection('/users')
            .add(userData.toJSON())
            .then((value) {
          setState(() {
            _fetchingMsg = 'Success Registering User !';

            // clear semua value di form
            _formKey.currentState!.reset();
          });
        });

        // jika tidak error langsung ke login page
        if (!_isErrorRegister) {
          _navigateToLogin();
        }
      }

      Future.delayed(
        Duration(
          seconds: 2,
        ),
        () {
          setState(() {
            _isErrorRegister = false;
            _fetchingMsg = '';
            _isFetchingData = false;
          });
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Colors.blue,
          ),
          onPressed: _isErrorRegister ? null : _navigateToLogin,
        ),
        title: Text(
          'Back to Login',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      /// component paling atas
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                    ),

                    /// komponen form
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// input field untuk nama
                            TextFormField(
                              enabled: !_isFetchingData,
                              validator: _validateNama,
                              controller: _namaTextController,
                              decoration: InputDecoration(
                                labelText: 'Nama',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// input field untuk nomer handphone
                            TextFormField(
                              enabled: !_isFetchingData,
                              keyboardType: TextInputType.phone,
                              validator: _validateNoHp,
                              controller: _noHpTextController,
                              decoration: InputDecoration(
                                labelText: 'No. Handphone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.phone_android_outlined),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// input field untuk alamat rumah
                            TextFormField(
                              enabled: !_isFetchingData,
                              validator: _validateAlamat,
                              controller: _alamatTextController,
                              decoration: InputDecoration(
                                labelText: 'Alamat Rumah',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// input field untuk email
                            TextFormField(
                              enabled: !_isFetchingData,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              controller: _emailTextController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// input field untuk password
                            TextFormField(
                              enabled: !_isFetchingData,
                              controller: _passwordTextController,
                              validator: _validatePassword,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.remove_red_eye,
                                  ),
                                  onPressed: _toggleObscurePassword,
                                ),
                              ),
                              obscureText: _obscurePassword,
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// input field untuk konfirmasi password
                            TextFormField(
                              enabled: !_isFetchingData,
                              validator: _validatePasswordConfirmation,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'Password Confirmation',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.remove_red_eye,
                                  ),
                                  onPressed: _toggleObscurePassword,
                                ),
                              ),
                              obscureText: _obscurePassword,
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            /// Tombol Register
                            Container(
                              width: double.infinity,
                              child: MaterialButton(
                                color: Theme.of(context).buttonColor,
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed:
                                    _isFetchingData ? null : _registerUser,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isFetchingData)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 30.0,
                      ),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Center(
                      child: Text(
                        _fetchingMsg,
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
