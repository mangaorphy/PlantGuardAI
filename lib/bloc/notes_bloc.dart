import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

import 'notes_event.dart';
import 'notes_state.dart';
import '../services/firestore_service.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FirestoreService _firestoreService;

  NotesBloc(this._firestoreService) : super(NotesLoading()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    try {
      final notes = await _firestoreService.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      await _firestoreService.addNote(event.text);
      add(LoadNotes());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        emit(NotesError('Permission denied. Please check your authentication.'));
      } else {
        emit(NotesError(e.message ?? 'Failed to add note'));
      }
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await _firestoreService.updateNote(event.id, event.text);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _firestoreService.deleteNote(event.id);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}