#include <iostream>
#include <vector>
#include <algorithm>  // std::find() ke liye
#include <ctime>      // Random number generator ke liye

using namespace std;

// ?? Member Class
class Member {
public:
    int id;
    string name;
    int balance;
    bool hasWon;

    Member(int i, string n) : id(i), name(n), balance(0), hasWon(false) {}

    void updateBalance(int amount) {
        balance = amount;
    }

    void addBalanceManually(int amount) {
        balance += amount;
    }
};

// ?? Transaction Class (JazzCash, EasyPaisa, Cash)
class Transaction {
public:
    static void processPayment(Member& member, int amount, string method) {
        cout << "Processing " << amount << " PKR payment for " << member.name;
        cout << " using " << method << ". Transaction Successful!\n";
        member.updateBalance(amount);
    }
};

// ?? Committee Class
class Committee {
private:
    vector<Member> members;

public:
    Committee() {
        members.push_back(Member(101, "Ali"));
        members.push_back(Member(102, "Ahmed"));
        members.push_back(Member(103, "Sara"));
        members.push_back(Member(104, "Ayesha"));
    }

    vector<Member>& getMembers() {
        return members;
    }

    void conductLuckyDraw() {
        vector<int> eligibleIndexes;
        for (int i = 0; i < members.size(); ++i) {
            if (!members[i].hasWon) {
                eligibleIndexes.push_back(i);
            }
        }

        if (eligibleIndexes.empty()) {
            cout << "All members have won once. Resetting winners list.\n";
            for (auto& member : members) {
                member.hasWon = false;
            }
            return conductLuckyDraw();
        }

        srand(time(0));
        int winnerIndex = eligibleIndexes[rand() % eligibleIndexes.size()];
        members[winnerIndex].hasWon = true;

        cout << "?? Winner for this month: " << members[winnerIndex].name << " ??\n";
        
        string method;
        cout << "Enter Payment Method (JazzCash/EasyPaisa/Cash): ";
        cin >> method;

        // Reset all balances to 0 before giving the winner 20,000 PKR
        for (auto& member : members) {
            member.updateBalance(0);
        }

        // Give the winner 20,000 PKR
        Transaction::processPayment(members[winnerIndex], 20000, method);
    }

    void displayMembers() {
        cout << "\n?? Committee Members List:\n";
        cout << "----------------------------------\n";
        cout << "ID\tName\tBalance\tHas Won\n";
        cout << "----------------------------------\n";
        for (auto& member : members) {
            cout << member.id << "\t" << member.name << "\t" << member.balance << " PKR\t" << (member.hasWon ? "Yes" : "No") << "\n";
        }
        cout << "----------------------------------\n";
    }

    void setMonthlyAllowance() {
        for (auto& member : members) {
            member.updateBalance(0); // Reset balance to 0 at the start of the month
        }
    }

    void addManualBalance() {
        for (auto& member : members) {
            int amount;
            cout << "Enter balance to add for " << member.name << ": ";
            cin >> amount;
            member.addBalanceManually(amount);
        }
    }

    void conductMonthlyDraw(int month) {
        cout << "\n==================== Month " << month << " ====================\n";
        setMonthlyAllowance(); // Reset balances to 0 at the start of the month
        displayMembers(); // Display members after resetting balances

        cout << "\nAdding manual balances to members...\n";
        addManualBalance(); // Add manual balances for each member
        displayMembers(); // Display members after adding manual balances

        cout << "\nConducting Lucky Draw for Month " << month << "...\n";
        conductLuckyDraw(); // Conduct the lucky draw
        displayMembers(); // Display members after the lucky draw
    }
};

int main() {
    Committee committee;
    int month = 1;
    while (month <= 12) {
        char choice;
        cout << "Do you want to conduct the lucky draw for this month? (y/n): ";
        cin >> choice;

        if (choice == 'y' || choice == 'Y') {
            committee.conductMonthlyDraw(month);
        } else {
            cout << "Skipping lucky draw for this month.\n";
        }

        month++;
    }

    return 0;
}