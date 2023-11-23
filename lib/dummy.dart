// const SizedBox(height: 20), // Add some spacing
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 Bloodmanagement_Page(userId: widget.userId),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(
//                               255, 224, 48, 51), // Change to your desired color
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Text(
//                           'Blood Management',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 Organmanagement(userId: widget.userId),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: const Color.fromARGB(255, 224, 48, 51),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Text(
//                           'Organ Management',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),