part of 'service_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceModelAdapter extends TypeAdapter<ServiceModel> {
  @override
  final int typeId = 1;

  @override
  ServiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      basePrice: fields[3] as double,
      pricePerHour: fields[4] as double,
      category: fields[5] as String,
      imageUrl: fields[6] as String?,
      tags: (fields[7] as List).cast<String>(),
      minHours: fields[8] as int,
      maxHours: fields[9] as int,
      isActive: fields[10] as bool,
      bookingCount: fields[11] as int,
      addons: (fields[12] as List).cast<AddonModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.pricePerHour)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.minHours)
      ..writeByte(9)
      ..write(obj.maxHours)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.bookingCount)
      ..writeByte(12)
      ..write(obj.addons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
