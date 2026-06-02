import 'dart:typed_data';

enum ConnectSlotState {
  open,
  claimed,
  offerReady,
  answerReady,
  connected,
  expired,
}

class ConnectSlotData {
  final Uint8List room;
  final Uint8List host;
  final Uint8List viewer;
  final Uint8List hostProtectedKey;
  final Uint8List offerData;
  final Uint8List viewerProtectedKey;
  final Uint8List answerData;
  final ConnectSlotState state;
  final int createdAt;
  final int expiresAt;
  final int bump;

  const ConnectSlotData({
    required this.room,
    required this.host,
    required this.viewer,
    required this.hostProtectedKey,
    required this.offerData,
    required this.viewerProtectedKey,
    required this.answerData,
    required this.state,
    required this.createdAt,
    required this.expiresAt,
    required this.bump,
  });

  // Borsh layout (all LE):
  // [8 disc][32 room][32 host][32 viewer]
  // [8 host_deposit][8 viewer_deposit]
  // [4+N host_protected_key][4+N offer_data]
  // [4+N viewer_protected_key][4+N answer_data]
  // [1 state][8 created_at][8 expires_at][1 bump]
  static ConnectSlotData parse(Uint8List data) {
    var off = 8; // skip discriminator

    Uint8List readFixed(int n) {
      final s = data.sublist(off, off + n);
      off += n;
      return s;
    }

    Uint8List readVec() {
      final len = ByteData.sublistView(data, off, off + 4)
          .getUint32(0, Endian.little);
      off += 4;
      final s = data.sublist(off, off + len);
      off += len;
      return s;
    }

    void skipU64() => off += 8;

    int readI64() {
      final v = ByteData.sublistView(data, off, off + 8)
          .getInt64(0, Endian.little);
      off += 8;
      return v;
    }

    final room = readFixed(32);
    final host = readFixed(32);
    final viewer = readFixed(32);
    skipU64(); // host_deposit
    skipU64(); // viewer_deposit
    final hostProtectedKey = readVec();
    final offerData = readVec();
    final viewerProtectedKey = readVec();
    final answerData = readVec();
    final stateIdx = data[off++].clamp(0, 5);
    final createdAt = readI64();
    final expiresAt = readI64();
    final bump = data[off];

    return ConnectSlotData(
      room: room,
      host: host,
      viewer: viewer,
      hostProtectedKey: hostProtectedKey,
      offerData: offerData,
      viewerProtectedKey: viewerProtectedKey,
      answerData: answerData,
      state: ConnectSlotState.values[stateIdx],
      createdAt: createdAt,
      expiresAt: expiresAt,
      bump: bump,
    );
  }
}
