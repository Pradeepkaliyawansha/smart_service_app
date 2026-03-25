part of 'addon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddonModelAdapter extends TypeAdapter<AddonModel> {
  @override
  final int typeId = 2;

  @override
  AddonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddonModel(
      id: fields[0] as String,
      serviceId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      price: fields[4] as double,
      icon: fields[5] as String,
      isPopular: fields[6] as bool,
      selectCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AddonModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.isPopular)
      ..writeByte(7)
      ..write(obj.selectCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
