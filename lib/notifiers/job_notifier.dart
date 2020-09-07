import 'package:flutter/material.dart';

class JobNotifier with ChangeNotifier {
  List<String> theJobs = ["--", "", "", "", "", "", "", ""];

  addJob(String t1, t2, t3, t4, t5, t6, t7, t8) {
    //theJobs.add(data);
    theJobs.insert(0, t1);
    theJobs.insert(1, t2);
    theJobs.insert(2, t3);
    theJobs.insert(3, t4);
    theJobs.insert(4, t5);
    theJobs.insert(5, t6);
    theJobs.insert(6, t7);
    theJobs.insert(7, t8);
    notifyListeners();
  }
}
