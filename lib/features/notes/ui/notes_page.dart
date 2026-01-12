import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/notes_controller.dart';
import 'note_editor_page.dart';
import 'widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesControllerProvider);
    final ctrl = ref.read(notesControllerProvider.notifier);

    final notes = ctrl.visibleNotes;
    final tags = ctrl.allTags.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Better Notes',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NoteEditorPage()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsetsGeometry.all(12),
        child: Column(
          children: [
            TextField(
              cursorColor: Color.fromRGBO(0, 0, 0, 1),
              cursorWidth: 2.2,
              onChanged: ctrl.setSearch,
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(27)),
                  borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.702), width: 2)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(27)),
                  borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.702), width: 2)
                ),
                prefixIcon: Icon(Icons.search, size: 35, fontWeight: FontWeight.bold,),
                hintText: 'Search title for content...',
                hintStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)
              ),
            ),

            const SizedBox(height: 10,),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selectedColor: Color.fromRGBO(0, 103, 9, 0.317),
                      label: const Text('All', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                      selected: state.activeTag.isEmpty,
                      onSelected: (_) => ctrl.setTag(''),
                    ),
                  ),
                  
                  for (final t in tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selectedColor: Color.fromRGBO(0, 103, 9, 0.317),
                        label: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),), 
                        selected: state.activeTag == t,
                        onSelected: (_) => ctrl.setTag(t),
                      ),
                    )
                ],
              ),
            ),

            const SizedBox(height: 10,),
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Text('No notes yet. Tap + to create one.'),
                    )
                  :ListView.separated(
                    itemBuilder: (context, i) {
                      final note = notes[i];
                      return NoteTile(
                        note: note,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteEditorPage(noteId: note.id),
                            ),
                          );
                        },
                        onDelete: () async {
                          await ctrl.delete(note.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Note deleted!'),
                              action: SnackBarAction(
                                label: 'UNDO', 
                                onPressed: () async {
                                  await ctrl.save(note);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }, 
                    separatorBuilder: (_, __) => const SizedBox(height: 8,), 
                    itemCount: notes.length,
                    )
              )
          ],
        ),
      ),
    );
  }
}