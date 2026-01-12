import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/note_model.dart';
import '../logic/notes_controller.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  const NoteEditorPage({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _tags = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ctrl = ref.read(notesControllerProvider.notifier);
    if (widget.noteId != null) {
      final note = ctrl.getById(widget.noteId!);
      if (note != null) {
        _title.text = note.title;
        _content.text = note.content;
        _tags.text = note.tags.join(', ');
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

    Future<void> _save() async {
    final title = _title.text.trim();
    final content = _content.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final ctrl = ref.read(notesControllerProvider.notifier);
    final now = DateTime.now();

    final existing =
        widget.noteId != null ? ctrl.getById(widget.noteId!) : null;

    final note = (existing ??
            NoteModel(
              id: const Uuid().v4(),
              title: '',
              content: '',
              tags: const [],
              updatedAt: now,
            ))
        .copyWith(
      title: title.isEmpty ? '(untitled)' : title,
      content: content,
      tags: _parseTags(_tags.text),
      updatedAt: now,
    );

    await ctrl.save(note);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title', 
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                textAlignVertical: TextAlignVertical.top,
                controller: _content,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                ),
              ),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                hintText: 'e.g. school, work, ideas',
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
