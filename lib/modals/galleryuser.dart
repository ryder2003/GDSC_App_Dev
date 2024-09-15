class GalleryUser {
  String image;
  String name;
  String id;
  String email;
  String pushToken;

  GalleryUser({
    required this.image,
    required this.name,
    required this.id,
    required this.email,
    required this.pushToken,
  });

  GalleryUser.fromJson(Map<String, dynamic>? json)
      : image = json?['image'] ?? '',
        name = json?['name'] ?? '',
        id = json?['id'] ?? '',
        email = json?['email'] ?? '',
        pushToken = json?['push_token'] ?? '';

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}


