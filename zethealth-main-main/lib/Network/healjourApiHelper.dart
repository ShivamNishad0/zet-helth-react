
import 'dart:convert';

import 'package:zet_health/Models/BranchDepartmentModel.dart';
import 'package:zet_health/Models/BranchListModel.dart';
import 'package:http/http.dart' as http;


const String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbl91dWlkIjoiMWM0ZWQ5YzYtZjcxMS00MjNjLTk1M2UtOWMxZjY1MDBkOTE1IiwiYWRtaW5fZW1haWwiOiJoZXhwcmVzc0BoZWFsam91ci5jb20iLCJhZG1pbl9yb2xlIjoic3VwZXJfYWRtaW4iLCJhZG1pbl90eXBlIjoiaW5zdXJlciIsImFzc29jaWF0ZWRfYnJhbmNoZXMiOltdLCJpYXQiOjE3NDk2MzQ0OTgsImV4cCI6MTc0OTcyMDg5OH0.tUdudOtV-PFgEcu17kYmeDp7Gr46u33nl0LNLN3h1eY"; // Replace with your actual token

class HealjourApiServices{

  Future<BranchListModel?> branchList(String postcode) async {
    try {
      var response = await http.get(Uri.parse('https://apitesting.healjour.com/v1/branch/list?branch_pincode=$postcode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        BranchListModel branchListModel = BranchListModel.fromJson(json);
        return branchListModel;
      } else {
        print("Unexpected response status: ${response.statusCode}");
      }
    } catch (err) {
      print("Error occurred: $err");
    }
    return null;
  }

  Future<BranchDepartmentModel?> branchDepartment(String branchuuid) async {
    try {
      var response = await http.get(
        Uri.parse('https://apitesting.healjour.com/v1/department/list?branch_uuid=$branchuuid'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        BranchDepartmentModel branchDepartmentModel = BranchDepartmentModel.fromJson(json);
        return branchDepartmentModel;
      } else {
        print("Unexpected response status: ${response.statusCode}");
      }
    } catch (err) {
      print("Error occurred : $err");
    }

    return null;
  }


}