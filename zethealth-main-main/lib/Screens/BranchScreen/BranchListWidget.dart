import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:zet_health/Models/BranchListModel.dart';
import 'package:zet_health/Network/healjourApiHelper.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AppConstants.dart';
import 'BranchDepartment/branchDepartment.dart';

class BranchListWidget extends StatefulWidget {
  const BranchListWidget({super.key});

  @override
  State<BranchListWidget> createState() => _BranchListWidgetState();
}

class _BranchListWidgetState extends State<BranchListWidget> {
  BranchListModel branchListModel = BranchListModel();
  bool isLoading = false;
  final TextEditingController _pincodeController =
  TextEditingController(text: "");

  void fetchBranchList(String pincode) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await HealjourApiServices().branchList(pincode);
      if (result != null) {
        setState(() {
          branchListModel = result;
        });
      }
    } catch (err) {
      print("Error fetching branches: $err");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    String? currentPincode =
    AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE);
    if (currentPincode != null && currentPincode.isNotEmpty) {
      _pincodeController.text = currentPincode;
      fetchBranchList(currentPincode);
    } else {
      fetchBranchList(_pincodeController.text); // Initial fetch
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Pincode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: () {
                  fetchBranchList(_pincodeController.text.trim());
                  print('Your current pincode is \${_pincodeController.text}');
                },
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : branchListModel.data == null || branchListModel.data!.isEmpty
              ? const Center(child: Text("No branches found"))
              : ListView.builder(
            itemCount: branchListModel.data!.length,
            itemBuilder: (context, index) {
              final branch = branchListModel.data![index];
              return Card(
                margin: EdgeInsets.symmetric(
                    horizontal: 15.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12.w),
                  title: Text(
                    branch.branchName ?? 'No Name',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(branch.branchAddress ?? 'No Address'),
                      if (branch.branchCity != null)
                        Text(
                            '\${branch.branchCity}, \${branch.branchState}'),
                      if (branch.branchPincode != null)
                        Text('Pincode: \${branch.branchPincode}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartmentScreen(
                          branchUuid: branch.branchUuid ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
