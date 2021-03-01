import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// screen with a form to create a new post and submit the data to the firebase

class PostComposer extends StatefulWidget {
  PostComposer({Key key}) : super(key: key);

  _PostComposer createState() => _PostComposer();
}

class _PostComposer extends State<PostComposer> {
  var images = List<File>(), isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = new TextEditingController(),
      _textController = new TextEditingController();
  static const int maximumTextCharacters = 200;
  static const int maximumPictures = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Padding(padding: EdgeInsets.only(bottom: 60.0)),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("New Post"),
      ),
      body: WillPopScope(
          onWillPop: () => _onBackPressed(),
          // Execute the "_onBackPressed" function if the user goes backwards into the application
          child: Stack(children: [
            Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        // field allowing the user to enter a title
                        controller: _titleController,
                        validator: (value) {
                          // function verifying the integrity of the entered data
                          if (value.isEmpty) {
                            // check that the title is not empty
                            return 'Please enter a title';
                          } else if (value.length > 20) {
                            // check that the title doesn't exceed 20 characters
                            return 'Please enter a title not exceeding 20 characters';
                          }
                          return null;
                        },
                        inputFormatters: [
                          // limit the number of characters to 20
                          new LengthLimitingTextInputFormatter(20),
                        ],
                        textInputAction: TextInputAction.next,
                        autocorrect: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: new BorderSide(width: 1)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          hintText: "Type post's title here...",
                          labelText: "Title",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        minLines: 1,
                        maxLength: 20,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        // add a spacing of 20 between the widgets
                        height: 20,
                      ),
                      TextFormField(
                        // text field for user to enter a text not exceeding 200 characters
                        controller: _textController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a text';
                          } else if (value.length > 200) {
                            return 'Please enter a text not exceeding $maximumTextCharacters characters';
                          }
                          return null;
                        },
                        inputFormatters: [
                          // limit the number of characters to 200
                          new LengthLimitingTextInputFormatter(
                              maximumTextCharacters),
                        ],
                        autocorrect: true,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: new BorderSide(width: 1)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 15),
                          hintText: "Type your message here...",
                          labelText: "Message",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        minLines: 5,
                        maxLength: maximumTextCharacters,
                        keyboardType: TextInputType.multiline,
                        // set the text field to multiple lines mode
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          RaisedButton(
                            color: Colors.grey[200],
                            onPressed: () {
                              _getImage(ImageSource.gallery);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Select a pic",
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RaisedButton(
                            color: Colors.grey[200],
                            onPressed: () {
                              _getImage(ImageSource.camera);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Take a photo",
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5)),
                          height: 100,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: images != null && images.length > 0
                              ? ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images != null ? images.length : 0,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      width: 90,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Stack(
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[600],
                                                      width: 2)),
                                              child: Image.file(images[index])),
                                          Positioned(
                                              top: 5,
                                              right: 5,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      images.removeAt(index);
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red,
                                                  )))
                                        ],
                                      ),
                                    );
                                  })
                              : Center(
                                  child: Text(
                                  "No pictures added yet...",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 15),
                                ))),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Maximum 4 images",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ))
                    ],
                  ),
                )),
            Positioned(
              right: 70,
              bottom: 30,
              child: RaisedButton(
                // Reset Button positioned at the screen's bottom left corner (onPressed -> clear stored data in var text and images)
                shape: CircleBorder(),
                padding: EdgeInsets.all(17),
                elevation: 8,
                color: Colors.redAccent,
                onPressed: () {
                  setState(() {
                    _formKey.currentState.reset();
                    _textController.clear();
                    _titleController.clear();
                    images.clear();
                  });
                },
                child: Icon(Icons.delete_forever, color: Colors.white),
              ),
            )
          ])),
      floatingActionButton: FloatingActionButton(
        //Button to send the post to the database
        onPressed: () {
          if (_formKey.currentState.validate()) {
            // check if the inputs are correct
            _submitPost();
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }

  _getImage(ImageSource imageSource) async {
    // function to pick a picture from the user's device (either from the gallery or from the camera)
    if (images == null || images.length < maximumPictures) {
      // check that the number of selected images does not exceed 4
      PickedFile pickedFile = await ImagePicker().getImage(
        source: imageSource,
        imageQuality: 75, // limit the quality of the image to 75%
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          images.add(File(pickedFile
              .path)); // add the image path to the images variable if the file is not null
        });
      }
    } else {
      _showAlertDialog(
          context,
          "Pictures Limit",
          // show an alert dialog if the user is trying to upload more than 4 pictures
          "You have reached the maximum of $maximumPictures pictures per post",
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ]);
    }
  }

  _showAlertDialog(BuildContext context, String title, String text,
      // function used to display a custom alert dialog
      {List<Widget> actions}) {
    AlertDialog alert =
        AlertDialog(title: Text(title), content: Text(text), actions: actions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> _onBackPressed() async {
    // if data was entered into the form, ask the user confirmation before quitting the current screen
    if (_textController.text.isNotEmpty ||
        _titleController.text.isNotEmpty ||
        (images.isNotEmpty)) {
      _showAlertDialog(
          context, "Exit", "Are you sure you want to leave without savings?",
          actions: [
            FlatButton(
              child: Text("NO"),
              onPressed: () {
                Navigator.pop(
                    context); // if the user doesn't want to quit the form, close the current dialog
              },
            ),
            FlatButton(
              child: Text("YES"),
              onPressed: () {
                int count = 0;
                Navigator.of(context).popUntil((_) =>
                    count++ >=
                    2); // if the user click yes to quit, close the dialog and the PostComposer screen
              },
            )
          ]);
    } else {
      Navigator.pop(context);
    }
    return true;
  }

  Future<List<String>> uploadFiles(List<File> _images) async {
    // function used to upload the image file in our Firebase Storage database
    var _imagesURL = List<String>();
    await Future.forEach(_images, (element) async {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('post_images/img_' +
              DateTime.now()
                  .toString()) // create a file in the folder "post_images" on the server with the format name "img_YYYYY-MM-DD HH-MM-SS.mmmmmm".
          .putFile(element); // upload the image file
      await uploadTask.then((value) async {
        // wait for the upload task to finish
        await value.ref.getDownloadURL().then((url) {
          // add the image's URL into the list
          _imagesURL.add(url);
        });
      }).catchError((onError) {
        // handle error while uploading the image
        return Future.error(onError);
      });
    });
    return _imagesURL; // return the URLs of the images uploaded
  }

  void _submitPost() async {
    // function to store data into the "post" collection on firestore
    _showProgressDialog(
        context); // display a circular progress indicator when upload starts
    await uploadFiles(images).then((value) async {
      // start image upload process
      await FirebaseFirestore.instance.collection("post").add({
        // wait for image upload process to finish and store data into the database
        'title': _titleController.text,
        // put title's value in the corresponding field of our Firestore
        'text': _textController.text,
        // put text's value in the corresponding field of our Firestore
        'images': value,
        // put image's URLs from the uploadFiles function into the images field of our Firestore
      }).then((value) {
        setState(() {
          // quit the PostComposer screen if the upload proceeded without errors
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }).timeout(Duration(seconds: 10), onTimeout: () {
        // set a timeout of 10 seconds, after this delay the upload ends, put in cache and will resume when the connection is better
        Navigator.pop(context);
      }).catchError((onError) {
        // if an error occures while uploading data into the database
        print(onError);
        _showAlertDialog(context, "Upload Error",
            "An error occured while uploading data to the database, please try again");
      });
    }).catchError((onError) {
      // if an error occures while uploading images files
      print(onError);
      _showAlertDialog(context, "Image Upload Error",
          "An error occured while uploading images, please try again");
    });
  }

  _showProgressDialog(BuildContext context) {
    // display the circular progress indicator dialog while uploading
    AlertDialog alert = AlertDialog(
        content: Container(
            alignment: Alignment.center,
            height: 100,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Uploading...",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              )
            ])));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
