import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/components/custom_text_field.dart';
import '../controller/chatbot_controller.dart';



class ChatBotView extends StatelessWidget {
  final controller = Get.find<ChatBotController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Career Assistant')),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: controller.nameController, hintText: "Name"),
            const SizedBox(height: 12),
            CustomTextField(controller: controller.educationController, hintText: "Education"),
            const SizedBox(height: 12),
            CustomTextField(controller: controller.locationController, hintText: "Location (e.g. Pakistan, Lahore)"),
            const SizedBox(height: 12),
            CustomTextField(controller: controller.bioController, hintText: "Short Bio"),
            const SizedBox(height: 12),
            CustomTextField(controller: controller.interestsController, hintText: "Interests"),
            const SizedBox(height: 20),

            // Dynamic Skills Fields
            GetBuilder<ChatBotController>(
              builder: (con) {
                return ListView.builder(
                  itemCount: con.skillControllers.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: con.skillControllers[index],
                              hintText: "Skill ${index + 1}",
                            ),
                          ),
                          IconButton(
                            onPressed: () => con.removeSkillField(index),
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.addSkillField,
                icon: const Icon(Icons.add),
                label: const Text("Add Skill"),
              ),
            ),
            const SizedBox(height: 20),

            // CustomButton(
            //   isLoading: controller.isLoading.value,
            //   title: "Generate Career Path",
            //   onPressed: () async {
            //     try{
            //       final result = await controller.generateCareerPath();
            //       print("Result: $result");
            //       Get.dialog(
            //         Dialog(
            //           insetPadding: const EdgeInsets.all(8),
            //           child: Container(
            //             width: double.infinity,
            //             height: Get.height * 0.8, // 70% of screen height
            //             padding: const EdgeInsets.all(16),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 const Text(
            //                   "Career Guidance",
            //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            //                 ),
            //                 const SizedBox(height: 10),
            //                 Expanded(
            //                   child: SingleChildScrollView(
            //                     child: Html(
            //                       data: result.replaceAll('\n', '<br>'),
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 10),
            //                 Align(
            //                   alignment: Alignment.centerRight,
            //                   child: TextButton(
            //                     onPressed: () => Get.back(),
            //                     child: const Text("Close"),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     }catch (ex){
            //       debugPrint("Error: $ex");
            //       showErrorMessage("Sorry, something went wrong. Please try again.");
            //     }
            //   },
            // ),

            // Updated dialog implementation


            CustomButton(
              isLoading: controller.isLoading.value,
              title: "Generate Career Path",
              onPressed: () async {
                try {

                  if (controller.nameController.text.isEmpty ||
                      controller.educationController.text.isEmpty ||
                      controller.locationController.text.isEmpty ||
                      controller.bioController.text.isEmpty ||
                      controller.interestsController.text.isEmpty) {
                    showErrorMessage("Please fill in all fields.");
                    return;
                  }


                  final result = await controller.generateCareerPath();
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      backgroundColor: const Color(0xFFFAFAFA),
                      surfaceTintColor: const Color(0xFFFAFAFA),
                      insetPadding: const EdgeInsets.all(16),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: Get.height * 0.85,
                          maxWidth: Get.width * 0.95,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Career Guidance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Get.back(),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Html(
                                  data: result,
                                  style: {
                                    "div": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "h1": Style(
                                      margin: Margins.only(bottom: 10),
                                    ),
                                    "h2": Style(
                                      margin: Margins.only(bottom: 8),
                                    ),
                                    "p": Style(
                                      margin: Margins.only(bottom: 12),
                                      lineHeight: const LineHeight(1.4),
                                    ),
                                    "ul": Style(
                                      margin: Margins.only(bottom: 12, left: 16),
                                    ),
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[800],
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                ),
                                onPressed: () => Get.back(),
                                child: const Text("Close"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  controller.resetFields();
                } catch (ex) {
                  debugPrint("Error showing dialog: $ex");
                  showErrorMessage("Sorry, something went wrong. Please try again.");
                }
              },
            ),

        ],
        ),
      )),
    );
  }
}
