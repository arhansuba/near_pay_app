
// ignore_for_file: empty_catches

// Represent user-account
class Account {
  int id; // Primary Key
  int index; // Index on the seed
  String name; // Account nickname
  int lastAccess; // Last Accessed incrementor
  bool selected; // Whether this is the currently selected account
  String address;
  String balance; // Last known balance in RAW

  Account({required this.id, required this.index, required this.name, required this.lastAccess, this.selected = false, required this.address, required this.balance});

  String getShortName() {
    List<String> splitName = name.split(" ");
    if (splitName.length > 1 && splitName[0].isNotEmpty && splitName[1].isNotEmpty) {
      String firstChar = splitName[0].substring(0, 1);
      String secondPart = splitName[1].substring(0, 1);
      try {
        if (int.parse(splitName[1]) >= 10) {
          secondPart = splitName[1].substring(0, 2);
        }
      } catch (e) {}
      return firstChar + secondPart;
    } else if (name.length >= 2) {
      return name.substring(0, 2);
    } else {
      return name.substring(0, 1);
    }
  }
}