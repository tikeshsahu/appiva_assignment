import 'package:appiva_int/pages/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var isLoading = true;
  String userId = '';
  getUserid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    setState(() {
      userId = user!.uid;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5));
    isLoading = false;
    getUserid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('checkIns')
                    .doc(userId)
                    .collection('myCheckIns')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final checkInData = snapshot.data!.docs;
                    return Column(
                      children: [
                        Text(
                          'Check-In Details',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                checkInData[0]['email'],
                                style: TextStyle(fontSize: 23),
                              ),
                              Text(
                                  '(Tap the list for Image and Location Detail)'),
                              ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Login(),
                                      ),
                                    );
                                  },
                                  child: Text('LogOut')),
                              SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.amber,
                                  child: ListView.builder(
                                      itemCount: checkInData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Column(
                                                      children: [
                                                        Text(
                                                            'Latitude - ${checkInData[index]['latitude'].toString()}'),
                                                        Text(
                                                            'Longitude - ${checkInData[index]['longitude'].toString()}')
                                                      ],
                                                    ),
                                                    content: Image.network(
                                                        checkInData[index]
                                                            ['image']),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(14),
                                                          child: const Text(
                                                              "okay"),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: ListTile(
                                                  leading:
                                                      Text(index.toString()),
                                                  trailing: Text(
                                                    checkInData[index]['place'],
                                                  ),
                                                  title: Text(checkInData[index]
                                                          ['timestamp']
                                                      .toString()
                                                      .substring(0, 19))),
                                            ),
                                            Divider(
                                              height: 5,
                                              color: Colors.grey,
                                              thickness: 2,
                                            )
                                          ],
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              )),
            ),
    );
  }
}
