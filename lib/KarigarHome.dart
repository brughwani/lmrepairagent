import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lmrepaireagent/Karigarform.dart';

//import 'package:flutter/material.dart';

class KarigarHome extends StatefulWidget {
  final String token;
  final String name;

  const KarigarHome({Key? key,required this.token,required this.name}) : super(key: key);

  @override
  State<KarigarHome> createState() => _KarigarHomeState();
}

class _KarigarHomeState extends State<KarigarHome> {
  late Future<Map<String, List<dynamic>>> complaintsData;

  @override
  void initState() {
    super.initState();
    complaintsData = fetchComplaints();
  }

  Future<void> _refresh() async {
    setState(() {
      complaintsData = fetchComplaints();
    });
  }

  Future<List<dynamic>> _queryApi(String techName) async {
    if (techName.isEmpty) return [];
    try {
      final url = Uri.https('limsonvercelapi2.vercel.app', '/api/fskarigarapp', {
        'technicianName': techName,
      });
      print('Fetching complaints for technicianName="$techName" via $url');

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      });

      print('Response for "$techName" (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['complaints'] is List) {
            return decoded['complaints'];
          } else if (decoded['data'] is List) {
            return decoded['data'];
          } else if (decoded['records'] is List) {
            return decoded['records'];
          }
        }
      }
    } catch (e) {
      print('Error querying for "$techName": $e');
    }
    return [];
  }

  Future<Map<String, List<dynamic>>> fetchComplaints() async {
    final cleanName = widget.name.trim();
    final namesToTry = <String>{};

    if (cleanName.isNotEmpty) {
      namesToTry.add(cleanName);
      namesToTry.add(cleanName.toLowerCase());
      final titleCase = cleanName[0].toUpperCase() +
          (cleanName.length > 1 ? cleanName.substring(1).toLowerCase() : '');
      namesToTry.add(titleCase);
      namesToTry.add(cleanName.toUpperCase());
    }

    final rawComplaints = <dynamic>[];
    final seenIds = <String>{};

    for (final name in namesToTry) {
      final list = await _queryApi(name);
      for (final item in list) {
        if (item is Map) {
          final id = (item['id'] ?? item['_id'] ?? item['Complaint no.'] ?? item['Customer name'] ?? jsonEncode(item)).toString();
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            rawComplaints.add(item);
          }
        }
      }
    }

    // Categorized map
    final Map<String, List<dynamic>> categorizedComplaints = {
      'pending': [],
      'inProgress': [],
      'solved': [],
    };

    for (var complaint in rawComplaints) {
      if (complaint is! Map) continue;
      final rawStatus = (complaint['Status'] ?? complaint['status'] ?? '').toString().trim().toLowerCase();

      if (rawStatus == 'open' ||
          rawStatus == 'pending' ||
          rawStatus == 'assigned' ||
          rawStatus == 'allotted' ||
          rawStatus == 'new' ||
          rawStatus == '') {
        categorizedComplaints['pending']?.add(complaint);
      } else if (rawStatus == 'in progress' ||
          rawStatus == 'in-progress' ||
          rawStatus == 'inprogress' ||
          rawStatus == 'ongoing' ||
          rawStatus == 'active') {
        categorizedComplaints['inProgress']?.add(complaint);
      } else if (rawStatus == 'resolved' ||
          rawStatus == 'solved' ||
          rawStatus == 'closed' ||
          rawStatus == 'completed' ||
          rawStatus == 'done') {
        categorizedComplaints['solved']?.add(complaint);
      } else {
        // Fallback: don't lose any complaints allotted to the technician
        categorizedComplaints['pending']?.add(complaint);
      }
    }

    return categorizedComplaints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.isNotEmpty ? 'Dashboard (${widget.name})' : 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, List<dynamic>>>(
          future: complaintsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ComplaintContainer(
                      title: 'Pending Complaints',
                      complaints: data['pending']?.length ?? 0,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailsPage(
                              title: "Pending Complaints",
                              complaint: data['pending'] ?? [],
                              token: widget.token,
                              onRefresh: _refresh,
                            ),
                          ),
                        );
                      },
                    ),
                    ComplaintContainer(
                      title: 'In Progress Complaints',
                      complaints: data['inProgress']?.length ?? 0,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailsPage(
                              title: "In Progress Complaints",
                              complaint: data['inProgress'] ?? [],
                              token: widget.token,
                              onRefresh: _refresh,
                            ),
                          ),
                        );
                      },
                    ),
                    ComplaintContainer(
                      title: 'Solved Complaints',
                      complaints: data['solved']?.length ?? 0,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailsPage(
                              title: "Solved Complaints",
                              complaint: data['solved'] ?? [],
                              token: widget.token,
                              onRefresh: _refresh,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}

class ComplaintContainer extends StatelessWidget {
  final String title;
  final int? complaints;
  final Color color;
  final VoidCallback onTap;

  const ComplaintContainer({
    required this.title,
    required this.complaints,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(10),
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${complaints ?? 0} Complaints',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatComplaintDate(dynamic date) {
  if (date == null) return '-';
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
  if (str.isEmpty) return '-';
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

class ComplaintDetailsPage extends StatelessWidget {
  final String title;
  final List<dynamic> complaint;
  final String token;
  final VoidCallback onRefresh;

  const ComplaintDetailsPage({
    required this.title,
    required this.complaint,
    Key? key,
    required this.token,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: complaint.isEmpty
          ? const Center(child: Text('No complaints in this category'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: complaint.length,
              itemBuilder: (context, index) {
                final complaintItem = complaint[index] is Map
                    ? complaint[index]
                    : <String, dynamic>{};

                final customerName = (complaintItem['Customer name'] ??
                        complaintItem['Customer Name'] ??
                        complaintItem['customerName'] ??
                        complaintItem['name'] ??
                        'Customer')
                    .toString()
                    .trim();

                final phone = (complaintItem['Phone'] ??
                        complaintItem['phone'] ??
                        complaintItem['Mobile'] ??
                        '')
                    .toString()
                    .trim();

                final complainNo = (complaintItem['Complain number'] ??
                        complaintItem['Complaint no.'] ??
                        complaintItem['cmpno'] ??
                        '')
                    .toString()
                    .trim();

                final brand = (complaintItem['Brand'] ?? complaintItem['brand'] ?? '-')
                    .toString()
                    .trim();

                final product = (complaintItem['Product name'] ??
                        complaintItem['Product Name'] ??
                        complaintItem['product'] ??
                        '-')
                    .toString()
                    .trim();

                final complaintDate = formatComplaintDate(
                    complaintItem['date of complain'] ??
                        complaintItem['Date of complain'] ??
                        complaintItem['complaintDate']);

                final problem = (complaintItem['Complain/Remark'] ??
                        complaintItem['Problem'] ??
                        complaintItem['problem'] ??
                        complaintItem['complain'] ??
                        '')
                    .toString()
                    .trim();

                final city = (complaintItem['city'] ?? complaintItem['City'] ?? '')
                    .toString()
                    .trim();

                final status = (complaintItem['Status'] ??
                        complaintItem['status'] ??
                        'Open')
                    .toString()
                    .trim();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KarigarApp(
                            complaint: complaintItem is Map<String, dynamic>
                                ? complaintItem
                                : Map<String, dynamic>.from(complaintItem),
                            title: title,
                            token: token,
                          ),
                        ),
                      );
                      if (result == true) {
                        onRefresh();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (complainNo.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#$complainNo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (phone.isNotEmpty || city.isNotEmpty)
                            Row(
                              children: [
                                if (phone.isNotEmpty) ...[
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                                if (phone.isNotEmpty && city.isNotEmpty)
                                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                                if (city.isNotEmpty) ...[
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Text(
                                    city,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$brand - $product',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (problem.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Issue: $problem',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: $complaintDate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: status.toLowerCase() == 'resolved'
                                          ? Colors.green.shade100
                                          : status.toLowerCase() == 'in progress'
                                              ? Colors.blue.shade100
                                              : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: status.toLowerCase() == 'resolved'
                                            ? Colors.green.shade800
                                            : status.toLowerCase() == 'in progress'
                                                ? Colors.blue.shade800
                                                : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}