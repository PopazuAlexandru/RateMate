// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      profilePicturePath: fields[4] as String?,
      tags: (fields[5] as List?)?.cast<String>(),
      followers: (fields[6] as List?)?.cast<String>(),
      following: (fields[7] as List?)?.cast<String>(),
      isAdmin: fields[8] as bool,
      isBlocked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.profilePicturePath)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.followers)
      ..writeByte(7)
      ..write(obj.following)
      ..writeByte(8)
      ..write(obj.isAdmin)
      ..writeByte(9)
      ..write(obj.isBlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 1;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Review(
      id: fields[0] as String,
      targetUserId: fields[1] as String,
      submitterUserId: fields[2] as String?,
      rating: fields[3] as int,
      comment: fields[4] as String,
      timestamp: fields[5] as DateTime,
      status: fields[6] as ReviewStatus,
      moderatorNote: fields[7] as String?,
      tag: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.targetUserId)
      ..writeByte(2)
      ..write(obj.submitterUserId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.comment)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.moderatorNote)
      ..writeByte(8)
      ..write(obj.tag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReviewStatusAdapter extends TypeAdapter<ReviewStatus> {
  @override
  final int typeId = 2;

  @override
  ReviewStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReviewStatus.pending;
      case 1:
        return ReviewStatus.approved;
      case 2:
        return ReviewStatus.rejected;
      default:
        return ReviewStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ReviewStatus obj) {
    switch (obj) {
      case ReviewStatus.pending:
        writer.writeByte(0);
        break;
      case ReviewStatus.approved:
        writer.writeByte(1);
        break;
      case ReviewStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
