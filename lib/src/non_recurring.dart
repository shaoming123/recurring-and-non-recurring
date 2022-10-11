import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/accordion/task.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/util/app_styles.dart';

class NonRecurring extends StatelessWidget {
  const NonRecurring({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: Container(
          margin: EdgeInsets.only(
              top: height * 0.08, left: width * 0.02, right: width * 0.02),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
                  Text("Non-Recurring", style: Styles.title),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black),
                    onPressed: () => {},
                  ),
                ],
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [
                      Text("Total ",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      const Text("3",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Completed",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      const Text("3",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Overdue",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Tasks",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      const Text("3",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Column(children: [
                      Text("Pending",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      Text("Review",
                          style:
                              TextStyle(color: Styles.textColor, fontSize: 14)),
                      const Gap(5),
                      const Text("3",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ],
                ),
              ),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      Task(
                        title: 'Section #1',
                        content:
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam bibendum ornare vulputate. Curabitur faucibus condimentum purus quis tristique.',
                      ),
                      Gap(20),
                      Task(
                        title: 'Section #1',
                        content:
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam bibendum ornare vulputate. Curabitur faucibus condimentum purus quis tristique.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
