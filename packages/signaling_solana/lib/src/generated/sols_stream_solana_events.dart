// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated event API for `sols_stream`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'sols_stream_solana_support.dart';
import 'sols_stream_solana_types.dart';

/// Base class for decoded program events.
sealed class SolsStreamEvent {
  /// Creates a decoded event wrapper.
  const SolsStreamEvent();
}

/// Decoded `AnswerWritten` event.
final class SolsStreamAnswerWrittenEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamAnswerWrittenEvent(this.value);

  /// Typed event payload.
  final SolsStreamAnswerWritten value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    153,
    48,
    199,
    174,
    55,
    249,
    209,
    41,
  ]);
}

/// Decoded `BecameRelay` event.
final class SolsStreamBecameRelayEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamBecameRelayEvent(this.value);

  /// Typed event payload.
  final SolsStreamBecameRelay value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    105,
    207,
    151,
    27,
    211,
    38,
    222,
    60,
  ]);
}

/// Decoded `ConfigInitialized` event.
final class SolsStreamConfigInitializedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConfigInitializedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConfigInitialized value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    181,
    49,
    200,
    156,
    19,
    167,
    178,
    91,
  ]);
}

/// Decoded `ConfigUpdated` event.
final class SolsStreamConfigUpdatedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConfigUpdatedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConfigUpdated value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    40,
    241,
    230,
    122,
    11,
    19,
    198,
    194,
  ]);
}

/// Decoded `ConnectSlotClaimed` event.
final class SolsStreamConnectSlotClaimedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectSlotClaimedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectSlotClaimed value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    16,
    59,
    188,
    96,
    153,
    201,
    138,
    153,
  ]);
}

/// Decoded `ConnectSlotCleanedUpThirdParty` event.
final class SolsStreamConnectSlotCleanedUpThirdPartyEvent
    extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectSlotCleanedUpThirdPartyEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectSlotCleanedUpThirdParty value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    130,
    143,
    209,
    47,
    182,
    55,
    109,
    54,
  ]);
}

/// Decoded `ConnectSlotClosed` event.
final class SolsStreamConnectSlotClosedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectSlotClosedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectSlotClosed value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    104,
    225,
    19,
    212,
    162,
    218,
    251,
    89,
  ]);
}

/// Decoded `ConnectSlotExpired` event.
final class SolsStreamConnectSlotExpiredEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectSlotExpiredEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectSlotExpired value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    190,
    47,
    172,
    253,
    36,
    204,
    219,
    217,
  ]);
}

/// Decoded `ConnectSlotOpened` event.
final class SolsStreamConnectSlotOpenedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectSlotOpenedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectSlotOpened value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    10,
    139,
    249,
    1,
    238,
    134,
    9,
    228,
  ]);
}

/// Decoded `ConnectionConfirmed` event.
final class SolsStreamConnectionConfirmedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamConnectionConfirmedEvent(this.value);

  /// Typed event payload.
  final SolsStreamConnectionConfirmed value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    66,
    225,
    180,
    33,
    158,
    198,
    243,
    48,
  ]);
}

/// Decoded `HeartbeatSent` event.
final class SolsStreamHeartbeatSentEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamHeartbeatSentEvent(this.value);

  /// Typed event payload.
  final SolsStreamHeartbeatSent value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    104,
    195,
    123,
    96,
    64,
    85,
    251,
    122,
  ]);
}

/// Decoded `MemoPosted` event.
final class SolsStreamMemoPostedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamMemoPostedEvent(this.value);

  /// Typed event payload.
  final SolsStreamMemoPosted value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    109,
    202,
    82,
    156,
    147,
    213,
    167,
    67,
  ]);
}

/// Decoded `OfferWritten` event.
final class SolsStreamOfferWrittenEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamOfferWrittenEvent(this.value);

  /// Typed event payload.
  final SolsStreamOfferWritten value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    98,
    70,
    177,
    142,
    223,
    78,
    9,
    82,
  ]);
}

/// Decoded `RoomCleanedUp` event.
final class SolsStreamRoomCleanedUpEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamRoomCleanedUpEvent(this.value);

  /// Typed event payload.
  final SolsStreamRoomCleanedUp value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    213,
    30,
    18,
    249,
    189,
    61,
    134,
    239,
  ]);
}

/// Decoded `RoomClosed` event.
final class SolsStreamRoomClosedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamRoomClosedEvent(this.value);

  /// Typed event payload.
  final SolsStreamRoomClosed value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    150,
    23,
    85,
    195,
    169,
    114,
    30,
    88,
  ]);
}

/// Decoded `RoomCreated` event.
final class SolsStreamRoomCreatedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamRoomCreatedEvent(this.value);

  /// Typed event payload.
  final SolsStreamRoomCreated value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    9,
    177,
    128,
    166,
    26,
    19,
    14,
    243,
  ]);
}

/// Decoded `RoomEnded` event.
final class SolsStreamRoomEndedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamRoomEndedEvent(this.value);

  /// Typed event payload.
  final SolsStreamRoomEnded value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    204,
    239,
    146,
    218,
    190,
    21,
    193,
    184,
  ]);
}

/// Decoded `SlotCleanedUp` event.
final class SolsStreamSlotCleanedUpEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamSlotCleanedUpEvent(this.value);

  /// Typed event payload.
  final SolsStreamSlotCleanedUp value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    177,
    123,
    185,
    62,
    70,
    165,
    171,
    76,
  ]);
}

/// Decoded `TurnPurchased` event.
final class SolsStreamTurnPurchasedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamTurnPurchasedEvent(this.value);

  /// Typed event payload.
  final SolsStreamTurnPurchased value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    238,
    51,
    234,
    108,
    182,
    245,
    188,
    91,
  ]);
}

/// Decoded `UserCleanedUp` event.
final class SolsStreamUserCleanedUpEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamUserCleanedUpEvent(this.value);

  /// Typed event payload.
  final SolsStreamUserCleanedUp value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    244,
    199,
    113,
    177,
    223,
    45,
    218,
    37,
  ]);
}

/// Decoded `UserClosed` event.
final class SolsStreamUserClosedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamUserClosedEvent(this.value);

  /// Typed event payload.
  final SolsStreamUserClosed value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    78,
    205,
    4,
    245,
    226,
    24,
    219,
    51,
  ]);
}

/// Decoded `UserCreated` event.
final class SolsStreamUserCreatedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamUserCreatedEvent(this.value);

  /// Typed event payload.
  final SolsStreamUserCreated value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    145,
    177,
    42,
    214,
    0,
    65,
    40,
    69,
  ]);
}

/// Decoded `UserProfileUpdated` event.
final class SolsStreamUserProfileUpdatedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamUserProfileUpdatedEvent(this.value);

  /// Typed event payload.
  final SolsStreamUserProfileUpdated value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    137,
    227,
    236,
    168,
    126,
    29,
    3,
    132,
  ]);
}

/// Decoded `ViewerExpired` event.
final class SolsStreamViewerExpiredEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamViewerExpiredEvent(this.value);

  /// Typed event payload.
  final SolsStreamViewerExpired value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    194,
    112,
    181,
    31,
    164,
    1,
    245,
    94,
  ]);
}

/// Decoded `ViewerJoined` event.
final class SolsStreamViewerJoinedEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamViewerJoinedEvent(this.value);

  /// Typed event payload.
  final SolsStreamViewerJoined value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    149,
    205,
    228,
    15,
    25,
    237,
    47,
    107,
  ]);
}

/// Decoded `ViewerLeft` event.
final class SolsStreamViewerLeftEvent extends SolsStreamEvent {
  /// Creates an event wrapper.
  const SolsStreamViewerLeftEvent(this.value);

  /// Typed event payload.
  final SolsStreamViewerLeft value;

  /// IDL event discriminator.
  static final List<int> discriminator = List.unmodifiable(<int>[
    179,
    210,
    148,
    119,
    95,
    107,
    118,
    3,
  ]);
}

/// Context attached to every decoded event notification.
final class SolsStreamEventContext {
  /// Creates event context.
  const SolsStreamEventContext({required this.signature, required this.slot});

  /// Transaction signature.
  final String signature;

  /// Context slot.
  final BigInt slot;
}

/// One typed event notification or recoverable log diagnostic.
sealed class SolsStreamEventNotification {
  /// Creates a notification.
  const SolsStreamEventNotification();
}

/// Successfully decoded event notification.
final class SolsStreamDecodedEventNotification
    extends SolsStreamEventNotification {
  /// Creates a decoded notification.
  const SolsStreamDecodedEventNotification({
    required this.event,
    required this.context,
  });

  /// Typed event.
  final SolsStreamEvent event;

  /// Transaction context.
  final SolsStreamEventContext context;
}

/// Recoverable malformed or truncated log notification.
final class SolsStreamEventDiagnosticNotification
    extends SolsStreamEventNotification {
  /// Creates a diagnostic notification.
  const SolsStreamEventDiagnosticNotification({
    required this.code,
    required this.message,
  });

  /// Stable diagnostic code.
  final String code;

  /// Human-readable diagnostic.
  final String message;
}

/// Closeable typed event subscription.
final class SolsStreamTypedEventSubscription {
  /// Creates a typed wrapper around a raw subscription.
  SolsStreamTypedEventSubscription._(this._raw, this.notifications);

  final SolsStreamEventSubscription _raw;

  bool _closed = false;

  /// Typed events and recoverable malformed-log diagnostics.
  final Stream<SolsStreamEventNotification> notifications;

  /// Closes the raw subscription exactly once.
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _raw.close();
  }
}

/// Typed event subscription client with invocation-stack parsing.
final class SolsStreamEventsClient {
  /// Creates an event client.
  const SolsStreamEventsClient(this.subscriber);

  /// Raw log subscription capability.
  final SolsStreamEventSubscriber subscriber;

  /// Subscribes and decodes events without closing on malformed logs.
  Future<SolsStreamTypedEventSubscription> subscribe() async {
    final subscription = await subscriber.subscribe(
      SolsStreamProgram.programAddress,
    );
    return SolsStreamTypedEventSubscription._(
      subscription,
      subscription.batches.asyncExpand(_decodeBatch),
    );
  }

  Stream<SolsStreamEventNotification> _decodeBatch(
    SolsStreamLogBatch batch,
  ) async* {
    final target = SolsStreamProgram.address;
    final stack = <String>[];
    for (final line in batch.logs) {
      final invoke = RegExp(r'^Program ([1-9A-HJ-NP-Za-km-z]+) invoke')
          .firstMatch(line);
      if (invoke != null) {
        stack.add(invoke.group(1)!);
        continue;
      }
      final exit = RegExp(r'^Program ([1-9A-HJ-NP-Za-km-z]+) (success|failed)')
          .firstMatch(line);
      if (exit != null) {
        if (stack.isEmpty || stack.last != exit.group(1)) {
          yield const SolsStreamEventDiagnosticNotification(
            code: 'EVENT_STACK_MISMATCH',
            message: 'Program invocation stack is malformed.',
          );
        } else {
          stack.removeLast();
        }
        continue;
      }
      if (!line.startsWith('Program data: ') ||
          stack.isEmpty ||
          stack.last != target) {
        continue;
      }
      Uint8List payload;
      try {
        payload = base64Decode(line.substring(14));
      } on FormatException {
        yield const SolsStreamEventDiagnosticNotification(
          code: 'EVENT_BASE64',
          message: 'Event payload is not valid Base64.',
        );
        continue;
      }
      final decoded = _decode(payload);
      if (decoded == null) {
        yield const SolsStreamEventDiagnosticNotification(
          code: 'EVENT_DISCRIMINATOR',
          message: 'Unknown or truncated event discriminator.',
        );
      } else {
        yield SolsStreamDecodedEventNotification(
          event: decoded,
          context: SolsStreamEventContext(
            signature: batch.signature,
            slot: batch.slot,
          ),
        );
      }
    }
  }

  SolsStreamEvent? _decode(Uint8List data) {
    if (_startsWith(data, SolsStreamAnswerWrittenEvent.discriminator)) {
      return SolsStreamAnswerWrittenEvent(
        SolsStreamAnswerWritten.codec.decodeExact(
          data.sublist(SolsStreamAnswerWrittenEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamBecameRelayEvent.discriminator)) {
      return SolsStreamBecameRelayEvent(
        SolsStreamBecameRelay.codec.decodeExact(
          data.sublist(SolsStreamBecameRelayEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConfigInitializedEvent.discriminator)) {
      return SolsStreamConfigInitializedEvent(
        SolsStreamConfigInitialized.codec.decodeExact(
          data.sublist(SolsStreamConfigInitializedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConfigUpdatedEvent.discriminator)) {
      return SolsStreamConfigUpdatedEvent(
        SolsStreamConfigUpdated.codec.decodeExact(
          data.sublist(SolsStreamConfigUpdatedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConnectSlotClaimedEvent.discriminator)) {
      return SolsStreamConnectSlotClaimedEvent(
        SolsStreamConnectSlotClaimed.codec.decodeExact(
          data.sublist(SolsStreamConnectSlotClaimedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(
      data,
      SolsStreamConnectSlotCleanedUpThirdPartyEvent.discriminator,
    )) {
      return SolsStreamConnectSlotCleanedUpThirdPartyEvent(
        SolsStreamConnectSlotCleanedUpThirdParty.codec.decodeExact(
          data.sublist(
            SolsStreamConnectSlotCleanedUpThirdPartyEvent.discriminator.length,
          ),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConnectSlotClosedEvent.discriminator)) {
      return SolsStreamConnectSlotClosedEvent(
        SolsStreamConnectSlotClosed.codec.decodeExact(
          data.sublist(SolsStreamConnectSlotClosedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConnectSlotExpiredEvent.discriminator)) {
      return SolsStreamConnectSlotExpiredEvent(
        SolsStreamConnectSlotExpired.codec.decodeExact(
          data.sublist(SolsStreamConnectSlotExpiredEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConnectSlotOpenedEvent.discriminator)) {
      return SolsStreamConnectSlotOpenedEvent(
        SolsStreamConnectSlotOpened.codec.decodeExact(
          data.sublist(SolsStreamConnectSlotOpenedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamConnectionConfirmedEvent.discriminator)) {
      return SolsStreamConnectionConfirmedEvent(
        SolsStreamConnectionConfirmed.codec.decodeExact(
          data.sublist(SolsStreamConnectionConfirmedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamHeartbeatSentEvent.discriminator)) {
      return SolsStreamHeartbeatSentEvent(
        SolsStreamHeartbeatSent.codec.decodeExact(
          data.sublist(SolsStreamHeartbeatSentEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamMemoPostedEvent.discriminator)) {
      return SolsStreamMemoPostedEvent(
        SolsStreamMemoPosted.codec.decodeExact(
          data.sublist(SolsStreamMemoPostedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamOfferWrittenEvent.discriminator)) {
      return SolsStreamOfferWrittenEvent(
        SolsStreamOfferWritten.codec.decodeExact(
          data.sublist(SolsStreamOfferWrittenEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamRoomCleanedUpEvent.discriminator)) {
      return SolsStreamRoomCleanedUpEvent(
        SolsStreamRoomCleanedUp.codec.decodeExact(
          data.sublist(SolsStreamRoomCleanedUpEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamRoomClosedEvent.discriminator)) {
      return SolsStreamRoomClosedEvent(
        SolsStreamRoomClosed.codec.decodeExact(
          data.sublist(SolsStreamRoomClosedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamRoomCreatedEvent.discriminator)) {
      return SolsStreamRoomCreatedEvent(
        SolsStreamRoomCreated.codec.decodeExact(
          data.sublist(SolsStreamRoomCreatedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamRoomEndedEvent.discriminator)) {
      return SolsStreamRoomEndedEvent(
        SolsStreamRoomEnded.codec.decodeExact(
          data.sublist(SolsStreamRoomEndedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamSlotCleanedUpEvent.discriminator)) {
      return SolsStreamSlotCleanedUpEvent(
        SolsStreamSlotCleanedUp.codec.decodeExact(
          data.sublist(SolsStreamSlotCleanedUpEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamTurnPurchasedEvent.discriminator)) {
      return SolsStreamTurnPurchasedEvent(
        SolsStreamTurnPurchased.codec.decodeExact(
          data.sublist(SolsStreamTurnPurchasedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamUserCleanedUpEvent.discriminator)) {
      return SolsStreamUserCleanedUpEvent(
        SolsStreamUserCleanedUp.codec.decodeExact(
          data.sublist(SolsStreamUserCleanedUpEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamUserClosedEvent.discriminator)) {
      return SolsStreamUserClosedEvent(
        SolsStreamUserClosed.codec.decodeExact(
          data.sublist(SolsStreamUserClosedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamUserCreatedEvent.discriminator)) {
      return SolsStreamUserCreatedEvent(
        SolsStreamUserCreated.codec.decodeExact(
          data.sublist(SolsStreamUserCreatedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamUserProfileUpdatedEvent.discriminator)) {
      return SolsStreamUserProfileUpdatedEvent(
        SolsStreamUserProfileUpdated.codec.decodeExact(
          data.sublist(SolsStreamUserProfileUpdatedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamViewerExpiredEvent.discriminator)) {
      return SolsStreamViewerExpiredEvent(
        SolsStreamViewerExpired.codec.decodeExact(
          data.sublist(SolsStreamViewerExpiredEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamViewerJoinedEvent.discriminator)) {
      return SolsStreamViewerJoinedEvent(
        SolsStreamViewerJoined.codec.decodeExact(
          data.sublist(SolsStreamViewerJoinedEvent.discriminator.length),
        ),
      );
    }
    if (_startsWith(data, SolsStreamViewerLeftEvent.discriminator)) {
      return SolsStreamViewerLeftEvent(
        SolsStreamViewerLeft.codec.decodeExact(
          data.sublist(SolsStreamViewerLeftEvent.discriminator.length),
        ),
      );
    }
    return null;
  }

  bool _startsWith(List<int> data, List<int> prefix) {
    if (data.length < prefix.length) {
      return false;
    }
    for (var index = 0; index < prefix.length; index++) {
      if (data[index] != prefix[index]) {
        return false;
      }
    }
    return true;
  }
}
