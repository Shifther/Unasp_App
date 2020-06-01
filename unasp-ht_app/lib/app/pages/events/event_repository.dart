import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unasp_ht/app/pages/events/event_model.dart';

class EventRepository {
  
  final Firestore _firestore;
 
  EventRepository(this._firestore);

  Future<List<Eventos>> getEventos() async { try {
      QuerySnapshot snapshot = await _firestore.collection('eventos').getDocuments();

      if (snapshot == null || snapshot.documents == null) {
        return null;
      }
      return snapshot.documents.map((f) => Eventos.fromJson(f.data)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<bool> post(Eventos model) async {
    try {
      await Firestore.instance
          .collection('eventos')
          .document()
          .setData(model.toJson());

      return true;
    } catch (e) {
      return false;
    }
  }
}
