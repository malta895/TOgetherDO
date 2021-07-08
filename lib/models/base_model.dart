import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/utils.dart';

// part 'base_model.g.dart';

@JsonSerializable(
  checked: true,
  createFactory: false,
  createToJson: false,
)
abstract class BaseModel {
  /// The id provided by the data source
  String? databaseId;

  @JsonKey(
      fromJson: ModelUtils.dateTimeFromJson, toJson: ModelUtils.dateTimeToJson)
  final DateTime createdAt;

  BaseModel({
    this.databaseId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}
