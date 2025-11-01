import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:zet_health/Models/BranchDepartmentModel.dart';
import 'package:zet_health/Network/healjourApiHelper.dart';

class DepartmentScreen extends StatefulWidget {
  final String branchUuid;

  const DepartmentScreen({super.key, required this.branchUuid});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  BranchDepartmentModel? departmentModel;
  bool isLoading = false;

  void fetchDepartments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await HealjourApiServices().branchDepartment(widget.branchUuid);
      if (result != null) {
        setState(() {
          departmentModel = result;
        });
      }
    } catch (err) {
      print("Error fetching departments: $err");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Departments", style: semiBoldBlack_18),
        backgroundColor: whiteColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : departmentModel == null ||
                  departmentModel!.data == null ||
                  departmentModel!.data!.isEmpty
              ? const Center(child: Text("No departments found"))
              : ListView.builder(
                  itemCount: departmentModel!.data!.length,
                  itemBuilder: (context, index) {
                    final department = departmentModel!.data![index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.w),
                        title: Text(
                          department.departmentName ?? 'Unnamed Department',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          department.isActive == true
                              ? 'Status: Active'
                              : 'Status: Inactive',
                          style: TextStyle(
                            color: department.isActive == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
