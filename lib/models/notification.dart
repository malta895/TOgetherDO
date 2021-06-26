import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/models/list.dart';
import 'dart:core';

abstract class ListAppNotification {
  final ListAppUser sender;
  final ListAppUser receiver;
  final ListAppList? list;
  final bool accepted;

  ListAppNotification(
      {required this.sender,
      required this.receiver,
      this.list,
      required this.accepted});
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListInviteNotification extends ListAppNotification {
  ListInviteNotification(
      {required ListAppUser sender,
      required ListAppUser receiver,
      required ListAppList list,
      required bool accepted})
      : super(
            sender: sender, receiver: receiver, list: list, accepted: accepted);
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class FriendshipNotification extends ListAppNotification {
  FriendshipNotification(
      {required ListAppUser sender,
      required ListAppUser receiver,
      required bool accepted})
      : super(sender: sender, receiver: receiver, accepted: accepted);
}
