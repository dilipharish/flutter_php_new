  // void saveHLA(String hlaSequence) async {
  //   // Validate the HLA sequence
  //   if (!isValidHLA(hlaSequence)) {
  //     setState(() {
  //       errorMessage = 'Invalid HLA sequence. Only A, G, T, and C are allowed.';
  //     });
  //     return;
  //   }

  //   // TODO: Send the HLA sequence to your backend and save it to the database
  //   final MySqlConnection conn = await MySqlConnection.connect(settings);

  //   try {
  //     final userId = widget
  //         .userId; // Get the user's ID (you may need to adjust how you obtain this)
  //     final hlaValue = hlaSequence;

  //     await conn.query(
  //       'UPDATE users SET hla = ? WHERE id = ?',
  //       [hlaValue, userId],
  //     );
  //     print("HLA updated successfully!");
  //   } catch (e) {
  //     print("Exception in saving HLA: $e");
  //   } finally {
  //     await conn.close(); // Close the database connection
  //   }

  //   // Clear the text input field
  //   hlaController.clear();
  // }

  // bool isValidHLA(String sequence) {
  //   // Check if the sequence contains only A, G, T, and C
  //   return RegExp(r'^[AGTC]+$').hasMatch(sequence);
  // }