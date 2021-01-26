class User {
  // an user of the application

  String firstName;
  String lastName;
  final String email;
  final String
      username; // will be the same as email, left here because is required by backend at login

  List<Friendship> friendships = [];

  User(this.firstName, this.lastName, this.email, this.username);

  String getFullName() {
    return firstName + ' ' + lastName;
  }

  void addFriendship(Friendship friendship) {
    friendships.add(friendship);
  }
}

class Friendship {
  final User user;

  final bool accepted;

  Friendship(this.user, this.accepted);
}
