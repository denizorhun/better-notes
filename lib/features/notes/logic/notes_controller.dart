import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

import '../data/note_model.dart';
import '../data/notes_local_ds.dart';
import '../data/notes_repository.dart';

final notesRepoProvider = Provider<NotesRepistory>((ref) {
  final box = Hive.box<NoteModel>('notes');
  return NotesRepistory(NotesLocalDataSource(box));
});

class NotesState {
  final String search;
  final String activeTag;

  const NotesState({this.search = '', this.activeTag = ''});

  NotesState copyWith({String? search, String? activeTag}) {
    return NotesState(
      search: search ?? this.search,
      activeTag: activeTag ?? this.activeTag,
    );
  }
}

final notesControllerProvider = 
    StateNotifierProvider<NotesController, NotesState>((ref) {
  return NotesController(ref.read(notesRepoProvider));
});

class NotesController  extends StateNotifier<NotesState> {
  NotesController(this._repo) : super(const NotesState());

  final NotesRepistory _repo;

  void setSearch(String value) => state = state.copyWith(activeTag: value);

  void setTag(String value) => state = state.copyWith(activeTag: value);

  List<NoteModel> get visibleNotes =>
    _repo.listNotes(search: state.search, tag: state.activeTag);

  Set<String> get allTags {
    final all = _repo.listNotes();
    final tags = <String>{};
    for (final n in all) {
      tags.addAll(n.tags);
    }
    return tags;
  }

  Future<void> save(NoteModel note) async => _repo.save(note);

  Future<void> delete(String id) async => _repo.remove(id);

  NoteModel? getById(String id) => _repo.get(id);
}