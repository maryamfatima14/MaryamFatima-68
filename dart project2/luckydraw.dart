import 'dart:io';
import 'dart:math';

// Member Class
class Member {
  int id;
  String name;
  int balance;
  bool hasWon;

  Member(this.id, this.name) : balance = 0, hasWon = false;

  void updateBalance(int amount) {
    balance = amount;
  }

  void addBalanceManually(int amount) {
    balance += amount;
  }
}

// Transaction Class (JazzCash, EasyPaisa, Cash)
class Transaction {
  static void processPayment(Member member, int amount, String method) {
    print("Processing \$amount PKR payment for ${member.name} using $method. Transaction Successful!");
    member.updateBalance(amount);
  }
}

// Committee Class
class Committee {
  List<Member> members = [];

  Committee() {
    members.add(Member(101, "Ali"));
    members.add(Member(102, "Ahmed"));
    members.add(Member(103, "Sara"));
    members.add(Member(104, "Ayesha"));
  }

  void conductLuckyDraw() {
    List<int> eligibleIndexes = [];
    for (int i = 0; i < members.length; i++) {
      if (!members[i].hasWon) {
        eligibleIndexes.add(i);
      }
    }

    if (eligibleIndexes.isEmpty) {
      print("All members have won once. Resetting winners list.");
      for (var member in members) {
        member.hasWon = false;
      }
      return conductLuckyDraw();
    }

    Random random = Random();
    int winnerIndex = eligibleIndexes[random.nextInt(eligibleIndexes.length)];
    members[winnerIndex].hasWon = true;

    print("\n🏆 Winner for this month: ${members[winnerIndex].name} 🏆");
    stdout.write("Enter Payment Method (JazzCash/EasyPaisa/Cash): ");
    String method = stdin.readLineSync() ?? "Cash";

    for (var member in members) {
      member.updateBalance(0);
    }

    Transaction.processPayment(members[winnerIndex], 20000, method);
  }

  void displayMembers() {
    print("\n🎉 Committee Members List:");
    print("----------------------------------");
    print("ID\tName\tBalance\tHas Won");
    print("----------------------------------");
    for (var member in members) {
      print("${member.id}\t${member.name}\t${member.balance} PKR\t${member.hasWon ? 'Yes' : 'No'}");
    }
    print("----------------------------------");
  }

  void setMonthlyAllowance() {
    for (var member in members) {
      member.updateBalance(0);
    }
  }

  void addManualBalance() {
    for (var member in members) {
      stdout.write("Enter balance to add for ${member.name}: ");
      int? amount = int.tryParse(stdin.readLineSync() ?? "0");
      if (amount != null) {
        member.addBalanceManually(amount);
      }
    }
  }

  void conductMonthlyDraw(int month) {
    print("\n==================== Month $month ====================");
    setMonthlyAllowance();
    displayMembers();

    print("\nAdding manual balances to members...");
    addManualBalance();
    displayMembers();

    print("\nConducting Lucky Draw for Month $month...");
    conductLuckyDraw();
    displayMembers();
  }
}

void main() {
  Committee committee = Committee();
  int month = 1;

  while (month <= 12) {
    stdout.write("Do you want to conduct the lucky draw for this month? (y/n): ");
    String choice = stdin.readLineSync() ?? "n";

    if (choice.toLowerCase() == 'y') {
      committee.conductMonthlyDraw(month);
    } else {
      print("Skipping lucky draw for this month.");
    }
    month++;
  }
}
