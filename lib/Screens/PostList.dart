import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_data_wow/CustomWidget/CustomPageView.dart';


//Screen displaying the different posts as a list
class PostList extends StatefulWidget {
  PostList({Key key}) : super(key: key);

  _PostList createState() => _PostList();
}

class _PostList extends State<PostList> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder( //Retrieve data from firebase and build a set of widgets to display them
        stream: FirebaseFirestore.instance.collection("post").snapshots(), // Get the "post" collection from the Firestore instance
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // show a circular progress indicator if the data still haven't finished loading
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            _showAlertDialog(context, "Error", snapshot.error.toString(), // show an alert dialog if the snapshot retrieved contain an error
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK"))
                ]);
          }
          if (!snapshot.hasData) { // if no data was retrieved, display a text widget in the center of the screen stating that no data was found
            return Center(child: Text("Oops! There is no data yet..."));
          } else { // if data was found display them with a listview
            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 20),
                itemCount: snapshot.data.docs.length, // gives the number of documents found in the "post" collection of our firestore base
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot data = snapshot.data.docs[index]; // get document's data of the specific position (index)
                  if (data.data().values.toString() != '([], , )') { // Check if the data in the entire document is empty, to avoid display errors.
                    return Container(
                        child: Card(
                            elevation: 3,
                            color: Colors.grey[100],
                            child: Column(
                              children: [
                                if (data.get("title") != null && // check if the field "title" is empty, to avoid null container
                                    data.get("title") != "")
                                  Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        data.get("title"),
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )),
                                if (data.get("text") != null && // check if the field "text" is empty, to avoid null container
                                    data.get("text") != "")
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                        data.get("text"),
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        textAlign: TextAlign.justify,
                                      )),
                                if (data.get("images") != null && // only display the CustomPageView only if the field "images" is not empty
                                    data.get("images").toString() != "[]")
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: CustomPageView(
                                          PageView(
                                            children: [
                                              for (String url // for each image url contained in the "images" field, create an Image.network widget placed inside the PageView children
                                                  in data.get('images'))
                                                Image.network(
                                                  url,
                                                )
                                            ],
                                            controller:
                                                PageController(initialPage: 0),
                                          ),
                                          data.get('images').length)),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            )));
                  }
                },
                separatorBuilder: (context, index) => SizedBox( // create a separator between each item of the listview (margin with a height of 20)
                      height: 20,
                    ));
          }
        });
  }

  Future<List<QueryDocumentSnapshot>> fetchPosts() async { // function returning the data fetched from the "post" collection asynchronously
    await FirebaseFirestore.instance
        .collection("post")
        .get()
        .then<dynamic>((QuerySnapshot snapshot) async {
      setState(() {
        return snapshot.docs;
      });
    });
  }

  _showAlertDialog(BuildContext context, String title, String text, // function used to display a custom Alert Dialog
      {List<Widget> actions}) {
    AlertDialog alert =
        AlertDialog(title: Text(title), content: Text(text), actions: actions);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
