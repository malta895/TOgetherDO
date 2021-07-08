import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable(
  checked: true,
  createFactory: false,
)
abstract class BaseModel {
  /// The id provided by the data source
  String? databaseId;

  BaseModel([this.databaseId]);
}
