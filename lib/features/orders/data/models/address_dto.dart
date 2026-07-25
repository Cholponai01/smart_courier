import 'package:equatable/equatable.dart';
import 'package:smart_courier/features/orders/data/constants/order_firestore_fields.dart';

class AddressDto extends Equatable {
  const AddressDto({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  Map<String, dynamic> toFirestore() {
    return {
      OrderFirestoreFields.address: address,
      OrderFirestoreFields.lat: lat,
      OrderFirestoreFields.lng: lng,
    };
  }

  factory AddressDto.fromFirestore(Map<String, dynamic> data) {
    return AddressDto(
      address: data[OrderFirestoreFields.address] as String? ?? '',
      lat: (data[OrderFirestoreFields.lat] as num?)?.toDouble() ?? 0,
      lng: (data[OrderFirestoreFields.lng] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [address, lat, lng];
}
