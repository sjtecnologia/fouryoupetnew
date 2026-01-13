import 'package:fouryoupet/models/event/event.dart';
import 'package:firebase_helpers/firebase_helpers.dart';

import '../../helpers/data_constants.dart';

final eventDBS = DatabaseService<AppEvent>(AppDBConstants.eventsCollection,
    fromDS: (id, data) => AppEvent.fromDS(id, data),
    toMap: (event) => event.toMap());
