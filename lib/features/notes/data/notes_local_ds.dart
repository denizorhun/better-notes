import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'note_model.dart';

class NotesLocalDataSource {
  NotesLocalDataSource(this._box);

  final Box<NoteModel> _box;

  List<NoteModel> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<void> upsert(NoteModel note) async { 
    await _box.put(note.id, note);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  NoteModel? getById(String id) => _box.get(id);

}