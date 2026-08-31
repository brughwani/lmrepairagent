import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

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
  late TextEditingController _villageSearchController;


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
        villages = villageList.map((village) => village.toString().toUpperCase()).toList();
        villages.sort((a, b) => a.compareTo(b)); // Sort villages alphabetically

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
    required String? visitDate,
    required String? visitTime,
     String? solveDate,
    String? tat,
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
          'Visit date': visitDate,
          'Solve date': solveDate,
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
    name = TextEditingController(text: (widget.complaint['Customer name'] ?? widget.complaint['Customer Name'] ?? widget.complaint['customerName'] ?? '').toString());
    mobile = TextEditingController(text: (widget.complaint['Phone'] ?? widget.complaint['phone'] ?? '').toString());
    address = TextEditingController(text: (widget.complaint['address'] ?? widget.complaint['Address'] ?? '').toString());
    city = TextEditingController(text: (widget.complaint['City'] ?? widget.complaint['city'] ?? '').toString());
    pincode = TextEditingController(text: (widget.complaint['Pincode'] ?? widget.complaint['pincode'] ?? '').toString());
    cmpno = TextEditingController(text: (widget.complaint['Complaint no.'] ?? widget.complaint['cmpno'] ?? '').toString());
    complaindate = TextEditingController(text: (widget.complaint['date of complain'] ?? widget.complaint['Date of complain'] ?? '').toString());
    product = TextEditingController(text: (widget.complaint['Product name'] ?? widget.complaint['Product Name'] ?? widget.complaint['product'] ?? '').toString());
    category = TextEditingController(text: (widget.complaint['Category'] ?? widget.complaint['category'] ?? '').toString());
    brand = TextEditingController(text: (widget.complaint['Brand'] ?? widget.complaint['brand'] ?? '').toString());
    purchasedate = TextEditingController(text: (widget.complaint['Purchase date'] ?? widget.complaint['Purchase Date'] ?? '').toString());
    expirydate = TextEditingController(text: (widget.complaint['warranty expiry date'] ?? widget.complaint['Warranty expiry date'] ?? '').toString());
    complain = TextEditingController(text: (widget.complaint['Problem'] ?? widget.complaint['problem'] ?? '').toString());

    dealerName = (widget.complaint['Dealer name'] ?? widget.complaint['Dealer Name'] ?? widget.complaint['dealer'] ?? '')?.toString();
    if (dealerName != null && dealerName!.isEmpty) dealerName = null;

    villageName = (widget.complaint['Village'] ?? widget.complaint['village'] ?? widget.complaint['Location'] ?? '')?.toString();
    if (villageName != null && villageName!.isEmpty) villageName = null;

    _villageSearchController = TextEditingController(text: villageName ?? '');
    visitDate = TextEditingController(text: (widget.complaint['Visit date'] ?? widget.complaint['Visit Date'] ?? '').toString());
    visitTime = TextEditingController(text: (widget.complaint['Visit time'] ?? widget.complaint['Visit Time'] ?? '').toString());
    solveDate = TextEditingController(text: (widget.complaint['Solve date'] ?? widget.complaint['Solve Date'] ?? '').toString());

    final rawStatus = (widget.complaint['Status'] ?? widget.complaint['status'] ?? 'Open').toString().trim();
    if (rawStatus.toLowerCase() == 'open' || rawStatus.toLowerCase() == 'pending' || rawStatus.toLowerCase() == 'assigned' || rawStatus.toLowerCase() == 'allotted' || rawStatus.isEmpty) {
      status = 'Open';
    } else if (rawStatus.toLowerCase() == 'in progress' || rawStatus.toLowerCase() == 'inprogress' || rawStatus.toLowerCase() == 'in-progress') {
      status = 'In Progress';
    } else if (rawStatus.toLowerCase() == 'resolved' || rawStatus.toLowerCase() == 'solved' || rawStatus.toLowerCase() == 'closed') {
      status = 'Resolved';
    } else {
      status = 'Open';
    }

    substatus = TextEditingController(text: (widget.complaint['Substatus'] ?? widget.complaint['substatus'] ?? '').toString());

    final rawBrand = (widget.complaint['Brand'] ?? widget.complaint['brand'] ?? '')?.toString();
    selectedBrand = (rawBrand != null && rawBrand.isNotEmpty) ? rawBrand : null;

    final rawCategory = (widget.complaint['Category'] ?? widget.complaint['category'] ?? '')?.toString();
    selectedCategory = (rawCategory != null && rawCategory.isNotEmpty) ? rawCategory : null;

    final rawProduct = (widget.complaint['Product name'] ?? widget.complaint['Product Name'] ?? widget.complaint['product'] ?? '')?.toString();
    _selectedValue = (rawProduct != null && rawProduct.isNotEmpty) ? rawProduct : null;

    final rawWarranty = (widget.complaint['Warranty status'] ?? widget.complaint['warranty'] ?? 'In Warranty').toString();
    selectedWarranty = (rawWarranty.toLowerCase().contains('out')) ? 'Out of Warranty' : 'In Warranty';

    fetchbrands(widget.token);

    fetchVillages().then((_) {
      if (villageName != null && villageName!.isNotEmpty) {
        fetchDealers(villageName!);
      }
    });

    if (selectedBrand != null && selectedBrand!.isNotEmpty) {
      fetchCategories(selectedBrand!).then((_) {
        if (selectedCategory != null && selectedCategory!.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 100), () {
            fetchProductsForCategory(selectedBrand!, selectedCategory!);
          });
        }
      });
    }

    if (widget.complaint['Visit time'] != null) {
      try {
        final timeStr = widget.complaint['Visit time'].toString();
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          selectedVisitTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1].split(' ')[0]),
          );
        }
      } catch (e) {
        selectedVisitTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure dropdown options contain pre-selected values so Flutter never crashes
    if (selectedBrand != null && selectedBrand!.isNotEmpty && !brands.contains(selectedBrand)) {
      brands.insert(0, selectedBrand!);
    }
    if (selectedCategory != null && selectedCategory!.isNotEmpty && !categories.contains(selectedCategory)) {
      categories.insert(0, selectedCategory!);
    }
    if (_selectedValue != null && _selectedValue!.isNotEmpty && !products.contains(_selectedValue)) {
      products.insert(0, _selectedValue!);
    }
    if (dealerName != null && dealerName!.isNotEmpty && !dealers.contains(dealerName)) {
      dealers.insert(0, dealerName!);
    }
    if (villageName != null && villageName!.isNotEmpty && !villages.contains(villageName!.toUpperCase())) {
      villages.insert(0, villageName!.toUpperCase());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Service Form")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    label: Text("Customer Name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mobile,
                  decoration: const InputDecoration(
                    label: Text("Phone"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: address,
                  decoration: const InputDecoration(
                    label: Text("address"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: city,
                  decoration: const InputDecoration(
                    label: Text("City"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: complaindate,
                  decoration: const InputDecoration(
                    label: Text("Date of Complain"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: (selectedBrand != null && brands.contains(selectedBrand)) ? selectedBrand : null,
                  hint: const Text("Select Brand"),
                  decoration: const InputDecoration(
                    labelText: "Brand",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: brands.map<DropdownMenuItem<String>>((String brnd) {
                    return DropdownMenuItem<String>(
                      value: brnd,
                      child: Text(
                        brnd,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newbrnd) {
                    setState(() {
                      selectedBrand = newbrnd;
                      selectedCategory = null;
                      _selectedValue = null;
                      categories.clear();
                      products.clear();
                      if (newbrnd != null) {
                        fetchCategories(newbrnd);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: (selectedCategory != null && categories.contains(selectedCategory)) ? selectedCategory : null,
                  hint: const Text("Select Category"),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      _selectedValue = null;
                      products.clear();
                    });
                    if (newValue != null && selectedBrand != null) {
                      fetchProductsForCategory(selectedBrand!, newValue);
                    }
                  },
                  items: categories.map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: (_selectedValue != null && products.contains(_selectedValue)) ? _selectedValue : null,
                  hint: const Text("Select Product"),
                  decoration: const InputDecoration(
                    labelText: "Product",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: products.map<DropdownMenuItem<String>>((String prod) {
                    return DropdownMenuItem<String>(
                      value: prod,
                      child: Text(
                        prod,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (productselected) {
                    setState(() {
                      _selectedValue = productselected;
                    });
                  },
                ),
                const SizedBox(height: 16),

                DropdownMenu<String>(
                  controller: _villageSearchController,
                  initialSelection: villageName,
                  label: const Text('Village'),
                  hintText: 'Select or search village',
                  enableFilter: true,
                  dropdownMenuEntries: villages.map<DropdownMenuEntry<String>>((String v) {
                    return DropdownMenuEntry<String>(
                      value: v,
                      label: v,
                    );
                  }).toList(),
                  onSelected: (String? newVillage) {
                    setState(() {
                      villageName = newVillage;
                      dealerName = null;
                      dealers.clear();
                    });
                    if (newVillage != null) {
                      fetchDealers(newVillage);
                    }
                  },
                  width: MediaQuery.of(context).size.width - 32,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: (dealerName != null && dealers.contains(dealerName)) ? dealerName : null,
                  hint: const Text("Select Dealer"),
                  decoration: const InputDecoration(
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
                const SizedBox(height: 16),

                TextFormField(
                  controller: visitTime,
                  decoration: const InputDecoration(
                    labelText: "Visit Time",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: visitDate,
                  decoration: const InputDecoration(
                    labelText: "Visit Date",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: solveDate,
                  decoration: const InputDecoration(
                    labelText: "Solve Date",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: purchasedate,
                  decoration: const InputDecoration(
                    label: Text("Purchase Date"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: expirydate,
                  decoration: const InputDecoration(
                    label: Text("Warranty Expiry Date"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: complain,
                  decoration: const InputDecoration(
                    label: Text("Complain"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: (selectedWarranty == 'In Warranty' || selectedWarranty == 'Out of Warranty')
                      ? selectedWarranty
                      : 'In Warranty',
                  hint: const Text("Select Warranty Status"),
                  decoration: const InputDecoration(
                    labelText: "Warranty Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
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
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: statuses.contains(status) ? status : 'Open',
                  hint: const Text("Select Status"),
                  decoration: const InputDecoration(
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
                      status = newValue ?? 'Open';

                      if (newValue == 'In Progress' && visitDate.text.isEmpty) {
                        final now = DateTime.now();
                        visitDate.text = now.toIso8601String().split('T')[0];
                        final tod = TimeOfDay.now();
                        final hour = tod.hour.toString().padLeft(2, '0');
                        final minute = tod.minute.toString().padLeft(2, '0');
                        visitTime.text = '$hour:$minute';
                      } else if (newValue == 'Resolved' && solveDate.text.isEmpty) {
                        final now = DateTime.now();
                        solveDate.text = now.toIso8601String().split('T')[0];
                        if (complaindate.text.isNotEmpty) {
                          try {
                            tat = DateTime.now().difference(DateTime.parse(complaindate.text)).inDays.toString();
                          } catch (_) {
                            tat = '0';
                          }
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: substatus,
                  decoration: const InputDecoration(
                    label: Text("Substatus"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    final complaintId = widget.complaint['id'] ?? widget.complaint['_id'];
                    if (complaintId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot update: complaint ID missing')),
                      );
                      return;
                    }
                    updateRecord(
                      Name: name.text,
                      Phone: mobile.text,
                      Address: address.text,
                      City: city.text,
                      Pincode: pincode.text,
                      ComplainDate: complaindate.text,
                      Product: _selectedValue ?? product.text,
                      Category: selectedCategory ?? category.text,
                      Brand: selectedBrand ?? brand.text,
                      visitDate: visitDate.text,
                      solveDate: solveDate.text,
                      visitTime: visitTime.text,
                      tat: tat,
                      PurchaseDate: purchasedate.text,
                      ExpiryDate: expirydate.text,
                      Complain: complain.text,
                      DealerName: dealerName,
                      VillageName: villageName,
                      Warranty: selectedWarranty ?? 'In Warranty',
                      Status: status,
                      Substatus: substatus.text,
                    ).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Complaint updated successfully')),
                      );
                      Navigator.pop(context, true);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update complaint: $error')),
                      );
                    });
                  },
                  child: const Text("Submit"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
