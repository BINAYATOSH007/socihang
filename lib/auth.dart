import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socihang/user_image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth=FirebaseAuth.instance;
    class AuthScreen extends StatefulWidget {
      const AuthScreen({super.key});
    
      @override
      State<AuthScreen> createState() => _AuthScreenState();
    }
    
    class _AuthScreenState extends State<AuthScreen> {
      final _formkey =GlobalKey<FormState>();
      var _isLogin=true;
      var _enteredEmail='';
      var _enteredPassword='';
      var _enteredUsername='';
      File? _selectedImage;
      void _submit ()async{

       final isValid= _formkey.currentState!.validate();

       if(!isValid ||!_isLogin && _selectedImage==null ){
         return;
       }
       _formkey.currentState!.save();
    try{
        if(_isLogin){
          final userCredentials=await _auth.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);
          print(userCredentials);
        }else{
         
          final userCredentials=await _auth.createUserWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);
          print(userCredentials);
        final storageRef=  FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl=await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid).set(
          {
            'username':_enteredUsername,
            'email': _enteredEmail,
          'image_url':imageUrl
          }
        );

        }
        }
        on FirebaseAuthException catch(error) {

      if(error.code=='email already in use'){
        //..
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(error.message??'authentication failed'),
      ),
      );


    }

      }


      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30.0,
                      bottom: 20.0,
                      left: 20.0,
                      right: 20,
                    ),
                    child: Image.asset('assets/sh-logo-design_731343-601.jpg'),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formkey,
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                          children: [
                            if(!_isLogin)
                             UserImagePicker(onPickImage: (pickedImage){

                               _selectedImage=pickedImage;
                             }),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address'
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value){
                                if(value==null||value.trim().isEmpty||!value.contains('@')){
                                  return 'Pls enter valid email address.';

                                }
                                return  null;

                                },
                              onSaved: (value){
                                _enteredEmail=value!;
                              },
                            ),
                            if(!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(labelText: "Username"),
                              enableSuggestions: false,
                              validator: (value){
                                if(value==null ||value.isEmpty||value.trim().length<4){
                                  return 'Please enter a valid username(atleast 4 chars)';
                                }
                                return null;
                              },
                              onSaved: (value){
                                _enteredUsername=value!;
                              },
                            ),
                            TextFormField(
                              decoration:const InputDecoration(
                                  labelText: 'Password'
                              ),
                             obscureText: true,
                              validator: (value){
                                if(value==null||value.trim().length<6){
                                  return 'Password must be atleast 6 letters';

                                }
                                return  null;

                              },
                              onSaved: (value){
                                _enteredPassword=value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer
                              ),
                              child: const Text('Signup'),
                            ),
                            TextButton(onPressed: (){
                              setState(() {
                                _isLogin=!_isLogin;
                              });
                            }, child:Text(_isLogin?'Create an account':'I already have an account.Login.'),

                            ),

                          ],
                      ),
                      ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }
    