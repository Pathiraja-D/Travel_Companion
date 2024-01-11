// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_images.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteImagesAdapter extends TypeAdapter<NoteImages> {
  @override
  final int typeId = 1;

  @override
  NoteImages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteImages(
      fields[0] as String,
      (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteImages obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.noteId)
      ..writeByte(1)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteImagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
