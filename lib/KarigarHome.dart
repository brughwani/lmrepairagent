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
    complaintsData=fetchComplaints();
  }

  Future<Map<String, List<dynamic>>> fetchComplaints() async {
    final url = Uri.parse('https://limsonvercelapi2.vercel.app/api/fskarigarapp?technicianName=${widget.name}');
    final response = await http.get(url, headers: {

      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    });
  //  [, , 'Resolved'];
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final complaints = data['complaints'] as List<dynamic>;

      // Categorized map
      final Map<String, List<dynamic>> categorizedComplaints = {
        'pending': [],
        'inProgress': [],
        'solved': [],
      };
      for (var complaint in complaints) {
        switch (complaint['Status']) {
          case 'Open':
            categorizedComplaints['pending']?.add(complaint);
            break;
          case 'In Progress':
            categorizedComplaints['inProgress']?.add(complaint);
            break;
          case 'Resolved':
            categorizedComplaints['solved']?.add(complaint);
            break;
          default:
          // Handle unknown statuses if needed
            break;
        }
        print(jsonEncode(categorizedComplaints['pending']));
        // print('Pending Complaints: ${categorizedComplaints['pending']}');
      }
        return categorizedComplaints;

        // print('Data: $data');
        // return {
        //   'pending': data['complaints'][0]['']['Open'] ?? [],
        //   'inProgress': data['In Progress'] ?? [],
        //   'solved': data['Resolved'] ?? [],
        // };

    }
      else {
      throw Exception('Failed to load complaints');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: complaintsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            print(data.runtimeType);
            return SingleChildScrollView(
              child: Column(
                children: [
                  ComplaintContainer(
                    title: 'Pending Complaints',
                    complaints: data['pending']?.length,
                    color: Colors.orange,
                    onTap: () {
                      print('Pending complaints tapped: ${data['pending']}');
                      // Handle tap for pending complaints
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailsPage(title:"pending",complaint: data['pending']!,token: widget.token,
                          onRefresh: () {
                            setState(() {
                              complaintsData = fetchComplaints();
                            });
                          },
                          ),
                        ),
                      );
                    },
                  ),
                  ComplaintContainer(
                    title: 'In Progress Complaints',
                    complaints: data['inProgress']?.length,
                    color: Colors.blue,
                    onTap: () {
                      // Handle tap for in-progress complaints
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailsPage(title:"In progress",complaint: data['inProgress']!,token: widget.token,
                          onRefresh: () {
                            setState(() {
                              complaintsData = fetchComplaints();
                            });
                          },),

                        ),
                      );
                    },
                  ),
                  ComplaintContainer(
                    title: 'Solved Complaints',
                    complaints: data['solved']?.length,
                    color: Colors.green,
                    onTap: () {
                      // Handle tap for solved complaints
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailsPage(title:"solved",complaint: data['solved']!,token: widget.token,
                          onRefresh: () {
                            setState(() {
                              complaintsData = fetchComplaints();
                            });
                          },),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$complaints Complaints',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              // .map((complaint) {
              //   return ListTile(
              //     title: Text(complaint['title']),
              //     subtitle: Text(complaint['description']),
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) =>
              //               ComplaintDetailsPage(complaint: complaint),
              //         ),
              //       );
              //     },
              //   );
              // }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ComplaintDetailsPage extends StatelessWidget {
  String title;
  final List<dynamic> complaint;
  String token;
  final VoidCallback onRefresh;
  ComplaintDetailsPage({required this.title,required this.complaint, Key? key,required this.token,required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: complaint.length,
        itemBuilder: (context, index) {
          final complaintItem = complaint.toList()[index];
          print(complaintItem);
          return ListTile(

            title: Text(complaintItem['Customer name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brand: ${complaintItem['Brand']}'),
                Text('Product: ${complaintItem['Product name']}'),
                Text('Complaint Date: ${complaintItem['date of complain']}'),
                Text('Status: ${complaintItem['Status']}'),
              ],
            ),
            onTap: () async {
              // Handle tap for complaint details
           final result= await   Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KarigarApp(complaint: complaintItem, title: title,token: token)
                  ),);
               result == true ? onRefresh() : null;


            },

          );

        },
      ),
    );
  }
}