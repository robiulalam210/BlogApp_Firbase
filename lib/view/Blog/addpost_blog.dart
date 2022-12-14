import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myblog_app/Utlis/utlis.dart';
import 'package:myblog_app/view/adminhome.dart';
import 'package:myblog_app/widget/coustom_button.dart';
import 'package:myblog_app/widget/textformfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_page.dart';

class AddPostBlog extends StatefulWidget {
  const AddPostBlog({Key? key}) : super(key: key);

  @override
  State<AddPostBlog> createState() => _AddPostBlogState();
}

class _AddPostBlogState extends State<AddPostBlog> {

  TextEditingController _controllerTitle = TextEditingController();
  TextEditingController _controllerDiscreption = TextEditingController();
@override
  void initState() {
    // TODO: implement initState
  _controllerTitle.clear();
  _controllerDiscreption.clear();
    super.initState();
  }
  bool loading = false;
  final _key = GlobalKey<FormState>();

  final picker = ImagePicker();
  File? _images;
  XFile? _courseImages;

  Future getImageGallery() async {
    _courseImages = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (_courseImages != null) {
        _images = File(_courseImages!.path);
      } else {
        print("no images selected");
      }
    });
  }

  Future getCamraImage() async {
    _courseImages = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (_courseImages != null) {
        _images = File(_courseImages!.path);
      } else {
        print("no images selected");
      }
    });
  }

  dilogBox(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      getCamraImage();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.camera),
                      title: Text("Camra"),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getImageGallery();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.image),
                      title: Text("Gallery"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  dilogBox(context);
                },
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 1,
                    child: _images != null
                        ? ClipRRect(
                        child: Image.file(
                          _images!.absolute,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ))
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20)),
                      height: 100,
                      width: 100,
                      child: Icon(Icons.camera),
                    )),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Form(
                  key: _key,
                  child: Column(
                    children: [
                      CoustomTextFormField(
                          controller: _controllerTitle,
                          data_return: 'Enter Blog Title',
                          obsText: false,
                          icon: Icon(Icons.title),
                          hintText: 'Enter Title'),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      CoustomTextFormField(
                          controller: _controllerDiscreption,
                          data_return: 'Enter Discreption',
                          obsText: false,
                          icon: Icon(Icons.book_online),
                          hintText: 'Enter Discreption'),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      CoustomMaterialButton(
                          onpressed: () {
                            if (_key.currentState!.validate()) {
                              setState(() {
                                loading = true;
                                sendData();
                              });

                            }
                          }, loading: loading, data: 'Add Data'),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  sendData() async {
    loading = true;
    FirebaseStorage storage = await FirebaseStorage.instance;
    UploadTask uploadTask =
    storage.ref("Course").child(_courseImages!.name).putFile(_images!);
    TaskSnapshot _snapshot = await uploadTask;
    var imgUrl = await _snapshot.ref.getDownloadURL();

    //  UploadTask uploadTask = storage.ref("Course").putFile(_images!);
    // String downloadURL = await (await uploadTask).ref.getDownloadURL();


    await FirebaseFirestore.instance.collection("Course")
        .add(({
      "title": _controllerTitle.text,
      "dis": _controllerDiscreption.text,
      "img": imgUrl
    }))
        .then((value) {
      Utlis().toastMessage("Sucessfull");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace) {
      Utlis().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

}
