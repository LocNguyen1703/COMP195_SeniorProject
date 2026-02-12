class Contact {
  //define attributes of the Contact class
  int? id; // id is not required (marked by the "?") - it's nullable because it will be auto-incremented by the database
  String name; // all these attributes are required (no "?") - cannot be null 
  String email;
  String phone;
  String address;

  //constructor for the Contact class 
  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  //function to convert a Contact object to a Map (for database storage) 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone, 
      'address': address,
    };
  }

  //function to convert a Map to a Contact object (for retrieving from the database)
  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  

}