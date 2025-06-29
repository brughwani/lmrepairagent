import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KarigarApp extends StatefulWidget {
  KarigarApp({super.key, required this.complaint,required this.title, required this.token});
  String title;
  String token;
  final Map<String,dynamic> complaint;

  @override
  State<KarigarApp> createState() => _KarigarAppState();
}


class _KarigarAppState extends State<KarigarApp> {

  late TextEditingController name;
  late TextEditingController mobile;
  late TextEditingController address;
  late TextEditingController city;
  late TextEditingController pincode;
  late TextEditingController cmpno;
  late TextEditingController complaindate;
  late TextEditingController product;
  late TextEditingController category;
  late TextEditingController brand;
  late TextEditingController purchasedate;
  late TextEditingController expirydate;
  late TextEditingController complain;
  late TextEditingController dealer;
  late TextEditingController village;
  //late TextEditingController warranty;
  // late TextEditingController status;
   late TextEditingController substatus;

  late TextEditingController visitDate;
  late TextEditingController visitTime;
  late TextEditingController solveDate;
  late String tat = "";
  TimeOfDay? selectedVisitTime;
  List<String> products=[];
  List<String> categories = [];
  List<String> brands=[];
  List<String> dealers=[];
  List<String> villages=[];
  List<String> statuses=['Open', 'In Progress', 'Resolved'];

  String? dealerName;
  String? villageName;
  String status = ""; // Default value for status

  String? selectedCategory;
  String? selectedBrand;
  String? selectedWarranty = "In Warranty"; // Default value for warranty status
//  String? request;
  String? _selectedValue;
  //TextEditingController name=TextEditingController();
  // TextEditingController mobile=TextEditingController();
  // TextEditingController address=TextEditingController();
  // TextEditingController city=TextEditingController();
  // TextEditingController pincode=TextEditingController();
  // TextEditingController cmpno=TextEditingController();
  // TextEditingController complaindate=TextEditingController();
  // TextEditingController product=TextEditingController();
  // TextEditingController category=TextEditingController();
  // TextEditingController brand=TextEditingController();
  // TextEditingController purchasedate=TextEditingController();
  // TextEditingController expirydate=TextEditingController();
  // TextEditingController complain=TextEditingController();
  // TextEditingController dealer=TextEditingController();
  // TextEditingController village=TextEditingController();
  // TextEditingController warranty=TextEditingController();
  // TextEditingController status=TextEditingController();
  // TextEditingController substatus=TextEditingController();

  Future<void> fetchbrands(String token) async
  {
    final response= await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':'Bearer ${widget.token}',
      },
    );
    if(response.statusCode==200)
    {
      final List<dynamic> brandlist=jsonDecode(response.body);
      setState(() {
        brands=brandlist.map((b)=>b.toString()).toList();
      });

//print(response.body);
    }
    else
    {
      throw Exception('Failed to load brands');
      // print(response.statusCode);
    }
  }

  Future<void> fetchVillages() async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> villageList = json.decode(response.body);
      setState(() {
        villages = villageList.map((village) => village.toString()).toList();
      });
    } else {
      throw Exception('Failed to load villages');
    }
  }
  Future<void> updateRecord({
required String Name,
    required  String Phone,
    required String Address,
    required String City,
    required  String Pincode,
    String? Cmpno,
    required  String ComplainDate,
    required String Product,
    required String Category,
    required String Brand,
    required String PurchaseDate,
    required String ExpiryDate,
    required String Complain,
    required  String? DealerName,
    required String? VillageName,
    required String Warranty,
    required String Status,
    required String Substatus,
  }) async {
    final url = Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}', // If your API uses auth middleware
      },
      body: jsonEncode({
        'id': widget.complaint['id'],
        'fields': {
          'Customer name':Name,
          'Phone': Phone,
          'address': Address,
          'City': City,
          'Pincode': Pincode,
          // 'Complaint no.': cmpno.text,
          'date of complain': ComplainDate,
          'Product name': Product,
          'Category': Category,
          'Brand': Brand,
          'Visit date': visitDate.text,
          'Solve date': solveDate.text,
          'TAT': tat,
          'Purchase date': PurchaseDate,
          'warranty expiry date': ExpiryDate,
          'Problem': Complain,
          'Dealer name': DealerName ?? '', // Add null check
          'Village': VillageName ?? '',
          'Warranty status': Warranty,
          // 'Warranty status': warranty.text, // Assuming you have a warranty field
          'Status': Status,
          'Substatus': Substatus,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Update successful: ${response.body}');
    } else {
      print('Update failed: ${response.statusCode} ${response.body}');
    }
  }
  Future<void> fetchDealers(String village) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$village'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> dealerList = json.decode(response.body);
      print(dealerList);
      setState(() {
        dealers = dealerList.map((dealer) => dealer['Dealer name'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load dealers');
    }
  }

  Future<void> fetchCategories(String Brand) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> categoryList = json.decode(response.body);
      setState(() {
        categories = categoryList.map((category) => category.toString()).toList();

      });
      // print(categories);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchProductsForCategory(String Brand,String categoryId) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$Brand&category=$categoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':'Bearer ${widget.token}',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> productList = json.decode(response.body);
      setState(() {
        products = productList.map((e) => e['name'].toString()).toList();
        if (products.contains(widget.complaint['Product name'])) {
          _selectedValue = widget.complaint['Product name'];
        } else {
          _selectedValue = null;
        }
        // _selectedValue = null; // Reset product selection when category changes
      });
    } else {
      throw Exception('Failed to load products');
    }
  }
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.complaint['Customer name']);
    mobile = TextEditingController(text: widget.complaint['Phone']);
    address = TextEditingController(text: widget.complaint['address']);
    city = TextEditingController(text: widget.complaint['City']);
    pincode = TextEditingController();
    cmpno = TextEditingController();
    complaindate = TextEditingController(text: widget.complaint['date of complain']);
    product = TextEditingController(text: widget.complaint['Product name']);
    category = TextEditingController(text: widget.complaint['Category']);
    brand = TextEditingController(text: widget.complaint['Brand']);
    purchasedate = TextEditingController(text: widget.complaint['Purchase date']);
    expirydate = TextEditingController(text: widget.complaint['warranty expiry date']);
    complain = TextEditingController(text:widget.complaint['Problem']);
    // dealer = TextEditingController();
    // village = TextEditingController();
    //warranty = TextEditingController();
    dealerName = widget.complaint['Dealer name'];
    villageName = widget.complaint['Village'];
    visitDate = TextEditingController(text: widget.complaint['Visit date']);
    visitTime = TextEditingController(text: widget.complaint['Visit time']);
    solveDate = TextEditingController(text: widget.complaint['Solve date']);


    status = widget.complaint['Status'];
    substatus = TextEditingController();

    selectedBrand = widget.complaint['Brand'];
    selectedCategory = widget.complaint['Category'];
    _selectedValue = widget.complaint['Product name'];

    fetchbrands(widget.token);


    //fetchVillages();
    // if (selectedBrand != null) {
    //
    //   fetchCategories(selectedBrand!);
    //   fetchProductsForCategory(selectedBrand!, selectedCategory!);
    // }
    fetchVillages().then((_) {
      // If we have a village, fetch its dealers
      if (villageName != null) {
        fetchDealers(villageName!);
      }
    });
    if (selectedBrand != null && selectedBrand!.isNotEmpty) {
      fetchCategories(selectedBrand!).then((_) {
        if (selectedCategory != null && selectedCategory!.isNotEmpty) {
          // Delay the product fetch to ensure categories are loaded first
          Future.delayed(Duration(milliseconds: 100), () {
            fetchProductsForCategory(selectedBrand!, selectedCategory!);
          });
        }
      });
    }

    if (widget.complaint['Visit time'] != null) {
      try {
        final timeStr = widget.complaint['Visit time'];
        final parts = timeStr.split(':');
        selectedVisitTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1])
        );
        visitTime.text = selectedVisitTime!.format(context);
      } catch (e) {
        selectedVisitTime = null;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    print(widget.complaint);
    return Scaffold(
      appBar: AppBar(title: Text("Service Form"),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                TextFormField(
                //  initialValue: widget.complaint['Customer Name'],
                  controller: name,
                  decoration: InputDecoration(
                    label: Text("Customer Name"),
                      border: OutlineInputBorder()
                  ),
                ),
                  SizedBox(
                    height: 16,
                  ),
                TextFormField(

              //    initialValue: widget.complaint['Phone'],
                  controller: mobile,
                  decoration: InputDecoration(
                    label: Text("Phone"),
                      border: OutlineInputBorder()
                  ),

                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
            //      initialValue: widget.complaint['address'],
                  controller: address,
                  decoration: InputDecoration(
                      label: Text("address"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: city,
                  decoration: InputDecoration(
                      //label: Text("Phone"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
             //     initialValue: widget.complaint['date of complain'],
                  controller: complaindate,
                  decoration: InputDecoration(
                      label: Text("Date of Complain"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  value: selectedBrand,
                  hint: Text("Select Brand"),
                  decoration: InputDecoration(
                    labelText: "Brand",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: brands.map<DropdownMenuItem<String>>((String brnd) {
                    return DropdownMenuItem<String>(
                      value: brnd,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          brnd,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newbrnd) {
                    setState(() {
                      selectedBrand = newbrnd;
                      selectedCategory = null; // Reset category
                      _selectedValue = null; // Reset product
                      categories.clear();
                      products.clear();
                      if (newbrnd != null) {
                        print(123);
                        fetchCategories(newbrnd);
                      }
                    });
                  },
                ),
                SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: Text("Select Category"),
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      _selectedValue = null; // Reset product selection only when user manually changes category
                      products.clear();
                    });
                    if (newValue != null && selectedBrand != null) {
                      fetchProductsForCategory(selectedBrand!, newValue);
                    }
                  },
                  items: categories.map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 16,
                ),

                DropdownButtonFormField<String>(
                  value: _selectedValue,
                  hint: Text("Select Product"),
                  decoration: InputDecoration(
                    labelText: "Product",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: products.map<DropdownMenuItem<String>>((String product) {
                    return DropdownMenuItem<String>(
                      value: product,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          product,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (productselected) {
                    setState(() {
                      _selectedValue = productselected;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),

                DropdownButtonFormField<String>(
                  value: villageName,
                  hint: Text("Select Village"),
                  decoration: InputDecoration(
                    labelText: "Village",
                    border: OutlineInputBorder(),
                  ),
                  items: villages.map((String village) {
                    return DropdownMenuItem<String>(
                      value: village,
                      child: Text(village),
                    );
                  }).toList(),
                  onChanged: (String? newVillage) {
                    setState(() {
                      villageName = newVillage;
                      dealerName = null; // Reset dealer selection
                      dealers.clear();
                    });
                    if (newVillage != null) {
                      fetchDealers(newVillage);
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: dealerName,
                  hint: Text("Select Dealer"),
                  decoration: InputDecoration(
                    labelText: "Dealer",
                    border: OutlineInputBorder(),
                  ),
                  items: dealers.map((String dealer) {
                    return DropdownMenuItem<String>(
                      value: dealer,
                      child: Text(dealer),
                    );
                  }).toList(),
                  onChanged: (String? newDealer) {
                    setState(() {
                      dealerName = newDealer;
                    });
                  },
                ),

                // After the visit date field
                TextFormField(
                  controller: visitTime,
                  decoration: InputDecoration(
                    labelText: "Visit Time",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),

                // DropdownButton(
                //   value: selectedCategory,
                //   onChanged: (newValue) {
                //
                //     setState(() {
                //       selectedCategory = newValue as String?;
                //     });
                //     if (newValue != null) {
                //       fetchProductsForCategory(selectedBrand!,newValue); // Fetch products for the selected category
                //     }
                //   },
                //   items: categories.map<DropdownMenuItem<String>>((String category) {
                //     return DropdownMenuItem<String>(
                //       value: category,
                //       child: Text(category),
                //     );
                //   }).toList(),
                //
                // ),
             //    TextFormField(
             // //     initialValue: widget.complaint['Product name'],
             //      controller: product,
             //      decoration: InputDecoration(
             //          label: Text("Product Name"),
             //          border: OutlineInputBorder()
             //      ),
             //    ),
                SizedBox(

                  height: 16,
                ),
          //       TextFormField(
          // //        initialValue: widget.complaint['Category'],
          //         controller: category,
          //         decoration: InputDecoration(
          //             label: Text("Category"),
          //             border: OutlineInputBorder()
          //         ),
          //       ),
                SizedBox(
                  height: 16,
                ),
            //     TextFormField(
            // //      initialValue: widget.complaint['Brand'],
            //       controller: brand,
            //       decoration: InputDecoration(
            //           label: Text("Brand"),
            //           border: OutlineInputBorder()
            //       ),
            //     ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
         //         initialValue: widget.complaint['Purchase date'],
                  controller: purchasedate,
                  decoration: InputDecoration(
                      label: Text("Purchase Date"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
          //        initialValue: widget.complaint['warranty expiry date'],
                  controller:expirydate,
                  decoration: InputDecoration(
                      label: Text("Warranty Expiry Date"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: complain,
                  decoration: InputDecoration(
                      label: Text("Complain"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                // TextFormField(
                //   controller:dealer ,
                //   decoration: InputDecoration(
                //       label: Text("Dealer"),
                //       border: OutlineInputBorder()
                //   ),
                // ),
                // SizedBox(
                //   height: 16,
                // ),
                // TextFormField(
                //   controller: village,
                //   decoration: InputDecoration(
                //       label: Text("Village"),
                //       border: OutlineInputBorder()
                //   ),
                // ),

                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  value: selectedWarranty,
                  hint: Text("Select Warranty Status"),
                  decoration: InputDecoration(
                    labelText: "Warranty Status",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "In Warranty",
                      child: Text("In Warranty"),
                    ),
                    DropdownMenuItem(
                      value: "Out of Warranty",
                      child: Text("Out of Warranty"),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWarranty = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  value: status.isNotEmpty ? status : null,
                  hint: Text("Select Status"),
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: statuses.map((String s) {
                    return DropdownMenuItem<String>(
                      value: s,
                      child: Text(s),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      status= newValue ?? '';
                    });
                  },
                ),
                // DropdownButtonFormField(value:status.text,items:statuses.map((s)=>DropdownMenuItem(value:s,child:Text(s)))) , onChanged:(){}),
           //      TextFormField(
           // //       initialValue: widget.complaint['Status'],
           //        controller: status,
           //        decoration: InputDecoration(
           //            label: Text("Status"),
           //            border: OutlineInputBorder()
           //        ),
           //      ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: substatus,
                  decoration: InputDecoration(
                    label: Text("Substatus"),
                      border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                    // You can send the data to your backend or perform any action you need
                    updateRecord(Name:name.text,Phone:mobile.text,Address:address.text,City: city.text,Pincode: pincode.text,ComplainDate: complaindate.text,Product:_selectedValue!,Category: selectedCategory!,Brand: selectedBrand!,PurchaseDate:purchasedate.text,ExpiryDate: expirydate.text,Complain: complain.text,DealerName: dealerName,VillageName: villageName,Warranty: selectedWarranty!,Status: status,Substatus: substatus.text).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Complaint updated successfully')),
                      );
                      Navigator.pop(context,true);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update complaint: $error')),
                      );

                    });
                  },
                  child: Text("Submit"),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
