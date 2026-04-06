class RoomModel {
  final String spaceUuid;
  final String spaceName;
  final String spaceCode;
  final List<String> spaceTags;

  RoomModel({
    required this.spaceUuid,
    required this.spaceName,
    required this.spaceCode,
    required this.spaceTags,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      spaceUuid: json['space_uuid'] ?? '',
      spaceName: json['space_name'] ?? '',
      spaceCode: json['space_code'] ?? '',
      spaceTags:
          (json['space_tags'] ?? '')
              .toString()
              .split(',')
              .map((e) => e.trim())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'space_uuid': spaceUuid,
      'space_name': spaceName,
      'space_code': spaceCode,
      'space_tags': spaceTags.join(','),
    };
  }
}
