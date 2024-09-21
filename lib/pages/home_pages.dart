import 'package:assignmentapp/controller/public_controller.dart';
import 'package:assignmentapp/pages/details_pages.dart';
import 'package:flutter/material.dart';

import '../model/demo_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  List<Memes> memes= [];
  List<Memes> filter = [];
  PublicController publicController = PublicController();

  fetchDoctorList() async {
    memes = await publicController.getDoctorList(context);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDoctorList();
    filter = memes;
  }

  List<Memes>? result;

  void runFilter(String name) {
    if (name.isEmpty) {
      result = memes!;
    } else {
      result = memes!
          .where((element) =>
              element.name!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    setState(() {
      filter = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: memes == null
          ?  Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.amber.withOpacity(0.6)),
                      child: TextField(
                        onChanged: (value) => runFilter(value),
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            hintStyle: TextStyle(color: Colors.white),
                            hintText: "Search",
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                          itemCount: filter.isNotEmpty ? filter.length : memes.length,
                          itemBuilder: (context, index) {
                            final data =
                            filter.isNotEmpty ? filter[index] : memes[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DetailsPages(
                                              url: "${data.url}",
                                              name: '${data.name}',
                                              id: '${data.id}',
                                              box_coutn: '${data.boxCount}',
                                              capiton: '${data.captions}',
                                            )));
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    Image.network("${data.url}"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("${data.name}")
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
