import 'dart:convert';
import 'dart:io';

import 'package:assignmentapp/widget/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;


import '../model/demo_model.dart';

class PublicController {
  Future<List<Memes>> getDoctorList(BuildContext context) async {
    List<Memes> insertDoctorList = [];

    try {
      http.Response res = await http.get(Uri.parse(Utils.baseUrl));
      print("get data${res.body}");
      print("get brandddddddddddddddddddd       ${res.body.length}");

      if (res.statusCode == 200) {
        var jsonRes = jsonDecode(res.body);

        print(jsonRes);

        DemoModel brandModel = DemoModel.fromJson(jsonRes);

        for (Memes data in brandModel.data!.memes!) {
          insertDoctorList.add(data);
        }
      }
    } on SocketException {
      Fluttertoast.showToast(
          msg: "No internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e.toString());
    }
    return insertDoctorList;
  }





}
