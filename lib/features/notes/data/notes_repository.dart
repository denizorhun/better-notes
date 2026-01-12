import 'notes_local_ds.dart';
import 'note_model.dart';

class NotesRepistory {
  NotesRepistory(this._local);

  final NotesLocalDataSource _local;

  List<NoteModel> listNotes({
    String search = '',
    String tag = '',
  }) {
    final all = _local.getAll();
    final s = search.trim().toLowerCase();

    return all.where((n) {
      final matchesSearch = s.isEmpty ||
        n.title.toLowerCase().contains(s) ||
        n.content.toLowerCase().contains(s);

        final matchesTag = tag.isEmpty || n.tags.contains(tag);

        return matchesSearch && matchesTag;
    }).toList();
  }

  Future<void> save(NoteModel note) => _local.upsert(note);

  Future<void> remove(String id) => _local.delete(id);

  NoteModel? get(String id) => _local.getById(id);
}
