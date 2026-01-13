import 'package:firebase_helpers/firebase_helpers.dart';

import '../../helpers/data_constants.dart';
import 'hotel.dart';

final hotelDBS = DatabaseService<Hotel>(AppDBConstants.hotelCollection,
    fromDS: (id, data) => Hotel.fromDS(id, data),
    toMap: (hotel) => hotel.toMap());
