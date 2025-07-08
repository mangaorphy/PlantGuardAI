abstract class NotesEvent {}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final String text;
  AddNote(this.text);
}

class UpdateNote extends NotesEvent {
  final String id;
  final String text;
  UpdateNote(this.id, this.text);
}

class DeleteNote extends NotesEvent {
  final String id;
  DeleteNote(this.id);
}
