abstract class NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Map<String, dynamic>> notes;
  NotesLoaded(this.notes);
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}