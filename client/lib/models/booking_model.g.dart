part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingModelAdapter extends TypeAdapter<BookingModel> {
  @override
  final int typeId = 3;

  @override
  BookingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      serviceId: fields[2] as String,
      serviceName: fields[3] as String,
      selectedAddonIds: (fields[4] as List).cast<String>(),
      selectedAddonNames: (fields[5] as List).cast<String>(),
      durationHours: fields[6] as int,
      basePrice: fields[7] as double,
      addonsTotal: fields[8] as double,
      discountAmount: fields[9] as double,
      totalPrice: fields[10] as double,
      status: fields[11] as String,
      bookingDate: fields[12] as DateTime,
      eventDate: fields[13] as DateTime?,
      notes: fields[14] as String?,
      packageName: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BookingModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.serviceId)
      ..writeByte(3)
      ..write(obj.serviceName)
      ..writeByte(4)
      ..write(obj.selectedAddonIds)
      ..writeByte(5)
      ..write(obj.selectedAddonNames)
      ..writeByte(6)
      ..write(obj.durationHours)
      ..writeByte(7)
      ..write(obj.basePrice)
      ..writeByte(8)
      ..write(obj.addonsTotal)
      ..writeByte(9)
      ..write(obj.discountAmount)
      ..writeByte(10)
      ..write(obj.totalPrice)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.bookingDate)
      ..writeByte(13)
      ..write(obj.eventDate)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.packageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
