import 'package:flutter/material.dart';

class KarigarApp extends StatefulWidget {
  const KarigarApp({super.key});

  @override
  State<KarigarApp> createState() => _KarigarAppState();
}

class _KarigarAppState extends State<KarigarApp> {

  TextEditingController name=TextEditingController();
  TextEditingController mobile=TextEditingController();
  TextEditingController address=TextEditingController();
  TextEditingController city=TextEditingController();
  TextEditingController pincode=TextEditingController();
  TextEditingController cmpno=TextEditingController();
  TextEditingController complaindate=TextEditingController();
  TextEditingController product=TextEditingController();
  TextEditingController category=TextEditingController();
  TextEditingController brand=TextEditingController();
  TextEditingController purchasedate=TextEditingController();
  TextEditingController expirydate=TextEditingController();
  TextEditingController complain=TextEditingController();
  TextEditingController dealer=TextEditingController();
  TextEditingController village=TextEditingController();
  TextEditingController warranty=TextEditingController();
  TextEditingController status=TextEditingController();
  TextEditingController substatus=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Service Form"),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                  SizedBox(
                    height: 16,
                  ),
                TextFormField(
                  controller: mobile,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),

                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: address,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: cmpno,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: complaindate,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: product,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: category,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: brand,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: purchasedate,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller:expirydate,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: complain,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller:dealer ,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: village,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: warranty,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: status,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: substatus,
                  decoration: InputDecoration(
                      border: OutlineInputBorder()
                  ),
                )




              ],
            ),
          ),
        ),
      ),
    );
  }
}
