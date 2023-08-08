import '../resources/assets.dart';

class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.isOnline,
    required this.email,
    required this.pushToken,
    this.verified,
  });

  late String? image;
  late String? name;
  late String? about;
  late String? createdAt;
  late String? lastActive;
  late String? id;
  late bool? isOnline;
  late bool? verified;
  late String? email;
  late String? pushToken;

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      image: json["image"] ?? Assets.firebaseDpImage,
      name: json["name"],
      about: json["about"] ?? "",
      createdAt: json["created_at"] ?? "",
      lastActive: json["last_active"] ?? "",
      id: json["id"] ?? "",
      isOnline: json["is_online"] ?? false,
      email: json["email"] ?? "",
      pushToken: json["push_token"] ?? "",
      verified: json["verified"]?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
        "about": about,
        "created_at": createdAt,
        "last_active": lastActive,
        "id": id,
        "is_online": isOnline,
        "email": email,
        "push_token": pushToken,
         "verified": verified,
      };


}
