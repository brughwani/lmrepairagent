import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:lmrepaireagent/offline_service.dart';

String _parseDate(dynamic date) {
  if (date == null) return '';
  if (date is DateTime) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  if (date is Map) {
    final seconds = date['_seconds'] ?? date['seconds'] ?? date['_seconds_'];
    if (seconds != null && seconds is num) {
      final dt = DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    }
  }
  final str = date.toString().trim();
  if (str.isEmpty) return '';

  final secMatch = RegExp(r'_?seconds:?\s*(\d+)').firstMatch(str);
  if (secMatch != null) {
    final sec = int.tryParse(secMatch.group(1)!);
    if (sec != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    }
  }

  if (str.contains('T')) {
    return str.split('T')[0];
  }
  return str;
}

class KarigarApp extends StatefulWidget {
  final String title;
  final String token;
  final Map<String, dynamic> complaint;

  const KarigarApp({
    super.key,
    required this.complaint,
    required this.title,
    required this.token,
  });

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
  late TextEditingController substatus;
  late TextEditingController _villageSearchController;

  late TextEditingController visitDate;
  late TextEditingController visitTime;
  late TextEditingController solveDate;
  late String tat = "";
  TimeOfDay? selectedVisitTime;

  List<String> products = [];
  List<String> categories = [];
  List<String> brands = [];
  List<String> dealers = [];
  List<String> villages = [];
  final List<String> statuses = ['Open', 'In Progress', 'Resolved'];

  String? dealerName;
  String? villageName;
  String status = "Open";
  String? selectedCategory;
  String? selectedBrand;
  String? selectedWarranty = "In Warranty";
  String? _selectedValue;
  String allottedTo = "";
  String requestType = "";

  bool isSubmitting = false;

  Future<void> fetchbrands(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> brandlist = jsonDecode(response.body);
        final fetched = brandlist.map((b) => b.toString()).toList();
        await OfflineService.saveBrands(fetched);
        setState(() { brands = fetched; });
      }
    } catch (e) {
      // Offline fallback
      final cached = await OfflineService.loadBrands();
      if (cached.isNotEmpty) setState(() { brands = cached; });
      print('Failed to load brands (using cache): $e');
    }
  }

  Future<void> fetchVillages() async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> villageList = json.decode(response.body);
        final fetched = villageList
            .map((village) => village.toString().toUpperCase())
            .toList()
          ..sort((a, b) => a.compareTo(b));
        await OfflineService.saveVillages(fetched);
        setState(() { villages = fetched; });
      }
    } catch (e) {
      // Offline fallback
      final cached = await OfflineService.loadVillages();
      if (cached.isNotEmpty) setState(() { villages = cached; });
      print('Failed to load villages (using cache): $e');
    }
  }

  Future<void> fetchDealers(String village) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$village'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dealerList = json.decode(response.body);
        final fetched =
            dealerList.map((dealer) => dealer['Dealer name'].toString()).toList();
        await OfflineService.saveDealers(village, fetched);
        setState(() { dealers = fetched; });
      }
    } catch (e) {
      // Offline fallback
      final cached = await OfflineService.loadDealers(village);
      if (cached.isNotEmpty) setState(() { dealers = cached; });
      print('Failed to load dealers (using cache): $e');
    }
  }

  Future<void> fetchCategories(String brandName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$brandName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categoryList = json.decode(response.body);
        final fetched = categoryList.map((c) => c.toString()).toList();
        await OfflineService.saveCategories(brandName, fetched);
        setState(() { categories = fetched; });
      }
    } catch (e) {
      // Offline fallback
      final cached = await OfflineService.loadCategories(brandName);
      if (cached.isNotEmpty) setState(() { categories = cached; });
      print('Failed to load categories (using cache): $e');
    }
  }

  Future<void> fetchProductsForCategory(
      String brandName, String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$brandName&category=$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productList = json.decode(response.body);
        final fetched =
            productList.map((e) => e['name'].toString()).toList();
        await OfflineService.saveProducts(brandName, categoryId, fetched);
        setState(() {
          products = fetched;
          final rawProd = (widget.complaint['Product name'] ??
                  widget.complaint['Product Name'] ??
                  widget.complaint['product'] ??
                  '')
              .toString()
              .trim();
          if (products.contains(rawProd)) {
            _selectedValue = rawProd;
          }
        });
      }
    } catch (e) {
      // Offline fallback
      final cached =
          await OfflineService.loadProducts(brandName, categoryId);
      if (cached.isNotEmpty) setState(() { products = cached; });
      print('Failed to load products (using cache): $e');
    }
  }

  Future<void> updateRecord({
    required String Name,
    required String Phone,
    required String Address,
    required String City,
    required String Pincode,
    required String Cmpno,
    required String ComplainDate,
    required String Product,
    required String Category,
    required String Brand,
    required String PurchaseDate,
    required String ExpiryDate,
    required String Complain,
    required String? DealerName,
    required String? VillageName,
    required String Warranty,
    required String Status,
    required String Substatus,
    required String? visitDate,
    required String? visitTime,
    String? solveDate,
    String? tat,
  }) async {
    final complaintId = widget.complaint['id'] ?? widget.complaint['_id'];
    if (complaintId == null) {
      throw Exception('Complaint ID is missing');
    }

    final fields = {
      'Customer name': Name,
      'Phone': Phone,
      'address': Address,
      'City': City,
      'city': City,
      'Pincode': Pincode,
      'pincode': Pincode,
      'Complaint no.': Cmpno,
      'Complain number': Cmpno,
      'date of complain': ComplainDate,
      'Product name': Product,
      'Category': Category,
      'Brand': Brand,
      'Visit date': visitDate ?? '',
      'Visit time': visitTime ?? '',
      'Solve date': solveDate ?? '',
      'TAT': tat ?? '',
      'Purchase date': PurchaseDate,
      'warranty expiry date': ExpiryDate,
      'Problem': Complain,
      'Complain/Remark': Complain,
      'Dealer name': DealerName ?? '',
      'Village': VillageName ?? '',
      'Warranty status': Warranty,
      'Status': Status,
      'Substatus': Substatus,
    };

    // Check connectivity before attempting network call
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline =
        connectivity.every((r) => r == ConnectivityResult.none);

    if (isOffline) {
      // Queue the update for later sync
      await OfflineService.enqueuePendingUpdate({
        'id': complaintId,
        'fields': fields,
        'token': widget.token,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '📶 No internet — changes saved locally and will sync automatically when you\'re back online.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return; // Treat as success — don't throw
    }

    // Online — send immediately
    final url =
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'id': complaintId,
        'fields': fields,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();

    final c = widget.complaint;

    // Complaint Number
    cmpno = TextEditingController(
      text: (c['Complain number'] ??
              c['Complaint no.'] ??
              c['cmpno'] ??
              c['complainNumber'] ??
              '')
          .toString()
          .trim(),
    );

    // Customer Name
    name = TextEditingController(
      text: (c['Customer name'] ??
              c['Customer Name'] ??
              c['customerName'] ??
              c['name'] ??
              '')
          .toString()
          .trim(),
    );

    // Phone
    mobile = TextEditingController(
      text: (c['Phone'] ?? c['phone'] ?? c['Mobile'] ?? c['mobile'] ?? '')
          .toString()
          .trim(),
    );

    // Address
    address = TextEditingController(
      text: (c['address'] ?? c['Address'] ?? '').toString().trim(),
    );

    // City
    city = TextEditingController(
      text: (c['city'] ?? c['City'] ?? '').toString().trim(),
    );

    // Pincode
    pincode = TextEditingController(
      text: (c['pincode'] ?? c['Pincode'] ?? '').toString().trim(),
    );

    // Complaint Date
    complaindate = TextEditingController(
      text: _parseDate(c['date of complain'] ?? c['Date of complain'] ?? c['complainDate']),
    );

    // Product, Category, Brand
    product = TextEditingController(
      text: (c['Product name'] ?? c['Product Name'] ?? c['product'] ?? '')
          .toString()
          .trim(),
    );
    category = TextEditingController(
      text: (c['Category'] ?? c['category'] ?? '').toString().trim(),
    );
    brand = TextEditingController(
      text: (c['Brand'] ?? c['brand'] ?? '').toString().trim(),
    );

    // Purchase Date & Expiry Date
    purchasedate = TextEditingController(
      text: _parseDate(c['Purchase date'] ?? c['Purchase Date'] ?? c['purchaseDate']),
    );
    expirydate = TextEditingController(
      text: _parseDate(c['warranty expiry date'] ?? c['Warranty expiry date'] ?? c['warrantyExpiryDate']),
    );

    // Problem / Complain / Remark
    complain = TextEditingController(
      text: (c['Complain/Remark'] ??
              c['Problem'] ??
              c['problem'] ??
              c['complain'] ??
              c['remark'] ??
              '')
          .toString()
          .trim(),
    );

    // Request metadata
    allottedTo = (c['allotted to'] ?? c['allottedTo'] ?? c['technician'] ?? '').toString().trim();
    requestType = (c['Request Type'] ?? c['requestType'] ?? 'Complain').toString().trim();

    // Dealer & Village
    dealerName = (c['Dealer name'] ?? c['Dealer Name'] ?? c['dealer'])?.toString().trim();
    if (dealerName != null && dealerName!.isEmpty) dealerName = null;

    villageName = (c['Village'] ?? c['village'] ?? c['Location'])?.toString().trim();
    if (villageName != null && villageName!.isEmpty) villageName = null;

    _villageSearchController = TextEditingController(text: villageName ?? '');

    // Visit and Solve Dates
    visitDate = TextEditingController(
      text: _parseDate(c['Visit date'] ?? c['Visit Date']),
    );
    visitTime = TextEditingController(
      text: (c['Visit time'] ?? c['Visit Time'] ?? '').toString().trim(),
    );
    solveDate = TextEditingController(
      text: _parseDate(c['Solve date'] ?? c['Solve Date']),
    );

    // Status
    final rawStatus = (c['Status'] ?? c['status'] ?? 'Open').toString().trim();
    if (rawStatus.toLowerCase() == 'open' ||
        rawStatus.toLowerCase() == 'pending' ||
        rawStatus.toLowerCase() == 'assigned' ||
        rawStatus.toLowerCase() == 'allotted' ||
        rawStatus.isEmpty) {
      status = 'Open';
    } else if (rawStatus.toLowerCase() == 'in progress' ||
        rawStatus.toLowerCase() == 'inprogress' ||
        rawStatus.toLowerCase() == 'in-progress') {
      status = 'In Progress';
    } else if (rawStatus.toLowerCase() == 'resolved' ||
        rawStatus.toLowerCase() == 'solved' ||
        rawStatus.toLowerCase() == 'closed') {
      status = 'Resolved';
    } else {
      status = 'Open';
    }

    substatus = TextEditingController(
      text: (c['Substatus'] ?? c['substatus'] ?? '').toString().trim(),
    );

    final rawBrand = (c['Brand'] ?? c['brand'])?.toString().trim();
    selectedBrand = (rawBrand != null && rawBrand.isNotEmpty) ? rawBrand : null;

    final rawCategory = (c['Category'] ?? c['category'])?.toString().trim();
    selectedCategory = (rawCategory != null && rawCategory.isNotEmpty) ? rawCategory : null;

    final rawProduct = (c['Product name'] ?? c['Product Name'] ?? c['product'])?.toString().trim();
    _selectedValue = (rawProduct != null && rawProduct.isNotEmpty) ? rawProduct : null;

    final rawWarranty = (c['Warranty status'] ?? c['warranty'] ?? 'In Warranty').toString();
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

    if (c['Visit time'] != null) {
      try {
        final timeStr = c['Visit time'].toString();
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          selectedVisitTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1].split(' ')[0]),
          );
        }
      } catch (_) {
        selectedVisitTime = null;
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text("Service Form"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.blueGrey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cmpno.text.isNotEmpty ? 'Complaint #${cmpno.text}' : 'Complaint Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              requestType.isNotEmpty ? requestType : 'Complain',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (allottedTo.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Allotted to: $allottedTo',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Section 1: Customer Information
              _buildSectionHeader("Customer Information", Icons.person_outline),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: "Customer Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: address,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: city,
                              decoration: const InputDecoration(
                                labelText: "City",
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: pincode,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Pincode",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownMenu<String>(
                        controller: _villageSearchController,
                        initialSelection: villageName,
                        label: const Text('Village / Area'),
                        hintText: 'Select or search village',
                        enableFilter: true,
                        dropdownMenuEntries: villages.map<DropdownMenuEntry<String>>((String v) {
                          return DropdownMenuEntry<String>(value: v, label: v);
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
                        width: MediaQuery.of(context).size.width - 56,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: (dealerName != null && dealers.contains(dealerName)) ? dealerName : null,
                        hint: const Text("Select Dealer"),
                        decoration: const InputDecoration(
                          labelText: "Dealer",
                          prefixIcon: Icon(Icons.storefront),
                          border: OutlineInputBorder(),
                        ),
                        items: dealers.map((String dealer) {
                          return DropdownMenuItem<String>(
                            value: dealer,
                            child: Text(dealer, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (String? newDealer) {
                          setState(() {
                            dealerName = newDealer;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Section 2: Product & Warranty
              _buildSectionHeader("Product & Warranty Details", Icons.inventory_2_outlined),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
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
                            child: Text(brnd, overflow: TextOverflow.ellipsis),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: (selectedCategory != null && categories.contains(selectedCategory)) ? selectedCategory : null,
                        hint: const Text("Select Category"),
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: categories.map<DropdownMenuItem<String>>((String cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
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
                      ),
                      const SizedBox(height: 12),
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
                            child: Text(prod, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (productselected) {
                          setState(() {
                            _selectedValue = productselected;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: purchasedate,
                              decoration: const InputDecoration(
                                labelText: "Purchase Date",
                                prefixIcon: Icon(Icons.calendar_today, size: 18),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: expirydate,
                              decoration: const InputDecoration(
                                labelText: "Warranty Expiry",
                                prefixIcon: Icon(Icons.event_busy, size: 18),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                    ],
                  ),
                ),
              ),

              // Section 3: Complain & Service Action
              _buildSectionHeader("Complaint & Service Action", Icons.build_circle_outlined),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: complaindate,
                        decoration: const InputDecoration(
                          labelText: "Date of Complaint",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: complain,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Complain / Remark",
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.report_problem_outlined),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: statuses.contains(status) ? status : 'Open',
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
                              visitDate.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                              final tod = TimeOfDay.now();
                              final hour = tod.hour.toString().padLeft(2, '0');
                              final minute = tod.minute.toString().padLeft(2, '0');
                              visitTime.text = '$hour:$minute';
                            } else if (newValue == 'Resolved' && solveDate.text.isEmpty) {
                              final now = DateTime.now();
                              solveDate.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: visitDate,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Visit Date",
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              onTap: () async {
                                final initialDate = visitDate.text.isNotEmpty
                                    ? (DateTime.tryParse(visitDate.text) ?? DateTime.now())
                                    : DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    visitDate.text =
                                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: visitTime,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Visit Time",
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time, size: 18),
                              ),
                              onTap: () async {
                                final initialTime = selectedVisitTime ?? TimeOfDay.now();
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: initialTime,
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedVisitTime = picked;
                                    final hour = picked.hour.toString().padLeft(2, '0');
                                    final minute = picked.minute.toString().padLeft(2, '0');
                                    visitTime.text = '$hour:$minute';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: solveDate,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Solve Date",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                        ),
                        onTap: () async {
                          final initialDate = solveDate.text.isNotEmpty
                              ? (DateTime.tryParse(solveDate.text) ?? DateTime.now())
                              : DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              solveDate.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              if (complaindate.text.isNotEmpty) {
                                try {
                                  tat = picked
                                      .difference(DateTime.parse(complaindate.text))
                                      .inDays
                                      .toString();
                                } catch (_) {
                                  tat = '0';
                                }
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: substatus,
                        decoration: const InputDecoration(
                          labelText: "Substatus",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() {
                            isSubmitting = true;
                          });

                          try {
                            await updateRecord(
                              Name: name.text,
                              Phone: mobile.text,
                              Address: address.text,
                              City: city.text,
                              Pincode: pincode.text,
                              Cmpno: cmpno.text,
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
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Complaint updated successfully')),
                              );
                              Navigator.pop(context, true);
                            }
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update complaint: $error')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                isSubmitting = false;
                              });
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
