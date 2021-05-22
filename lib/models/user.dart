import 'dart:collection';

/// An user of the application
class User {
  String _firstName;
  String _lastName;
  final String _email;
  final String _username;

  Set<Friendship> _friendships = {};

  User(this._firstName, this._lastName, this._email, this._username);

  String get fullName => _firstName + ' ' + _lastName;
  String get firstName => _firstName;
  String get email => _email;
  String get username => _username;

  UnmodifiableSetView<Friendship> get friendships =>
      UnmodifiableSetView(_friendships);

  bool addFriendship(Friendship friendship) => _friendships.add(friendship);
}

/// It represents the friendship among more users
class Friendship {
  final User _user;

  final bool _accepted;

  User get user => _user;
  bool get accepted => _accepted;

  Friendship(this._user, this._accepted);
}
