/// Parameters for creating an on-chain signaling room.
///
/// The sols.stream program's `create_room` instruction already carries room
/// economics — access mode, connection mode, and per-minute / per-session price.
/// Today the app only creates **public, free, P2P** rooms ([p2pFree]); this value
/// object is the single seam where that will change for the monetization roadmap
/// (paid / access-controlled / non-P2P rooms — see `docs/project/vision.md`).
///
/// Fields hold the program's raw encodings (u8 codes / lamports). Typed enums
/// for [accessMode]/[connectionMode]/[category] are deferred to the ticket that
/// actually implements the additional modes, when their full value space is known
/// (from the program IDL). Until then the unnamed constructor validates only what
/// is knowable without the IDL — the encoding ranges — so a malformed room (which
/// on mainnet spends real SOL) cannot be built or serialised.
class RoomCreationParams {
  /// Max byte length enforced on [title] to keep the `create_room` transaction
  /// within a sane size.
  static const int maxTitleLength = 64;

  /// Inclusive upper bound for the program's `u8` code fields.
  static const int maxU8 = 255;

  /// Room title (program `title`).
  final String title;

  /// Room category code (program `category`; `0` = General).
  final int category;

  /// Access mode code (program `access_mode`; `0` = Public).
  final int accessMode;

  /// Connection mode code (program `connection_mode`; `1` = P2P).
  final int connectionMode;

  /// Price per minute in lamports (program `price_per_minute`; `0` = free).
  final int pricePerMinute;

  /// Price per session in lamports (program `price_per_session`; `0` = free).
  final int pricePerSession;

  /// Creates room params, validating the program's encoding ranges. Throws
  /// [ArgumentError] if [title] is empty or too long, a code field is outside
  /// the `u8` range, or a price is negative.
  factory RoomCreationParams({
    required String title,
    required int category,
    required int accessMode,
    required int connectionMode,
    required int pricePerMinute,
    required int pricePerSession,
  }) {
    if (title.isEmpty || title.length > maxTitleLength) {
      throw ArgumentError.value(title, 'title', 'must be 1..$maxTitleLength chars');
    }
    _checkU8(category, 'category');
    _checkU8(accessMode, 'accessMode');
    _checkU8(connectionMode, 'connectionMode');
    _checkNonNegative(pricePerMinute, 'pricePerMinute');
    _checkNonNegative(pricePerSession, 'pricePerSession');

    return RoomCreationParams._(
      title: title,
      category: category,
      accessMode: accessMode,
      connectionMode: connectionMode,
      pricePerMinute: pricePerMinute,
      pricePerSession: pricePerSession,
    );
  }

  const RoomCreationParams._({
    required this.title,
    required this.category,
    required this.accessMode,
    required this.connectionMode,
    required this.pricePerMinute,
    required this.pricePerSession,
  });

  /// The current default: a public, free, P2P room — the app's only mode today.
  /// Built from known-valid constants, so it bypasses runtime validation.
  const RoomCreationParams.p2pFree()
    : this._(
        title: 'p2p',
        category: 0,
        accessMode: 0,
        connectionMode: 1,
        pricePerMinute: 0,
        pricePerSession: 0,
      );

  static void _checkU8(int value, String name) {
    if (value < 0 || value > maxU8) {
      throw ArgumentError.value(value, name, 'must be in 0..$maxU8');
    }
  }

  static void _checkNonNegative(int value, String name) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'must be non-negative');
    }
  }
}
