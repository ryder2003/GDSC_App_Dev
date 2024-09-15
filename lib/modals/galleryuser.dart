class GalleryUser {
  GalleryUser({
    required this.image,
    required this.name,
    required this.id,
    required this.email,
    required this.pushToken,
  });
  late String image;
  late String name;
  late String id;
  late String email;
  late String pushToken;

  GalleryUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    name = json['name']?? '';
    id = json['id']?? '';
    email = json['email']?? '';
    pushToken = json['push_token']?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['name'] = name;
    _data['id'] = id;
    _data['email'] = email;
    _data['push_token'] = pushToken;
    return _data;
  }
}


