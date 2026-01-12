import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String content;

  @HiveField(3)
  final List<String> tags;

  @HiveField(4)
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title, 
    required this.content, 
    required this.tags, 
    required this.updatedAt
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? updatedAt,  
  }) {
    return NoteModel(
      id: id ?? this.id, 
      title: title ?? this.title, 
      content: content ?? this.content,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}