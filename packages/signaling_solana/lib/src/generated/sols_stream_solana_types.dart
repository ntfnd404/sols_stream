// GENERATED CODE - DO NOT MODIFY BY HAND.
// tool: solana_idl_codegen
// generator-version: 0.2.0
// source-sha256: e967590f776990a88746c52fff70bb1e412706ceefa537870b711bb1dfe2279d
// semantic-ir-sha256: 06de736cba994a28c486121c3344a50591093167febb525a8227d85946d809fe
// SPDX-License-Identifier: MIT
/// Generated value models for `sols_stream`.
library;

import 'dart:typed_data';

import 'sols_stream_solana_support.dart';

bool _programListEquals<T>(
  List<T> left,
  List<T> right,
  bool Function(T left, T right) equals,
) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (!equals(left[index], right[index])) {
      return false;
    }
  }
  return true;
}

/// Generated metadata for `sols_stream`.
abstract final class SolsStreamProgram {
  /// Program name declared by the IDL.
  static const String name = 'sols_stream';

  /// Program version declared by the IDL.
  static const String version = '0.1.0';

  /// Anchor IDL specification dialect.
  static const String spec = '0.1.0';

  /// Base58 program address declared by the IDL.
  static const String address = '8rYyL3AY3cb4XrFWfUokXKwQb8uU48XvuLAHNxTgdmXw';

  /// Parsed program address.
  static final SolsStreamAddress programAddress = SolsStreamAddress.fromBase58(
    address,
  );
}

/// Sealed immutable representation of `AccessMode`.
sealed class SolsStreamAccessMode {
  /// Creates an enum variant.
  const SolsStreamAccessMode();

  /// Borsh codec for [SolsStreamAccessMode].
  static final SolsStreamBorshCodec<SolsStreamAccessMode> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamAccessMode>(
        (reader) {
          final tag = reader.readInt(1);
          return switch (tag) {
            0 => SolsStreamAccessModePublic(),
            1 => SolsStreamAccessModePrivate(),
            2 => SolsStreamAccessModePaid(),
            _ => throw SolsStreamBorshException(
              code: 'BORSH_ENUM_TAG',
              message: 'Invalid enum tag.',
              offset: reader.offset - 1,
              path: r'\$',
            ),
          };
        },
        (writer, value) {
          switch (value) {
            case SolsStreamAccessModePublic():
              writer.writeUnsigned(BigInt.from(0), 1);
            case SolsStreamAccessModePrivate():
              writer.writeUnsigned(BigInt.from(1), 1);
            case SolsStreamAccessModePaid():
              writer.writeUnsigned(BigInt.from(2), 1);
          }
        },
      );
}

/// The `Public` variant of [SolsStreamAccessMode].
final class SolsStreamAccessModePublic extends SolsStreamAccessMode {
  /// Creates the unit value.
  const SolsStreamAccessModePublic();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamAccessModePublic);

  @override
  int get hashCode => Object.hashAll([0]);
}

/// The `Private` variant of [SolsStreamAccessMode].
final class SolsStreamAccessModePrivate extends SolsStreamAccessMode {
  /// Creates the unit value.
  const SolsStreamAccessModePrivate();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamAccessModePrivate);

  @override
  int get hashCode => Object.hashAll([1]);
}

/// The `Paid` variant of [SolsStreamAccessMode].
final class SolsStreamAccessModePaid extends SolsStreamAccessMode {
  /// Creates the unit value.
  const SolsStreamAccessModePaid();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamAccessModePaid);

  @override
  int get hashCode => Object.hashAll([2]);
}

/// Immutable Borsh value for `AnswerWritten`.
final class SolsStreamAnswerWritten {
  /// Creates a validated immutable value.
  SolsStreamAnswerWritten({required this.slot, required this.viewer});

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `viewer`.
  final SolsStreamAddress viewer;

  /// Borsh codec for [SolsStreamAnswerWritten].
  static final SolsStreamBorshCodec<SolsStreamAnswerWritten> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamAnswerWritten>(
        (reader) => SolsStreamAnswerWritten(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewer: reader.field(
            'viewer',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.viewer.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamAnswerWritten &&
          slot == other.slot &&
          viewer == other.viewer);

  @override
  int get hashCode => Object.hashAll([slot.hashCode, viewer.hashCode]);
}

/// Immutable Borsh value for `BecameRelay`.
final class SolsStreamBecameRelay {
  /// Creates a validated immutable value.
  SolsStreamBecameRelay({required this.user, required this.room});

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Borsh codec for [SolsStreamBecameRelay].
  static final SolsStreamBorshCodec<SolsStreamBecameRelay> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamBecameRelay>(
        (reader) => SolsStreamBecameRelay(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeBytes(value.room.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamBecameRelay &&
          user == other.user &&
          room == other.room);

  @override
  int get hashCode => Object.hashAll([user.hashCode, room.hashCode]);
}

/// Immutable Borsh value for `ConfigInitialized`.
final class SolsStreamConfigInitialized {
  /// Creates a validated immutable value.
  SolsStreamConfigInitialized({
    required this.authority,
    required this.serviceWallet,
  });

  /// Value of the IDL field `authority`.
  final SolsStreamAddress authority;

  /// Value of the IDL field `service_wallet`.
  final SolsStreamAddress serviceWallet;

  /// Borsh codec for [SolsStreamConfigInitialized].
  static final SolsStreamBorshCodec<SolsStreamConfigInitialized> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConfigInitialized>(
        (reader) => SolsStreamConfigInitialized(
          authority: reader.field(
            'authority',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          serviceWallet: reader.field(
            'service_wallet',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.authority.bytes);
          writer.writeBytes(value.serviceWallet.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConfigInitialized &&
          authority == other.authority &&
          serviceWallet == other.serviceWallet);

  @override
  int get hashCode =>
      Object.hashAll([authority.hashCode, serviceWallet.hashCode]);
}

/// Immutable Borsh value for `ConfigUpdated`.
final class SolsStreamConfigUpdated {
  /// Creates a validated immutable value.
  SolsStreamConfigUpdated({required this.authority});

  /// Value of the IDL field `authority`.
  final SolsStreamAddress authority;

  /// Borsh codec for [SolsStreamConfigUpdated].
  static final SolsStreamBorshCodec<SolsStreamConfigUpdated> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConfigUpdated>(
        (reader) => SolsStreamConfigUpdated(
          authority: reader.field(
            'authority',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.authority.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConfigUpdated && authority == other.authority);

  @override
  int get hashCode => Object.hashAll([authority.hashCode]);
}

/// Immutable Borsh value for `ConnectSlot`.
final class SolsStreamConnectSlot {
  /// Creates a validated immutable value.
  SolsStreamConnectSlot({
    required this.room,
    required this.host,
    required this.viewer,
    required this.hostDeposit,
    required this.viewerDeposit,
    required List<int> hostProtectedKey,
    required List<int> offerData,
    required List<int> viewerProtectedKey,
    required List<int> answerData,
    required this.state,
    required this.createdAt,
    required this.expiresAt,
    required this.bump,
    required this.hostRentPaid,
    required this.viewerRentPaid,
    required this.accessPrice,
    required this.hostConfirmed,
    required this.viewerConfirmed,
  }) : hostProtectedKey = Uint8List.fromList(hostProtectedKey)
           .asUnmodifiableView(),
       offerData = Uint8List.fromList(offerData).asUnmodifiableView(),
       viewerProtectedKey = Uint8List.fromList(viewerProtectedKey)
           .asUnmodifiableView(),
       answerData = Uint8List.fromList(answerData).asUnmodifiableView();

  /// Value of the IDL field `room`.
  ///
  /// Room PDA
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  ///
  /// Host wallet
  final SolsStreamAddress host;

  /// Value of the IDL field `viewer`.
  ///
  /// Viewer wallet (set when viewer claims slot)
  final SolsStreamAddress viewer;

  /// Value of the IDL field `host_deposit`.
  ///
  /// Host's deposit (lamports)
  final BigInt hostDeposit;

  /// Value of the IDL field `viewer_deposit`.
  ///
  /// Viewer's deposit (lamports)
  final BigInt viewerDeposit;

  /// Value of the IDL field `host_protected_key`.
  ///
  /// Host's encrypted passphrase (encrypted by Worker)
  final Uint8List hostProtectedKey;

  /// Value of the IDL field `offer_data`.
  ///
  /// Host's encrypted offer SDP (encrypted with passphrase)
  final Uint8List offerData;

  /// Value of the IDL field `viewer_protected_key`.
  ///
  /// Viewer's encrypted passphrase (encrypted by Worker)
  final Uint8List viewerProtectedKey;

  /// Value of the IDL field `answer_data`.
  ///
  /// Viewer's encrypted answer SDP
  final Uint8List answerData;

  /// Value of the IDL field `state`.
  ///
  /// State machine
  final SolsStreamSlotState state;

  /// Value of the IDL field `created_at`.
  final BigInt createdAt;

  /// Value of the IDL field `expires_at`.
  final BigInt expiresAt;

  /// Value of the IDL field `bump`.
  final int bump;

  /// Value of the IDL field `host_rent_paid`.
  ///
  /// Sum of host's rent contribution (init rent + write_offer top-ups).
  final BigInt hostRentPaid;

  /// Value of the IDL field `viewer_rent_paid`.
  ///
  /// Sum of viewer's rent contribution (write_answer top-ups).
  final BigInt viewerRentPaid;

  /// Value of the IDL field `access_price`.
  ///
  /// Access price snapshot (lamports). Copied from room.price_per_session
  /// at claim_connect_slot time. 0 = free room.
  final BigInt accessPrice;

  /// Value of the IDL field `host_confirmed`.
  ///
  /// Host has called confirm_connection.
  final bool hostConfirmed;

  /// Value of the IDL field `viewer_confirmed`.
  ///
  /// Viewer has called confirm_connection.
  final bool viewerConfirmed;

  /// Borsh codec for [SolsStreamConnectSlot].
  static final SolsStreamBorshCodec<SolsStreamConnectSlot>
  codec = SolsStreamFunctionalBorshCodec<SolsStreamConnectSlot>(
    (reader) => SolsStreamConnectSlot(
      room: reader.field(
        'room',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      host: reader.field(
        'host',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      viewer: reader.field(
        'viewer',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      hostDeposit: reader.field('host_deposit', () => reader.readUnsigned(8)),
      viewerDeposit: reader.field(
        'viewer_deposit',
        () => reader.readUnsigned(8),
      ),
      hostProtectedKey: reader.field(
        'host_protected_key',
        () => reader.readBytes(reader.collectionLength()),
      ),
      offerData: reader.field(
        'offer_data',
        () => reader.readBytes(reader.collectionLength()),
      ),
      viewerProtectedKey: reader.field(
        'viewer_protected_key',
        () => reader.readBytes(reader.collectionLength()),
      ),
      answerData: reader.field(
        'answer_data',
        () => reader.readBytes(reader.collectionLength()),
      ),
      state: reader.field(
        'state',
        () => reader.nested(() => SolsStreamSlotState.codec.read(reader)),
      ),
      createdAt: reader.field('created_at', () => reader.readSigned(8)),
      expiresAt: reader.field('expires_at', () => reader.readSigned(8)),
      bump: reader.field('bump', () => reader.readInt(1)),
      hostRentPaid: reader.field(
        'host_rent_paid',
        () => reader.readUnsigned(8),
      ),
      viewerRentPaid: reader.field(
        'viewer_rent_paid',
        () => reader.readUnsigned(8),
      ),
      accessPrice: reader.field('access_price', () => reader.readUnsigned(8)),
      hostConfirmed: reader.field('host_confirmed', () => reader.readBool()),
      viewerConfirmed: reader.field(
        'viewer_confirmed',
        () => reader.readBool(),
      ),
    ),
    (writer, value) {
      writer.writeBytes(value.room.bytes);
      writer.writeBytes(value.host.bytes);
      writer.writeBytes(value.viewer.bytes);
      writer.writeUnsigned(value.hostDeposit, 8);
      writer.writeUnsigned(value.viewerDeposit, 8);
      writer
        ..writeUnsigned(BigInt.from(value.hostProtectedKey.length), 4)
        ..writeBytes(value.hostProtectedKey);
      writer
        ..writeUnsigned(BigInt.from(value.offerData.length), 4)
        ..writeBytes(value.offerData);
      writer
        ..writeUnsigned(BigInt.from(value.viewerProtectedKey.length), 4)
        ..writeBytes(value.viewerProtectedKey);
      writer
        ..writeUnsigned(BigInt.from(value.answerData.length), 4)
        ..writeBytes(value.answerData);
      SolsStreamSlotState.codec.write(writer, value.state);
      writer.writeSigned(value.createdAt, 8);
      writer.writeSigned(value.expiresAt, 8);
      writer.writeUnsigned(BigInt.from(value.bump), 1);
      writer.writeUnsigned(value.hostRentPaid, 8);
      writer.writeUnsigned(value.viewerRentPaid, 8);
      writer.writeUnsigned(value.accessPrice, 8);
      writer.writeBool(value.hostConfirmed);
      writer.writeBool(value.viewerConfirmed);
    },
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlot &&
          room == other.room &&
          host == other.host &&
          viewer == other.viewer &&
          hostDeposit == other.hostDeposit &&
          viewerDeposit == other.viewerDeposit &&
          _programListEquals(
            hostProtectedKey,
            other.hostProtectedKey,
            (left, right) => left == right,
          ) &&
          _programListEquals(
            offerData,
            other.offerData,
            (left, right) => left == right,
          ) &&
          _programListEquals(
            viewerProtectedKey,
            other.viewerProtectedKey,
            (left, right) => left == right,
          ) &&
          _programListEquals(
            answerData,
            other.answerData,
            (left, right) => left == right,
          ) &&
          state == other.state &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          bump == other.bump &&
          hostRentPaid == other.hostRentPaid &&
          viewerRentPaid == other.viewerRentPaid &&
          accessPrice == other.accessPrice &&
          hostConfirmed == other.hostConfirmed &&
          viewerConfirmed == other.viewerConfirmed);

  @override
  int get hashCode => Object.hashAll([
    room.hashCode,
    host.hashCode,
    viewer.hashCode,
    hostDeposit.hashCode,
    viewerDeposit.hashCode,
    Object.hashAll(hostProtectedKey),
    Object.hashAll(offerData),
    Object.hashAll(viewerProtectedKey),
    Object.hashAll(answerData),
    state.hashCode,
    createdAt.hashCode,
    expiresAt.hashCode,
    bump.hashCode,
    hostRentPaid.hashCode,
    viewerRentPaid.hashCode,
    accessPrice.hashCode,
    hostConfirmed.hashCode,
    viewerConfirmed.hashCode,
  ]);
}

/// Immutable Borsh value for `ConnectSlotClaimed`.
final class SolsStreamConnectSlotClaimed {
  /// Creates a validated immutable value.
  SolsStreamConnectSlotClaimed({
    required this.slot,
    required this.viewer,
    required this.deposit,
  });

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `viewer`.
  final SolsStreamAddress viewer;

  /// Value of the IDL field `deposit`.
  final BigInt deposit;

  /// Borsh codec for [SolsStreamConnectSlotClaimed].
  static final SolsStreamBorshCodec<SolsStreamConnectSlotClaimed> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectSlotClaimed>(
        (reader) => SolsStreamConnectSlotClaimed(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewer: reader.field(
            'viewer',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          deposit: reader.field('deposit', () => reader.readUnsigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.viewer.bytes);
          writer.writeUnsigned(value.deposit, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlotClaimed &&
          slot == other.slot &&
          viewer == other.viewer &&
          deposit == other.deposit);

  @override
  int get hashCode =>
      Object.hashAll([slot.hashCode, viewer.hashCode, deposit.hashCode]);
}

/// Immutable Borsh value for `ConnectSlotCleanedUpThirdParty`.
final class SolsStreamConnectSlotCleanedUpThirdParty {
  /// Creates a validated immutable value.
  SolsStreamConnectSlotCleanedUpThirdParty({
    required this.slot,
    required this.cleaner,
    required this.hostReturned,
    required this.viewerReturned,
    required this.cleanerReward,
  });

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `cleaner`.
  final SolsStreamAddress cleaner;

  /// Value of the IDL field `host_returned`.
  final BigInt hostReturned;

  /// Value of the IDL field `viewer_returned`.
  final BigInt viewerReturned;

  /// Value of the IDL field `cleaner_reward`.
  final BigInt cleanerReward;

  /// Borsh codec for [SolsStreamConnectSlotCleanedUpThirdParty].
  static final SolsStreamBorshCodec<SolsStreamConnectSlotCleanedUpThirdParty>
  codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectSlotCleanedUpThirdParty>(
        (reader) => SolsStreamConnectSlotCleanedUpThirdParty(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          cleaner: reader.field(
            'cleaner',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          hostReturned: reader.field(
            'host_returned',
            () => reader.readUnsigned(8),
          ),
          viewerReturned: reader.field(
            'viewer_returned',
            () => reader.readUnsigned(8),
          ),
          cleanerReward: reader.field(
            'cleaner_reward',
            () => reader.readUnsigned(8),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.cleaner.bytes);
          writer.writeUnsigned(value.hostReturned, 8);
          writer.writeUnsigned(value.viewerReturned, 8);
          writer.writeUnsigned(value.cleanerReward, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlotCleanedUpThirdParty &&
          slot == other.slot &&
          cleaner == other.cleaner &&
          hostReturned == other.hostReturned &&
          viewerReturned == other.viewerReturned &&
          cleanerReward == other.cleanerReward);

  @override
  int get hashCode => Object.hashAll([
    slot.hashCode,
    cleaner.hashCode,
    hostReturned.hashCode,
    viewerReturned.hashCode,
    cleanerReward.hashCode,
  ]);
}

/// Immutable Borsh value for `ConnectSlotClosed`.
final class SolsStreamConnectSlotClosed {
  /// Creates a validated immutable value.
  SolsStreamConnectSlotClosed({required this.slot, required this.host});

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Borsh codec for [SolsStreamConnectSlotClosed].
  static final SolsStreamBorshCodec<SolsStreamConnectSlotClosed> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectSlotClosed>(
        (reader) => SolsStreamConnectSlotClosed(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.host.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlotClosed &&
          slot == other.slot &&
          host == other.host);

  @override
  int get hashCode => Object.hashAll([slot.hashCode, host.hashCode]);
}

/// Immutable Borsh value for `ConnectSlotExpired`.
final class SolsStreamConnectSlotExpired {
  /// Creates a validated immutable value.
  SolsStreamConnectSlotExpired({required this.slot});

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Borsh codec for [SolsStreamConnectSlotExpired].
  static final SolsStreamBorshCodec<SolsStreamConnectSlotExpired> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectSlotExpired>(
        (reader) => SolsStreamConnectSlotExpired(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlotExpired && slot == other.slot);

  @override
  int get hashCode => Object.hashAll([slot.hashCode]);
}

/// Immutable Borsh value for `ConnectSlotOpened`.
final class SolsStreamConnectSlotOpened {
  /// Creates a validated immutable value.
  SolsStreamConnectSlotOpened({
    required this.slot,
    required this.room,
    required this.host,
    required this.deposit,
    required this.expiresAt,
  });

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Value of the IDL field `deposit`.
  final BigInt deposit;

  /// Value of the IDL field `expires_at`.
  final BigInt expiresAt;

  /// Borsh codec for [SolsStreamConnectSlotOpened].
  static final SolsStreamBorshCodec<SolsStreamConnectSlotOpened> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectSlotOpened>(
        (reader) => SolsStreamConnectSlotOpened(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          deposit: reader.field('deposit', () => reader.readUnsigned(8)),
          expiresAt: reader.field('expires_at', () => reader.readSigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.host.bytes);
          writer.writeUnsigned(value.deposit, 8);
          writer.writeSigned(value.expiresAt, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectSlotOpened &&
          slot == other.slot &&
          room == other.room &&
          host == other.host &&
          deposit == other.deposit &&
          expiresAt == other.expiresAt);

  @override
  int get hashCode => Object.hashAll([
    slot.hashCode,
    room.hashCode,
    host.hashCode,
    deposit.hashCode,
    expiresAt.hashCode,
  ]);
}

/// Immutable Borsh value for `ConnectionConfirmed`.
final class SolsStreamConnectionConfirmed {
  /// Creates a validated immutable value.
  SolsStreamConnectionConfirmed({
    required this.slot,
    required this.host,
    required this.viewer,
  });

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Value of the IDL field `viewer`.
  final SolsStreamAddress viewer;

  /// Borsh codec for [SolsStreamConnectionConfirmed].
  static final SolsStreamBorshCodec<SolsStreamConnectionConfirmed> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectionConfirmed>(
        (reader) => SolsStreamConnectionConfirmed(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewer: reader.field(
            'viewer',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.host.bytes);
          writer.writeBytes(value.viewer.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamConnectionConfirmed &&
          slot == other.slot &&
          host == other.host &&
          viewer == other.viewer);

  @override
  int get hashCode =>
      Object.hashAll([slot.hashCode, host.hashCode, viewer.hashCode]);
}

/// Sealed immutable representation of `ConnectionMode`.
sealed class SolsStreamConnectionMode {
  /// Creates an enum variant.
  const SolsStreamConnectionMode();

  /// Borsh codec for [SolsStreamConnectionMode].
  static final SolsStreamBorshCodec<SolsStreamConnectionMode> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamConnectionMode>(
        (reader) {
          final tag = reader.readInt(1);
          return switch (tag) {
            0 => SolsStreamConnectionModeStream(),
            1 => SolsStreamConnectionModeP2P(),
            _ => throw SolsStreamBorshException(
              code: 'BORSH_ENUM_TAG',
              message: 'Invalid enum tag.',
              offset: reader.offset - 1,
              path: r'\$',
            ),
          };
        },
        (writer, value) {
          switch (value) {
            case SolsStreamConnectionModeStream():
              writer.writeUnsigned(BigInt.from(0), 1);
            case SolsStreamConnectionModeP2P():
              writer.writeUnsigned(BigInt.from(1), 1);
          }
        },
      );
}

/// The `Stream` variant of [SolsStreamConnectionMode].
final class SolsStreamConnectionModeStream extends SolsStreamConnectionMode {
  /// Creates the unit value.
  const SolsStreamConnectionModeStream();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamConnectionModeStream);

  @override
  int get hashCode => Object.hashAll([0]);
}

/// The `P2P` variant of [SolsStreamConnectionMode].
final class SolsStreamConnectionModeP2P extends SolsStreamConnectionMode {
  /// Creates the unit value.
  const SolsStreamConnectionModeP2P();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamConnectionModeP2P);

  @override
  int get hashCode => Object.hashAll([1]);
}

/// Immutable Borsh value for `HeartbeatSent`.
final class SolsStreamHeartbeatSent {
  /// Creates a validated immutable value.
  SolsStreamHeartbeatSent({required this.user, required this.expiresAt});

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `expires_at`.
  final BigInt expiresAt;

  /// Borsh codec for [SolsStreamHeartbeatSent].
  static final SolsStreamBorshCodec<SolsStreamHeartbeatSent> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamHeartbeatSent>(
        (reader) => SolsStreamHeartbeatSent(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          expiresAt: reader.field('expires_at', () => reader.readSigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeSigned(value.expiresAt, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamHeartbeatSent &&
          user == other.user &&
          expiresAt == other.expiresAt);

  @override
  int get hashCode => Object.hashAll([user.hashCode, expiresAt.hashCode]);
}

/// Immutable Borsh value for `MemoPosted`.
final class SolsStreamMemoPosted {
  /// Creates a validated immutable value.
  SolsStreamMemoPosted({required this.sender, required this.dataLen});

  /// Value of the IDL field `sender`.
  final SolsStreamAddress sender;

  /// Value of the IDL field `data_len`.
  final int dataLen;

  /// Borsh codec for [SolsStreamMemoPosted].
  static final SolsStreamBorshCodec<SolsStreamMemoPosted> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamMemoPosted>(
        (reader) => SolsStreamMemoPosted(
          sender: reader.field(
            'sender',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          dataLen: reader.field('data_len', () => reader.readInt(4)),
        ),
        (writer, value) {
          writer.writeBytes(value.sender.bytes);
          writer.writeUnsigned(BigInt.from(value.dataLen), 4);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamMemoPosted &&
          sender == other.sender &&
          dataLen == other.dataLen);

  @override
  int get hashCode => Object.hashAll([sender.hashCode, dataLen.hashCode]);
}

/// Immutable Borsh value for `OfferWritten`.
final class SolsStreamOfferWritten {
  /// Creates a validated immutable value.
  SolsStreamOfferWritten({required this.slot, required this.host});

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Borsh codec for [SolsStreamOfferWritten].
  static final SolsStreamBorshCodec<SolsStreamOfferWritten> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamOfferWritten>(
        (reader) => SolsStreamOfferWritten(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.host.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamOfferWritten &&
          slot == other.slot &&
          host == other.host);

  @override
  int get hashCode => Object.hashAll([slot.hashCode, host.hashCode]);
}

/// Immutable Borsh value for `ProgramConfig`.
final class SolsStreamProgramConfig {
  /// Creates a validated immutable value.
  SolsStreamProgramConfig({
    required this.authority,
    required this.serviceWallet,
    required this.turnPrice,
    required this.signalFee,
    required this.heartbeatTtl,
    required this.minHeartbeatInterval,
    required this.bump,
  });

  /// Value of the IDL field `authority`.
  ///
  /// Admin wallet — can update config
  final SolsStreamAddress authority;

  /// Value of the IDL field `service_wallet`.
  ///
  /// Receives TURN fees and signal fees
  final SolsStreamAddress serviceWallet;

  /// Value of the IDL field `turn_price`.
  ///
  /// Lamports for 15-min TURN access (default 5_000_000)
  final BigInt turnPrice;

  /// Value of the IDL field `signal_fee`.
  ///
  /// Fee per post_memo call (can be 0)
  final BigInt signalFee;

  /// Value of the IDL field `heartbeat_ttl`.
  ///
  /// Seconds before viewer expires without heartbeat (default 300)
  final BigInt heartbeatTtl;

  /// Value of the IDL field `min_heartbeat_interval`.
  ///
  /// Minimum seconds between heartbeats (rate limit, default 60)
  final BigInt minHeartbeatInterval;

  /// Value of the IDL field `bump`.
  ///
  /// PDA bump
  final int bump;

  /// Borsh codec for [SolsStreamProgramConfig].
  static final SolsStreamBorshCodec<SolsStreamProgramConfig> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamProgramConfig>(
        (reader) => SolsStreamProgramConfig(
          authority: reader.field(
            'authority',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          serviceWallet: reader.field(
            'service_wallet',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          turnPrice: reader.field('turn_price', () => reader.readUnsigned(8)),
          signalFee: reader.field('signal_fee', () => reader.readUnsigned(8)),
          heartbeatTtl: reader.field(
            'heartbeat_ttl',
            () => reader.readUnsigned(8),
          ),
          minHeartbeatInterval: reader.field(
            'min_heartbeat_interval',
            () => reader.readUnsigned(8),
          ),
          bump: reader.field('bump', () => reader.readInt(1)),
        ),
        (writer, value) {
          writer.writeBytes(value.authority.bytes);
          writer.writeBytes(value.serviceWallet.bytes);
          writer.writeUnsigned(value.turnPrice, 8);
          writer.writeUnsigned(value.signalFee, 8);
          writer.writeUnsigned(value.heartbeatTtl, 8);
          writer.writeUnsigned(value.minHeartbeatInterval, 8);
          writer.writeUnsigned(BigInt.from(value.bump), 1);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamProgramConfig &&
          authority == other.authority &&
          serviceWallet == other.serviceWallet &&
          turnPrice == other.turnPrice &&
          signalFee == other.signalFee &&
          heartbeatTtl == other.heartbeatTtl &&
          minHeartbeatInterval == other.minHeartbeatInterval &&
          bump == other.bump);

  @override
  int get hashCode => Object.hashAll([
    authority.hashCode,
    serviceWallet.hashCode,
    turnPrice.hashCode,
    signalFee.hashCode,
    heartbeatTtl.hashCode,
    minHeartbeatInterval.hashCode,
    bump.hashCode,
  ]);
}

/// Immutable Borsh value for `Room`.
final class SolsStreamRoom {
  /// Creates a validated immutable value.
  SolsStreamRoom({
    required this.isLive,
    required this.accessMode,
    required this.category,
    required this.connectionMode,
    required this.bump,
    required this.host,
    required this.nonce,
    required this.startedAt,
    required this.endedAt,
    required this.viewerCount,
    required this.totalViewers,
    required this.pricePerMinute,
    required this.totalEarned,
    required this.depositLamports,
    required this.pricePerSession,
    required this.title,
  });

  /// Value of the IDL field `is_live`.
  final bool isLive;

  /// Value of the IDL field `access_mode`.
  final SolsStreamAccessMode accessMode;

  /// Value of the IDL field `category`.
  final SolsStreamRoomCategory category;

  /// Value of the IDL field `connection_mode`.
  final SolsStreamConnectionMode connectionMode;

  /// Value of the IDL field `bump`.
  final int bump;

  /// Value of the IDL field `host`.
  ///
  /// Host wallet
  final SolsStreamAddress host;

  /// Value of the IDL field `nonce`.
  ///
  /// Incrementing nonce per host
  final BigInt nonce;

  /// Value of the IDL field `started_at`.
  ///
  /// Lifecycle
  final BigInt startedAt;

  /// Value of the IDL field `ended_at`.
  final BigInt endedAt;

  /// Value of the IDL field `viewer_count`.
  ///
  /// Counters
  final int viewerCount;

  /// Value of the IDL field `total_viewers`.
  final int totalViewers;

  /// Value of the IDL field `price_per_minute`.
  ///
  /// Payments (Phase 3)
  final BigInt pricePerMinute;

  /// Value of the IDL field `total_earned`.
  final BigInt totalEarned;

  /// Value of the IDL field `deposit_lamports`.
  ///
  /// ConnectSlot deposit set by the host at room creation. Both the host's
  /// `open_connect_slot` and the viewer's `claim_connect_slot` must pass
  /// this exact value — guards against malicious clients submitting trivial
  /// deposits and skipping the WebRTC escrow.
  final BigInt depositLamports;

  /// Value of the IDL field `price_per_session`.
  ///
  /// Phase 1 PfA flat-rate price per ConnectSlot session (lamports).
  /// Set at create_room. 0 = free room (default). Read at claim_connect_slot
  /// time and snapshotted into slot.access_price.
  final BigInt pricePerSession;

  /// Value of the IDL field `title`.
  ///
  /// Room title (max 64 bytes, UTF-8)
  final String title;

  /// Borsh codec for [SolsStreamRoom].
  static final SolsStreamBorshCodec<SolsStreamRoom>
  codec = SolsStreamFunctionalBorshCodec<SolsStreamRoom>(
    (reader) => SolsStreamRoom(
      isLive: reader.field('is_live', () => reader.readBool()),
      accessMode: reader.field(
        'access_mode',
        () => reader.nested(() => SolsStreamAccessMode.codec.read(reader)),
      ),
      category: reader.field(
        'category',
        () => reader.nested(() => SolsStreamRoomCategory.codec.read(reader)),
      ),
      connectionMode: reader.field(
        'connection_mode',
        () => reader.nested(() => SolsStreamConnectionMode.codec.read(reader)),
      ),
      bump: reader.field('bump', () => reader.readInt(1)),
      host: reader.field(
        'host',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      nonce: reader.field('nonce', () => reader.readUnsigned(8)),
      startedAt: reader.field('started_at', () => reader.readSigned(8)),
      endedAt: reader.field('ended_at', () => reader.readSigned(8)),
      viewerCount: reader.field('viewer_count', () => reader.readInt(4)),
      totalViewers: reader.field('total_viewers', () => reader.readInt(4)),
      pricePerMinute: reader.field(
        'price_per_minute',
        () => reader.readUnsigned(8),
      ),
      totalEarned: reader.field('total_earned', () => reader.readUnsigned(8)),
      depositLamports: reader.field(
        'deposit_lamports',
        () => reader.readUnsigned(8),
      ),
      pricePerSession: reader.field(
        'price_per_session',
        () => reader.readUnsigned(8),
      ),
      title: reader.field('title', () => reader.readString()),
    ),
    (writer, value) {
      writer.writeBool(value.isLive);
      SolsStreamAccessMode.codec.write(writer, value.accessMode);
      SolsStreamRoomCategory.codec.write(writer, value.category);
      SolsStreamConnectionMode.codec.write(writer, value.connectionMode);
      writer.writeUnsigned(BigInt.from(value.bump), 1);
      writer.writeBytes(value.host.bytes);
      writer.writeUnsigned(value.nonce, 8);
      writer.writeSigned(value.startedAt, 8);
      writer.writeSigned(value.endedAt, 8);
      writer.writeUnsigned(BigInt.from(value.viewerCount), 4);
      writer.writeUnsigned(BigInt.from(value.totalViewers), 4);
      writer.writeUnsigned(value.pricePerMinute, 8);
      writer.writeUnsigned(value.totalEarned, 8);
      writer.writeUnsigned(value.depositLamports, 8);
      writer.writeUnsigned(value.pricePerSession, 8);
      writer.writeString(value.title);
    },
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamRoom &&
          isLive == other.isLive &&
          accessMode == other.accessMode &&
          category == other.category &&
          connectionMode == other.connectionMode &&
          bump == other.bump &&
          host == other.host &&
          nonce == other.nonce &&
          startedAt == other.startedAt &&
          endedAt == other.endedAt &&
          viewerCount == other.viewerCount &&
          totalViewers == other.totalViewers &&
          pricePerMinute == other.pricePerMinute &&
          totalEarned == other.totalEarned &&
          depositLamports == other.depositLamports &&
          pricePerSession == other.pricePerSession &&
          title == other.title);

  @override
  int get hashCode => Object.hashAll([
    isLive.hashCode,
    accessMode.hashCode,
    category.hashCode,
    connectionMode.hashCode,
    bump.hashCode,
    host.hashCode,
    nonce.hashCode,
    startedAt.hashCode,
    endedAt.hashCode,
    viewerCount.hashCode,
    totalViewers.hashCode,
    pricePerMinute.hashCode,
    totalEarned.hashCode,
    depositLamports.hashCode,
    pricePerSession.hashCode,
    title.hashCode,
  ]);
}

/// Sealed immutable representation of `RoomCategory`.
sealed class SolsStreamRoomCategory {
  /// Creates an enum variant.
  const SolsStreamRoomCategory();

  /// Borsh codec for [SolsStreamRoomCategory].
  static final SolsStreamBorshCodec<SolsStreamRoomCategory> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamRoomCategory>(
        (reader) {
          final tag = reader.readInt(1);
          return switch (tag) {
            0 => SolsStreamRoomCategoryGeneral(),
            1 => SolsStreamRoomCategoryGaming(),
            2 => SolsStreamRoomCategoryMusic(),
            3 => SolsStreamRoomCategoryEducation(),
            4 => SolsStreamRoomCategoryTech(),
            5 => SolsStreamRoomCategoryArt(),
            6 => SolsStreamRoomCategorySocial(),
            7 => SolsStreamRoomCategoryOther(),
            _ => throw SolsStreamBorshException(
              code: 'BORSH_ENUM_TAG',
              message: 'Invalid enum tag.',
              offset: reader.offset - 1,
              path: r'\$',
            ),
          };
        },
        (writer, value) {
          switch (value) {
            case SolsStreamRoomCategoryGeneral():
              writer.writeUnsigned(BigInt.from(0), 1);
            case SolsStreamRoomCategoryGaming():
              writer.writeUnsigned(BigInt.from(1), 1);
            case SolsStreamRoomCategoryMusic():
              writer.writeUnsigned(BigInt.from(2), 1);
            case SolsStreamRoomCategoryEducation():
              writer.writeUnsigned(BigInt.from(3), 1);
            case SolsStreamRoomCategoryTech():
              writer.writeUnsigned(BigInt.from(4), 1);
            case SolsStreamRoomCategoryArt():
              writer.writeUnsigned(BigInt.from(5), 1);
            case SolsStreamRoomCategorySocial():
              writer.writeUnsigned(BigInt.from(6), 1);
            case SolsStreamRoomCategoryOther():
              writer.writeUnsigned(BigInt.from(7), 1);
          }
        },
      );
}

/// The `General` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryGeneral extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryGeneral();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryGeneral);

  @override
  int get hashCode => Object.hashAll([0]);
}

/// The `Gaming` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryGaming extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryGaming();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryGaming);

  @override
  int get hashCode => Object.hashAll([1]);
}

/// The `Music` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryMusic extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryMusic();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryMusic);

  @override
  int get hashCode => Object.hashAll([2]);
}

/// The `Education` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryEducation extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryEducation();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryEducation);

  @override
  int get hashCode => Object.hashAll([3]);
}

/// The `Tech` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryTech extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryTech();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryTech);

  @override
  int get hashCode => Object.hashAll([4]);
}

/// The `Art` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryArt extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryArt();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryArt);

  @override
  int get hashCode => Object.hashAll([5]);
}

/// The `Social` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategorySocial extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategorySocial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategorySocial);

  @override
  int get hashCode => Object.hashAll([6]);
}

/// The `Other` variant of [SolsStreamRoomCategory].
final class SolsStreamRoomCategoryOther extends SolsStreamRoomCategory {
  /// Creates the unit value.
  const SolsStreamRoomCategoryOther();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamRoomCategoryOther);

  @override
  int get hashCode => Object.hashAll([7]);
}

/// Immutable Borsh value for `RoomCleanedUp`.
final class SolsStreamRoomCleanedUp {
  /// Creates a validated immutable value.
  SolsStreamRoomCleanedUp({
    required this.room,
    required this.host,
    required this.cleaner,
    required this.rentReward,
  });

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Value of the IDL field `cleaner`.
  final SolsStreamAddress cleaner;

  /// Value of the IDL field `rent_reward`.
  final BigInt rentReward;

  /// Borsh codec for [SolsStreamRoomCleanedUp].
  static final SolsStreamBorshCodec<SolsStreamRoomCleanedUp> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamRoomCleanedUp>(
        (reader) => SolsStreamRoomCleanedUp(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          cleaner: reader.field(
            'cleaner',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          rentReward: reader.field('rent_reward', () => reader.readUnsigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.host.bytes);
          writer.writeBytes(value.cleaner.bytes);
          writer.writeUnsigned(value.rentReward, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamRoomCleanedUp &&
          room == other.room &&
          host == other.host &&
          cleaner == other.cleaner &&
          rentReward == other.rentReward);

  @override
  int get hashCode => Object.hashAll([
    room.hashCode,
    host.hashCode,
    cleaner.hashCode,
    rentReward.hashCode,
  ]);
}

/// Immutable Borsh value for `RoomClosed`.
final class SolsStreamRoomClosed {
  /// Creates a validated immutable value.
  SolsStreamRoomClosed({required this.room, required this.host});

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Borsh codec for [SolsStreamRoomClosed].
  static final SolsStreamBorshCodec<SolsStreamRoomClosed> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamRoomClosed>(
        (reader) => SolsStreamRoomClosed(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.host.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamRoomClosed &&
          room == other.room &&
          host == other.host);

  @override
  int get hashCode => Object.hashAll([room.hashCode, host.hashCode]);
}

/// Immutable Borsh value for `RoomCreated`.
final class SolsStreamRoomCreated {
  /// Creates a validated immutable value.
  SolsStreamRoomCreated({
    required this.room,
    required this.host,
    required this.nonce,
    required this.title,
  });

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Value of the IDL field `nonce`.
  final BigInt nonce;

  /// Value of the IDL field `title`.
  final String title;

  /// Borsh codec for [SolsStreamRoomCreated].
  static final SolsStreamBorshCodec<SolsStreamRoomCreated> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamRoomCreated>(
        (reader) => SolsStreamRoomCreated(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          nonce: reader.field('nonce', () => reader.readUnsigned(8)),
          title: reader.field('title', () => reader.readString()),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.host.bytes);
          writer.writeUnsigned(value.nonce, 8);
          writer.writeString(value.title);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamRoomCreated &&
          room == other.room &&
          host == other.host &&
          nonce == other.nonce &&
          title == other.title);

  @override
  int get hashCode => Object.hashAll([
    room.hashCode,
    host.hashCode,
    nonce.hashCode,
    title.hashCode,
  ]);
}

/// Immutable Borsh value for `RoomEnded`.
final class SolsStreamRoomEnded {
  /// Creates a validated immutable value.
  SolsStreamRoomEnded({required this.room, required this.host});

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `host`.
  final SolsStreamAddress host;

  /// Borsh codec for [SolsStreamRoomEnded].
  static final SolsStreamBorshCodec<SolsStreamRoomEnded> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamRoomEnded>(
        (reader) => SolsStreamRoomEnded(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          host: reader.field(
            'host',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.host.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamRoomEnded &&
          room == other.room &&
          host == other.host);

  @override
  int get hashCode => Object.hashAll([room.hashCode, host.hashCode]);
}

/// Immutable Borsh value for `SlotCleanedUp`.
final class SolsStreamSlotCleanedUp {
  /// Creates a validated immutable value.
  SolsStreamSlotCleanedUp({
    required this.slot,
    required this.cleaner,
    required this.rentReward,
  });

  /// Value of the IDL field `slot`.
  final SolsStreamAddress slot;

  /// Value of the IDL field `cleaner`.
  final SolsStreamAddress cleaner;

  /// Value of the IDL field `rent_reward`.
  final BigInt rentReward;

  /// Borsh codec for [SolsStreamSlotCleanedUp].
  static final SolsStreamBorshCodec<SolsStreamSlotCleanedUp> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamSlotCleanedUp>(
        (reader) => SolsStreamSlotCleanedUp(
          slot: reader.field(
            'slot',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          cleaner: reader.field(
            'cleaner',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          rentReward: reader.field('rent_reward', () => reader.readUnsigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.slot.bytes);
          writer.writeBytes(value.cleaner.bytes);
          writer.writeUnsigned(value.rentReward, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamSlotCleanedUp &&
          slot == other.slot &&
          cleaner == other.cleaner &&
          rentReward == other.rentReward);

  @override
  int get hashCode =>
      Object.hashAll([slot.hashCode, cleaner.hashCode, rentReward.hashCode]);
}

/// Sealed immutable representation of `SlotState`.
sealed class SolsStreamSlotState {
  /// Creates an enum variant.
  const SolsStreamSlotState();

  /// Borsh codec for [SolsStreamSlotState].
  static final SolsStreamBorshCodec<SolsStreamSlotState> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamSlotState>(
        (reader) {
          final tag = reader.readInt(1);
          return switch (tag) {
            0 => SolsStreamSlotStateOpen(),
            1 => SolsStreamSlotStateClaimed(),
            2 => SolsStreamSlotStateOfferReady(),
            3 => SolsStreamSlotStateAnswerReady(),
            4 => SolsStreamSlotStateConnected(),
            5 => SolsStreamSlotStateExpired(),
            _ => throw SolsStreamBorshException(
              code: 'BORSH_ENUM_TAG',
              message: 'Invalid enum tag.',
              offset: reader.offset - 1,
              path: r'\$',
            ),
          };
        },
        (writer, value) {
          switch (value) {
            case SolsStreamSlotStateOpen():
              writer.writeUnsigned(BigInt.from(0), 1);
            case SolsStreamSlotStateClaimed():
              writer.writeUnsigned(BigInt.from(1), 1);
            case SolsStreamSlotStateOfferReady():
              writer.writeUnsigned(BigInt.from(2), 1);
            case SolsStreamSlotStateAnswerReady():
              writer.writeUnsigned(BigInt.from(3), 1);
            case SolsStreamSlotStateConnected():
              writer.writeUnsigned(BigInt.from(4), 1);
            case SolsStreamSlotStateExpired():
              writer.writeUnsigned(BigInt.from(5), 1);
          }
        },
      );
}

/// The `Open` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateOpen extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateOpen();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateOpen);

  @override
  int get hashCode => Object.hashAll([0]);
}

/// The `Claimed` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateClaimed extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateClaimed();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateClaimed);

  @override
  int get hashCode => Object.hashAll([1]);
}

/// The `OfferReady` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateOfferReady extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateOfferReady();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateOfferReady);

  @override
  int get hashCode => Object.hashAll([2]);
}

/// The `AnswerReady` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateAnswerReady extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateAnswerReady();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateAnswerReady);

  @override
  int get hashCode => Object.hashAll([3]);
}

/// The `Connected` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateConnected extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateConnected();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateConnected);

  @override
  int get hashCode => Object.hashAll([4]);
}

/// The `Expired` variant of [SolsStreamSlotState].
final class SolsStreamSlotStateExpired extends SolsStreamSlotState {
  /// Creates the unit value.
  const SolsStreamSlotStateExpired();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamSlotStateExpired);

  @override
  int get hashCode => Object.hashAll([5]);
}

/// Immutable Borsh value for `TurnPurchased`.
final class SolsStreamTurnPurchased {
  /// Creates a validated immutable value.
  SolsStreamTurnPurchased({
    required this.user,
    required this.turnExpiresAt,
    required this.price,
  });

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `turn_expires_at`.
  final BigInt turnExpiresAt;

  /// Value of the IDL field `price`.
  final BigInt price;

  /// Borsh codec for [SolsStreamTurnPurchased].
  static final SolsStreamBorshCodec<SolsStreamTurnPurchased> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamTurnPurchased>(
        (reader) => SolsStreamTurnPurchased(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          turnExpiresAt: reader.field(
            'turn_expires_at',
            () => reader.readSigned(8),
          ),
          price: reader.field('price', () => reader.readUnsigned(8)),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeSigned(value.turnExpiresAt, 8);
          writer.writeUnsigned(value.price, 8);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamTurnPurchased &&
          user == other.user &&
          turnExpiresAt == other.turnExpiresAt &&
          price == other.price);

  @override
  int get hashCode =>
      Object.hashAll([user.hashCode, turnExpiresAt.hashCode, price.hashCode]);
}

/// Immutable Borsh value for `User`.
final class SolsStreamUser {
  /// Creates a validated immutable value.
  SolsStreamUser({
    required this.authority,
    required this.nickname,
    required this.role,
    required this.room,
    required this.connectedTo,
    required this.lastHeartbeat,
    required this.expiresAt,
    required this.turnExpiresAt,
    required this.streamCount,
    required this.totalEarned,
    required this.createdAt,
    required this.bump,
  });

  /// Value of the IDL field `authority`.
  ///
  /// Wallet that owns this account
  final SolsStreamAddress authority;

  /// Value of the IDL field `nickname`.
  ///
  /// Display name (max 32 bytes, UTF-8)
  final String nickname;

  /// Value of the IDL field `role`.
  ///
  /// Current role
  final SolsStreamUserRole role;

  /// Value of the IDL field `room`.
  ///
  /// Room PDA if in a room (Pubkey::default() if Idle)
  final SolsStreamAddress room;

  /// Value of the IDL field `connected_to`.
  ///
  /// Who this user is connected to
  final SolsStreamAddress connectedTo;

  /// Value of the IDL field `last_heartbeat`.
  ///
  /// Last heartbeat timestamp (unix seconds)
  final BigInt lastHeartbeat;

  /// Value of the IDL field `expires_at`.
  ///
  /// When this user expires (last_heartbeat + config.heartbeat_ttl)
  final BigInt expiresAt;

  /// Value of the IDL field `turn_expires_at`.
  ///
  /// TURN access expiry (0 = no active TURN)
  final BigInt turnExpiresAt;

  /// Value of the IDL field `stream_count`.
  ///
  /// Number of streams hosted
  final int streamCount;

  /// Value of the IDL field `total_earned`.
  ///
  /// Total SOL earned (lamports)
  final BigInt totalEarned;

  /// Value of the IDL field `created_at`.
  ///
  /// Account creation timestamp
  final BigInt createdAt;

  /// Value of the IDL field `bump`.
  ///
  /// PDA bump
  final int bump;

  /// Borsh codec for [SolsStreamUser].
  static final SolsStreamBorshCodec<SolsStreamUser>
  codec = SolsStreamFunctionalBorshCodec<SolsStreamUser>(
    (reader) => SolsStreamUser(
      authority: reader.field(
        'authority',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      nickname: reader.field('nickname', () => reader.readString()),
      role: reader.field(
        'role',
        () => reader.nested(() => SolsStreamUserRole.codec.read(reader)),
      ),
      room: reader.field(
        'room',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      connectedTo: reader.field(
        'connected_to',
        () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
      ),
      lastHeartbeat: reader.field('last_heartbeat', () => reader.readSigned(8)),
      expiresAt: reader.field('expires_at', () => reader.readSigned(8)),
      turnExpiresAt: reader.field(
        'turn_expires_at',
        () => reader.readSigned(8),
      ),
      streamCount: reader.field('stream_count', () => reader.readInt(4)),
      totalEarned: reader.field('total_earned', () => reader.readUnsigned(8)),
      createdAt: reader.field('created_at', () => reader.readSigned(8)),
      bump: reader.field('bump', () => reader.readInt(1)),
    ),
    (writer, value) {
      writer.writeBytes(value.authority.bytes);
      writer.writeString(value.nickname);
      SolsStreamUserRole.codec.write(writer, value.role);
      writer.writeBytes(value.room.bytes);
      writer.writeBytes(value.connectedTo.bytes);
      writer.writeSigned(value.lastHeartbeat, 8);
      writer.writeSigned(value.expiresAt, 8);
      writer.writeSigned(value.turnExpiresAt, 8);
      writer.writeUnsigned(BigInt.from(value.streamCount), 4);
      writer.writeUnsigned(value.totalEarned, 8);
      writer.writeSigned(value.createdAt, 8);
      writer.writeUnsigned(BigInt.from(value.bump), 1);
    },
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamUser &&
          authority == other.authority &&
          nickname == other.nickname &&
          role == other.role &&
          room == other.room &&
          connectedTo == other.connectedTo &&
          lastHeartbeat == other.lastHeartbeat &&
          expiresAt == other.expiresAt &&
          turnExpiresAt == other.turnExpiresAt &&
          streamCount == other.streamCount &&
          totalEarned == other.totalEarned &&
          createdAt == other.createdAt &&
          bump == other.bump);

  @override
  int get hashCode => Object.hashAll([
    authority.hashCode,
    nickname.hashCode,
    role.hashCode,
    room.hashCode,
    connectedTo.hashCode,
    lastHeartbeat.hashCode,
    expiresAt.hashCode,
    turnExpiresAt.hashCode,
    streamCount.hashCode,
    totalEarned.hashCode,
    createdAt.hashCode,
    bump.hashCode,
  ]);
}

/// Immutable Borsh value for `UserCleanedUp`.
final class SolsStreamUserCleanedUp {
  /// Creates a validated immutable value.
  SolsStreamUserCleanedUp({required this.user, required this.cleaner});

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `cleaner`.
  final SolsStreamAddress cleaner;

  /// Borsh codec for [SolsStreamUserCleanedUp].
  static final SolsStreamBorshCodec<SolsStreamUserCleanedUp> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUserCleanedUp>(
        (reader) => SolsStreamUserCleanedUp(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          cleaner: reader.field(
            'cleaner',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeBytes(value.cleaner.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamUserCleanedUp &&
          user == other.user &&
          cleaner == other.cleaner);

  @override
  int get hashCode => Object.hashAll([user.hashCode, cleaner.hashCode]);
}

/// Immutable Borsh value for `UserClosed`.
final class SolsStreamUserClosed {
  /// Creates a validated immutable value.
  SolsStreamUserClosed({required this.user, required this.authority});

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `authority`.
  final SolsStreamAddress authority;

  /// Borsh codec for [SolsStreamUserClosed].
  static final SolsStreamBorshCodec<SolsStreamUserClosed> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUserClosed>(
        (reader) => SolsStreamUserClosed(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          authority: reader.field(
            'authority',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeBytes(value.authority.bytes);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamUserClosed &&
          user == other.user &&
          authority == other.authority);

  @override
  int get hashCode => Object.hashAll([user.hashCode, authority.hashCode]);
}

/// Immutable Borsh value for `UserCreated`.
final class SolsStreamUserCreated {
  /// Creates a validated immutable value.
  SolsStreamUserCreated({
    required this.user,
    required this.authority,
    required this.nickname,
  });

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `authority`.
  final SolsStreamAddress authority;

  /// Value of the IDL field `nickname`.
  final String nickname;

  /// Borsh codec for [SolsStreamUserCreated].
  static final SolsStreamBorshCodec<SolsStreamUserCreated> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUserCreated>(
        (reader) => SolsStreamUserCreated(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          authority: reader.field(
            'authority',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          nickname: reader.field('nickname', () => reader.readString()),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeBytes(value.authority.bytes);
          writer.writeString(value.nickname);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamUserCreated &&
          user == other.user &&
          authority == other.authority &&
          nickname == other.nickname);

  @override
  int get hashCode =>
      Object.hashAll([user.hashCode, authority.hashCode, nickname.hashCode]);
}

/// Immutable Borsh value for `UserProfileUpdated`.
final class SolsStreamUserProfileUpdated {
  /// Creates a validated immutable value.
  SolsStreamUserProfileUpdated({required this.user, required this.nickname});

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `nickname`.
  final String nickname;

  /// Borsh codec for [SolsStreamUserProfileUpdated].
  static final SolsStreamBorshCodec<SolsStreamUserProfileUpdated> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUserProfileUpdated>(
        (reader) => SolsStreamUserProfileUpdated(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          nickname: reader.field('nickname', () => reader.readString()),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeString(value.nickname);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamUserProfileUpdated &&
          user == other.user &&
          nickname == other.nickname);

  @override
  int get hashCode => Object.hashAll([user.hashCode, nickname.hashCode]);
}

/// Sealed immutable representation of `UserRole`.
sealed class SolsStreamUserRole {
  /// Creates an enum variant.
  const SolsStreamUserRole();

  /// Borsh codec for [SolsStreamUserRole].
  static final SolsStreamBorshCodec<SolsStreamUserRole> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamUserRole>(
        (reader) {
          final tag = reader.readInt(1);
          return switch (tag) {
            0 => SolsStreamUserRoleIdle(),
            1 => SolsStreamUserRoleHost(),
            2 => SolsStreamUserRoleViewer(),
            3 => SolsStreamUserRoleRelay(),
            _ => throw SolsStreamBorshException(
              code: 'BORSH_ENUM_TAG',
              message: 'Invalid enum tag.',
              offset: reader.offset - 1,
              path: r'\$',
            ),
          };
        },
        (writer, value) {
          switch (value) {
            case SolsStreamUserRoleIdle():
              writer.writeUnsigned(BigInt.from(0), 1);
            case SolsStreamUserRoleHost():
              writer.writeUnsigned(BigInt.from(1), 1);
            case SolsStreamUserRoleViewer():
              writer.writeUnsigned(BigInt.from(2), 1);
            case SolsStreamUserRoleRelay():
              writer.writeUnsigned(BigInt.from(3), 1);
          }
        },
      );
}

/// The `Idle` variant of [SolsStreamUserRole].
final class SolsStreamUserRoleIdle extends SolsStreamUserRole {
  /// Creates the unit value.
  const SolsStreamUserRoleIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamUserRoleIdle);

  @override
  int get hashCode => Object.hashAll([0]);
}

/// The `Host` variant of [SolsStreamUserRole].
final class SolsStreamUserRoleHost extends SolsStreamUserRole {
  /// Creates the unit value.
  const SolsStreamUserRoleHost();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamUserRoleHost);

  @override
  int get hashCode => Object.hashAll([1]);
}

/// The `Viewer` variant of [SolsStreamUserRole].
final class SolsStreamUserRoleViewer extends SolsStreamUserRole {
  /// Creates the unit value.
  const SolsStreamUserRoleViewer();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamUserRoleViewer);

  @override
  int get hashCode => Object.hashAll([2]);
}

/// The `Relay` variant of [SolsStreamUserRole].
final class SolsStreamUserRoleRelay extends SolsStreamUserRole {
  /// Creates the unit value.
  const SolsStreamUserRoleRelay();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SolsStreamUserRoleRelay);

  @override
  int get hashCode => Object.hashAll([3]);
}

/// Immutable Borsh value for `ViewerExpired`.
final class SolsStreamViewerExpired {
  /// Creates a validated immutable value.
  SolsStreamViewerExpired({
    required this.user,
    required this.room,
    required this.viewerCount,
  });

  /// Value of the IDL field `user`.
  final SolsStreamAddress user;

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `viewer_count`.
  final int viewerCount;

  /// Borsh codec for [SolsStreamViewerExpired].
  static final SolsStreamBorshCodec<SolsStreamViewerExpired> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamViewerExpired>(
        (reader) => SolsStreamViewerExpired(
          user: reader.field(
            'user',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewerCount: reader.field('viewer_count', () => reader.readInt(4)),
        ),
        (writer, value) {
          writer.writeBytes(value.user.bytes);
          writer.writeBytes(value.room.bytes);
          writer.writeUnsigned(BigInt.from(value.viewerCount), 4);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamViewerExpired &&
          user == other.user &&
          room == other.room &&
          viewerCount == other.viewerCount);

  @override
  int get hashCode =>
      Object.hashAll([user.hashCode, room.hashCode, viewerCount.hashCode]);
}

/// Immutable Borsh value for `ViewerJoined`.
final class SolsStreamViewerJoined {
  /// Creates a validated immutable value.
  SolsStreamViewerJoined({
    required this.room,
    required this.viewer,
    required this.viewerCount,
  });

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `viewer`.
  final SolsStreamAddress viewer;

  /// Value of the IDL field `viewer_count`.
  final int viewerCount;

  /// Borsh codec for [SolsStreamViewerJoined].
  static final SolsStreamBorshCodec<SolsStreamViewerJoined> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamViewerJoined>(
        (reader) => SolsStreamViewerJoined(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewer: reader.field(
            'viewer',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewerCount: reader.field('viewer_count', () => reader.readInt(4)),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.viewer.bytes);
          writer.writeUnsigned(BigInt.from(value.viewerCount), 4);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamViewerJoined &&
          room == other.room &&
          viewer == other.viewer &&
          viewerCount == other.viewerCount);

  @override
  int get hashCode =>
      Object.hashAll([room.hashCode, viewer.hashCode, viewerCount.hashCode]);
}

/// Immutable Borsh value for `ViewerLeft`.
final class SolsStreamViewerLeft {
  /// Creates a validated immutable value.
  SolsStreamViewerLeft({
    required this.room,
    required this.viewer,
    required this.viewerCount,
  });

  /// Value of the IDL field `room`.
  final SolsStreamAddress room;

  /// Value of the IDL field `viewer`.
  final SolsStreamAddress viewer;

  /// Value of the IDL field `viewer_count`.
  final int viewerCount;

  /// Borsh codec for [SolsStreamViewerLeft].
  static final SolsStreamBorshCodec<SolsStreamViewerLeft> codec =
      SolsStreamFunctionalBorshCodec<SolsStreamViewerLeft>(
        (reader) => SolsStreamViewerLeft(
          room: reader.field(
            'room',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewer: reader.field(
            'viewer',
            () => SolsStreamAddress.fromBytes(reader.readBytes(32)),
          ),
          viewerCount: reader.field('viewer_count', () => reader.readInt(4)),
        ),
        (writer, value) {
          writer.writeBytes(value.room.bytes);
          writer.writeBytes(value.viewer.bytes);
          writer.writeUnsigned(BigInt.from(value.viewerCount), 4);
        },
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolsStreamViewerLeft &&
          room == other.room &&
          viewer == other.viewer &&
          viewerCount == other.viewerCount);

  @override
  int get hashCode =>
      Object.hashAll([room.hashCode, viewer.hashCode, viewerCount.hashCode]);
}
