import 'package:flutter/foundation.dart';


@immutable
class ProfileUser {
  final String id;
  final String name;
  final String phone;
  final int balance;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });
}
