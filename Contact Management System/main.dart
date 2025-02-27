import 'dart:io';
import 'dart:convert';

// File storage for saving contacts
const String fileName = "contacts.json";

// List to store contacts as maps
List<Map<String, String>> contacts = [];

void main() {
  loadContacts(); // Load contacts when program starts

  while (true) {
    print("\n═══════════════════════════════════════");
    print("📞 CONTACT MANAGER ");
    print("═══════════════════════════════════════");
    print("1️⃣ Add Contact");
    print("2️⃣ View Contacts (Sorted)");
    print("3️⃣ Update Contact");
    print("4️⃣ Delete Contact");
    print("5️⃣ Search Contact");
    print("6️⃣ Backup Contacts");
    print("7️⃣ Restore Contacts");
    print("8️⃣ Exit");
    print("═══════════════════════════════════════");

    int choice = getValidChoice("📌 Choose an option: ", 1, 8);

    switch (choice) {
      case 1:
        addContact();
        break;
      case 2:
        viewContacts();
        break;
      case 3:
        updateContact();
        break;
      case 4:
        deleteContact();
        break;
      case 5:
        searchContact();
        break;
      case 6:
        backupContacts();
        break;
      case 7:
        restoreContacts();
        break;
      case 8:
        saveContacts();
        print("✅ Contacts saved. Exiting program...");
        return;
    }
  }
}

// Function to get a valid integer input within a range
int getValidChoice(String prompt, int min, int max) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input != null && int.tryParse(input) != null) {
      int choice = int.parse(input);
      if (choice >= min && choice <= max) return choice;
    }
    print("❌ Invalid input! Please enter a number between $min and $max.");
  }
}

// Function to get a valid string input
String getValidString(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input != null && input.trim().isNotEmpty) return input.trim();
    print("❌ Input cannot be empty. Please enter a valid value.");
  }
}

// Function to add a new contact (Prevents duplicates)
void addContact() {
  String name = getValidString("👤 Enter name: ");
  String phone = getValidString("📞 Enter phone: ");
  String email = getValidString("📧 Enter email: ");

  // Prevent Duplicate Names
  if (contacts.any((contact) => contact["name"]!.toLowerCase() == name.toLowerCase())) {
    print("⚠️ Contact with this name already exists!");
    return;
  }

  contacts.add({"name": name, "phone": phone, "email": email});
  print("✅ Contact added successfully!");
  saveContacts();
}

// Function to view all contacts (Sorted)
void viewContacts() {
  if (contacts.isEmpty) {
    print("📂 No contacts available.");
    return;
  }

  // Sorting Contacts Alphabetically
  contacts.sort((a, b) => a["name"]!.compareTo(b["name"]!));

  print("\n📋 CONTACT LIST (Sorted Alphabetically)");
  print("═══════════════════════════════════════");
  for (var contact in contacts) {
    print("👤 Name: ${contact['name']}");
    print("📞 Phone: ${contact['phone']}");
    print("📧 Email: ${contact['email']}");
    print("═══════════════════════════════════════");
  }
}

// Function to update a contact
void updateContact() {
  if (contacts.isEmpty) {
    print("📂 No contacts available to update.");
    return;
  }

  String name = getValidString("🔄 Enter name of contact to update: ");
  for (var contact in contacts) {
    if (contact["name"]!.toLowerCase() == name.toLowerCase()) {
      print("📝 Leave blank to keep current value.");
      stdout.write("📞 Enter new phone (or press Enter to skip): ");
      String newPhone = stdin.readLineSync() ?? "";
      stdout.write("📧 Enter new email (or press Enter to skip): ");
      String newEmail = stdin.readLineSync() ?? "";

      if (newPhone.isNotEmpty) contact["phone"] = newPhone;
      if (newEmail.isNotEmpty) contact["email"] = newEmail;

      print("✅ Contact updated successfully!");
      saveContacts();
      return;
    }
  }
  print("❌ Contact not found.");
}

// Function to delete a contact (with confirmation)
void deleteContact() {
  if (contacts.isEmpty) {
    print("📂 No contacts available to delete.");
    return;
  }

  String name = getValidString("🗑️ Enter name of contact to delete: ");
  contacts.removeWhere((contact) => contact["name"]!.toLowerCase() == name.toLowerCase());

  print("✅ Contact deleted successfully!");
  saveContacts();
}

// Function to search a contact by name
void searchContact() {
  if (contacts.isEmpty) {
    print("📂 No contacts available.");
    return;
  }

  String searchName = getValidString("🔍 Enter name to search: ").toLowerCase();
  List<Map<String, String>> results =
  contacts.where((contact) => contact["name"]!.toLowerCase().contains(searchName)).toList();

  if (results.isEmpty) {
    print("❌ No contact found with that name.");
  } else {
    print("\n🔎 SEARCH RESULTS");
    print("═══════════════════════════════════════");
    for (var contact in results) {
      print("👤 Name: ${contact['name']}");
      print("📞 Phone: ${contact['phone']}");
      print("📧 Email: ${contact['email']}");
      print("═══════════════════════════════════════");
    }
  }
}

// Function to backup contacts
void backupContacts() {
  try {
    File backupFile = File("contacts_backup.json");
    backupFile.writeAsStringSync(jsonEncode(contacts));
    print("✅ Contacts backed up successfully!");
  } catch (e) {
    print("⚠️ Error creating backup: $e");
  }
}

// Function to restore contacts from backup
void restoreContacts() {
  try {
    File backupFile = File("contacts_backup.json");
    if (backupFile.existsSync()) {
      List<dynamic> decodedList = jsonDecode(backupFile.readAsStringSync());

      contacts = decodedList.map((contact) {
        return {
          "name": contact["name"].toString(),
          "phone": contact["phone"].toString(),
          "email": contact["email"].toString(),
        };
      }).toList();

      print("✅ Contacts restored successfully!");
    } else {
      print("❌ No backup found.");
    }
  } catch (e) {
    print("⚠️ Error restoring contacts: $e");
  }
}

// Function to save contacts to file
void saveContacts() {
  File file = File(fileName);
  file.writeAsStringSync(jsonEncode(contacts));
}

// Function to load contacts from file
void loadContacts() {
  File file = File(fileName);
  if (file.existsSync()) {
    List<dynamic> decodedList = jsonDecode(file.readAsStringSync());

    contacts = decodedList.map((contact) {
      return {
        "name": contact["name"].toString(),
        "phone": contact["phone"].toString(),
        "email": contact["email"].toString(),
      };
    }).toList();
  }
}
