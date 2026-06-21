// sols_stream program client — manual instruction building
// No Anchor SDK dependency. Uses @solana/web3.js only.
// Loaded AFTER config.js, solana-common.js, and solana-web3.

(() => {
    'use strict';

    let _programId = null;
    let _programMode = 'memo';
    let _serviceWallet = null;

    // --- Anchor instruction discriminators (precomputed from IDL) ---
    // sha256("global:<instruction_name>")[0..8]
    // Values taken directly from the IDL at sols_stream.json

    const DISC = {
        initialize:          new Uint8Array([175, 175, 109, 31, 13, 152, 155, 237]),
        create_user:         new Uint8Array([108, 227, 130, 130, 252, 109, 75, 218]),
        update_profile:      new Uint8Array([98, 67, 99, 206, 86, 115, 175, 1]),
        close_user:          new Uint8Array([86, 219, 138, 140, 236, 24, 118, 200]),
        create_room:         new Uint8Array([130, 166, 32, 2, 247, 120, 178, 53]),
        end_room:            new Uint8Array([102, 106, 181, 155, 61, 17, 40, 78]),
        close_room:          new Uint8Array([152, 197, 88, 192, 98, 197, 51, 211]),
        join_room:           new Uint8Array([95, 232, 188, 81, 124, 130, 78, 139]),
        leave_room:          new Uint8Array([249, 42, 239, 128, 192, 20, 114, 156]),
        become_relay:        new Uint8Array([101, 244, 32, 158, 31, 72, 124, 238]),
        heartbeat:           new Uint8Array([202, 104, 56, 6, 240, 170, 63, 134]),
        expire_viewer:       new Uint8Array([188, 15, 41, 159, 21, 130, 243, 211]),
        post_memo:           new Uint8Array([201, 245, 220, 43, 59, 13, 178, 127]),
        purchase_turn:       new Uint8Array([188, 235, 133, 237, 250, 109, 124, 52]),
        open_connect_slot:   new Uint8Array([200, 199, 43, 201, 133, 53, 221, 183]),
        open_relay_slot:     new Uint8Array([237, 169, 69, 135, 47, 97, 35, 136]),
        claim_connect_slot:  new Uint8Array([110, 60, 180, 109, 39, 35, 5, 140]),
        write_offer:         new Uint8Array([50, 36, 220, 142, 101, 119, 205, 194]),
        write_answer:        new Uint8Array([229, 79, 107, 103, 29, 50, 93, 119]),
        close_connect_slot:  new Uint8Array([11, 246, 107, 98, 155, 124, 27, 192]),
        cleanup_expired_slot: new Uint8Array([47, 245, 123, 125, 160, 82, 36, 111]),
        cleanup_expired_slot_third_party: new Uint8Array([17, 128, 134, 184, 174, 144, 182, 83]),
        cleanup_stale_room:   new Uint8Array([197, 165, 55, 4, 228, 181, 208, 64]),
        cleanup_stale_user:   new Uint8Array([110, 83, 233, 184, 208, 207, 11, 177]),
        // Upgrade 07: connection verification (host+viewer flip flags after WebRTC connect).
        confirm_connection:  new Uint8Array([219, 162, 27, 145, 211, 2, 134, 122]),
    };

    // --- Account discriminators (from IDL, first 8 bytes of account data) ---
    const ACCOUNT_DISC = {
        User:          new Uint8Array([159, 117, 95, 227, 239, 151, 58, 236]),
        Room:          new Uint8Array([156, 199, 67, 27, 222, 23, 185, 94]),
        ProgramConfig: new Uint8Array([196, 210, 90, 231, 144, 149, 140, 63]),
        ConnectSlot:   new Uint8Array([97, 222, 119, 195, 143, 47, 180, 127]),
    };

    // --- Compute-unit reservations per instruction ---
    // Right-sized to observed real CU (typically <20k) plus safety margin.
    // Previously every tx requested 1_000_000 CU which inflates priority fees
    // and hurts block packing. Lookup by canonical Anchor ix name.
    const CU_PROFILE = {
        // tiny lifecycle / signaling ixs
        heartbeat:             30_000,
        post_memo:             30_000,
        leave_room:            30_000,
        become_relay:          30_000,
        expire_viewer:         30_000,
        update_profile:        30_000,
        close_user:            30_000,
        // medium ixs (transfers, room state changes)
        purchase_turn:         50_000,
        join_room:             50_000,
        end_room:              50_000,
        close_room:            50_000,
        close_connect_slot:    50_000,
        confirm_connection:    30_000,
        // account-create / open paths
        create_user:           80_000,
        create_room:           80_000,
        open_connect_slot:     80_000,
        claim_connect_slot:    80_000,
        open_relay_slot:       80_000,
        // realloc-heavy (Borsh deserialize + grow account by ~800 bytes)
        write_offer:          200_000,
        write_answer:         200_000,
        // account-close / cleanup paths
        cleanup_expired_slot:  60_000,
        cleanup_expired_slot_third_party: 60_000,
        cleanup_stale_room:    60_000,
        cleanup_stale_user:    60_000,
        // admin paths
        initialize:            80_000,
        update_config:         80_000,
        admin_force_close_room: 80_000,
    };
    const CU_FALLBACK = 80_000;

    // Only realloc-heavy ixs need the bumped 256KB heap. Default 32KB heap is
    // plenty for everything else, and skipping the requestHeapFrame ix saves
    // a tx instruction slot and ~150 CU.
    const REALLOC_HEAVY_SET = new Set(['write_offer', 'write_answer']);

    // --- Enum index maps ---
    const ROOM_CATEGORY = { General: 0, Gaming: 1, Music: 2, Education: 3, Tech: 4, Art: 5, Social: 6, Other: 7 };
    const ROOM_CATEGORY_REV = ['General', 'Gaming', 'Music', 'Education', 'Tech', 'Art', 'Social', 'Other'];
    const ACCESS_MODE = { Public: 0, Private: 1, Paid: 2 };
    const ACCESS_MODE_REV = ['Public', 'Private', 'Paid'];
    const CONNECTION_MODE = { Stream: 0, P2P: 1 };
    const CONNECTION_MODE_REV = ['stream', 'p2p'];
    const USER_ROLE = { Idle: 0, Host: 1, Viewer: 2, Relay: 3 };
    const USER_ROLE_REV = ['Idle', 'Host', 'Viewer', 'Relay'];
    const SLOT_STATE_REV = ['Open', 'Claimed', 'OfferReady', 'AnswerReady', 'Connected', 'Expired'];

    // --- Borsh serialization helpers (minimal subset) ---

    function serializeU8(n) {
        return new Uint8Array([n & 0xff]);
    }

    function serializeI64(n) {
        const buf = new ArrayBuffer(8);
        const view = new DataView(buf);
        view.setBigInt64(0, BigInt(n), true); // little-endian
        return new Uint8Array(buf);
    }

    function serializeU64(n) {
        const buf = new ArrayBuffer(8);
        const view = new DataView(buf);
        view.setBigUint64(0, BigInt(n), true); // little-endian
        return new Uint8Array(buf);
    }

    function serializeU32(n) {
        const buf = new ArrayBuffer(4);
        const view = new DataView(buf);
        view.setUint32(0, n, true);
        return new Uint8Array(buf);
    }

    function serializeBool(b) {
        return new Uint8Array([b ? 1 : 0]);
    }

    function serializeString(str) {
        const encoded = new TextEncoder().encode(str);
        const lenBuf = new ArrayBuffer(4);
        new DataView(lenBuf).setUint32(0, encoded.length, true);
        return concatBytes(new Uint8Array(lenBuf), encoded);
    }

    function serializeBytes(data) {
        // Borsh Vec<u8>: 4-byte LE length prefix + raw bytes
        const bytes = (data instanceof Uint8Array) ? data : new TextEncoder().encode(data);
        const lenBuf = new ArrayBuffer(4);
        new DataView(lenBuf).setUint32(0, bytes.length, true);
        return concatBytes(new Uint8Array(lenBuf), bytes);
    }

    function serializePubkey(pubkey) {
        return pubkey.toBuffer();
    }

    function concatBytes(/* ...arrays */) {
        const arrays = Array.from(arguments);
        let total = 0;
        for (let i = 0; i < arrays.length; i++) total += arrays[i].length;
        const result = new Uint8Array(total);
        let offset = 0;
        for (let i = 0; i < arrays.length; i++) {
            result.set(arrays[i], offset);
            offset += arrays[i].length;
        }
        return result;
    }

    // --- Borsh deserialization helpers ---

    function deserializeU8(data, offset) {
        return [data[offset], offset + 1];
    }

    function deserializeU32(data, offset) {
        const view = new DataView(data.buffer, data.byteOffset + offset, 4);
        return [view.getUint32(0, true), offset + 4];
    }

    function deserializeU64(data, offset) {
        const view = new DataView(data.buffer, data.byteOffset + offset, 8);
        return [view.getBigUint64(0, true), offset + 8];
    }

    function deserializeI64(data, offset) {
        const view = new DataView(data.buffer, data.byteOffset + offset, 8);
        return [view.getBigInt64(0, true), offset + 8];
    }

    function deserializeBool(data, offset) {
        return [data[offset] !== 0, offset + 1];
    }

    function deserializePubkey(data, offset) {
        const sw3 = window.solanaWeb3;
        const bytes = data.slice(offset, offset + 32);
        return [new sw3.PublicKey(bytes), offset + 32];
    }

    function deserializeString(data, offset) {
        const view = new DataView(data.buffer, data.byteOffset + offset, 4);
        const len = view.getUint32(0, true);
        const strBytes = data.slice(offset + 4, offset + 4 + len);
        return [new TextDecoder().decode(strBytes), offset + 4 + len];
    }

    function deserializeBytes(data, offset) {
        const view = new DataView(data.buffer, data.byteOffset + offset, 4);
        const len = view.getUint32(0, true);
        const bytes = data.slice(offset + 4, offset + 4 + len);
        return [bytes, offset + 4 + len];
    }

    // --- PDA derivation helpers ---

    function deriveUserPDA(walletPubkey) {
        const sw3 = window.solanaWeb3;
        return sw3.PublicKey.findProgramAddressSync(
            [new TextEncoder().encode('user'), walletPubkey.toBuffer()],
            _programId
        );
    }

    function deriveRoomPDA(hostPubkey, nonce) {
        const sw3 = window.solanaWeb3;
        return sw3.PublicKey.findProgramAddressSync(
            [new TextEncoder().encode('room'), hostPubkey.toBuffer(), serializeU64(nonce)],
            _programId
        );
    }

    function deriveConfigPDA() {
        const sw3 = window.solanaWeb3;
        return sw3.PublicKey.findProgramAddressSync(
            [new TextEncoder().encode('config')],
            _programId
        );
    }

    function deriveSlotPDA(roomPubkey, nonce) {
        const sw3 = window.solanaWeb3;
        return sw3.PublicKey.findProgramAddressSync(
            [new TextEncoder().encode('slot'), roomPubkey.toBuffer(), serializeU64(nonce)],
            _programId
        );
    }

    // --- Wallet/connection broker (no global signing oracle) ---
    // Providers are getter fns so the broker never holds a stale wallet snapshot.
    let _walletProvider = null;
    let _connectionProvider = null;

    function registerWalletProvider(getWallet, getConnection) {
        // Lock the signer after first registration: the getter reads the live wallet var,
        // so wallet switching still works without re-registering. Blocks XSS signer swap.
        if (typeof getWallet === 'function' && !_walletProvider) _walletProvider = getWallet;
        if (typeof getConnection === 'function') _connectionProvider = getConnection;
    }

    function getActivePublicKey() {
        const w = _walletProvider ? _walletProvider() : null;
        return w && w.publicKey ? w.publicKey : null;
    }

    function _getConn() {
        return _connectionProvider ? _connectionProvider() : null;
    }

    function _getWallet() {
        return _walletProvider ? _walletProvider() : null;
    }

    // --- Instruction builders ---

    /**
     * Build and send a single instruction as a transaction.
     * Uses the global `connection` and `wallet` from solana-common.js.
     */
    let _bhCache = { hash: null, ts: 0 };
    const _BH_TTL = 30_000; // cache blockhash for 30s (valid ~60s on Solana)
    async function _getCachedBlockhash(conn) {
        if (_bhCache.hash && (Date.now() - _bhCache.ts < _BH_TTL)) return _bhCache.hash;
        const { blockhash } = await conn.getLatestBlockhash('processed');
        _bhCache = { hash: blockhash, ts: Date.now() };
        return blockhash;
    }

    // --- Anchor error mapping and formatting ---
    const SOLS_ERROR_NAMES = {
        6000: 'NicknameTooLong',
        6001: 'TitleTooLong',
        6002: 'UserNotIdle',
        6003: 'NotInRoom',
        6004: 'NotViewer',
        6005: 'RoomNotLive',
        6006: 'RoomAlreadyEnded',
        6007: 'RoomHasViewers',
        6008: 'RoomMismatch',
        6009: 'NotHost',
        6010: 'NotExpired',
        6011: 'TooFrequent',
        6012: 'DataTooLarge',
        6013: 'Unauthorized',
        6014: 'InvalidSlotState',
        6015: 'SlotExpired',
        6016: 'SlotNotExpired',
        6017: 'ProtectedKeyTooLong',
        6018: 'SdpDataTooLong',
        6019: 'ZeroDeposit',
        6020: 'ZeroExpiry',
        6021: 'NotRelay',
        6022: 'HostStillActive',
        6023: 'DepositMismatch',
        6024: 'InsufficientFunds',
        6025: 'NotStaleEnough',
        6026: 'IsHostOrViewer',
        6027: 'NotConnected',
        6028: 'RentSplitOverflow',
        6029: 'AlreadyConfirmed',
        6030: 'HostingLiveRoom',
        6031: 'RoomStillLive',
        6032: 'SlotConnected',
    };

    function extractAnchorErrorNumber(message, logs) {
        const haystack = `${message}\n${(logs || []).join('\n')}`;
        const numMatch = haystack.match(/Error Number:\s*(\d+)/);
        if (numMatch) {
            const n = parseInt(numMatch[1], 10);
            if (Number.isFinite(n)) return n;
        }
        const hexMatch = haystack.match(/custom program error:\s*0x([0-9a-fA-F]+)/);
        if (hexMatch) {
            const n = parseInt(hexMatch[1], 16);
            if (Number.isFinite(n)) return n;
        }
        return null;
    }

    /**
     * Send a single instruction as a transaction.
     *
     * @param {TransactionInstruction} ix      built ix to send
     * @param {string|null} laneId             optional throttle lane (used for parallel chunk writes)
     * @param {object} [opts]
     * @param {number} [opts.cuLimit]          override CU; falls back to CU_PROFILE[ix._ixName] then CU_FALLBACK
     * @param {boolean} [opts.requestHeap]     prepend requestHeapFrame(256KB); default false
     */
    async function sendInstruction(ix, laneId, opts) {
        const sw3 = window.solanaWeb3;
        const w = _getWallet();
        if (!w) throw new Error('Solana not initialized');

        const options = opts || {};
        const ixName = (ix && ix._ixName) || null;
        const cuLimit = (typeof options.cuLimit === 'number' && options.cuLimit > 0)
            ? options.cuLimit
            : (ixName && CU_PROFILE[ixName]) || CU_FALLBACK;
        const requestHeap = options.requestHeap === true
            || (!!ixName && REALLOC_HEAVY_SET.has(ixName));

        // Use lane-specific connection for parallel chunk writes
        let conn;
        if (laneId && window.throttledFetch) {
            const CFG = window.SOLS_CONFIG || {};
            const rpcUrl = CFG.RPC_ENDPOINTS?.[window._solanaNetwork || 'localnet'] || 'http://localhost:8899';
            conn = new sw3.Connection(rpcUrl, {
                commitment: 'confirmed',
                disableRetryOnRateLimit: true,
                fetch: (url, opts) => window.throttledFetch(url, opts, laneId),
            });
        } else {
            conn = _getConn();
        }
        if (!conn) throw new Error('Solana not initialized');

        // Retry on blockhash expiry or simulation failure (up to 3 attempts)
        for (let attempt = 0; attempt < 3; attempt++) {
            try {
                const tx = new sw3.Transaction();
                tx.recentBlockhash = await _getCachedBlockhash(conn);
                tx.feePayer = w.publicKey;
                tx.add(sw3.ComputeBudgetProgram.setComputeUnitLimit({ units: cuLimit }));
                if (requestHeap) {
                    tx.add(sw3.ComputeBudgetProgram.requestHeapFrame({ bytes: 256 * 1024 }));
                }
                tx.add(ix);

                const signed = await w.signAllTransactions([tx]);
                const sig = await conn.sendRawTransaction(signed[0].serialize(), { skipPreflight: false });
                await conn.confirmTransaction(sig, 'confirmed');
                return sig;
            } catch (e) {
                const msg = e.message || '';
                if (attempt < 2 && (msg.includes('Blockhash not found') || msg.includes('block height exceeded'))) {
                    _bhCache = { hash: null, ts: 0 };
                    console.warn(`[sendInstruction] Blockhash expired (attempt ${attempt + 1}), refreshing...`);
                    continue;
                }
                if (attempt < 2 && msg.includes('simulation failed')) {
                    // Simulation may fail due to stale blockhash or transient state — retry once with fresh blockhash
                    _bhCache = { hash: null, ts: 0 };
                    console.warn(`[sendInstruction] Simulation failed (attempt ${attempt + 1}), retrying with fresh blockhash...`);
                    await new Promise(r => setTimeout(r, 500));
                    continue;
                }
                const anchorCode = extractAnchorErrorNumber(msg, e.logs);
                if (anchorCode !== null) {
                    const name = SOLS_ERROR_NAMES[anchorCode];
                    const formattedName = name ? `${name} (0x${anchorCode.toString(16)})` : `ANCHOR_ERROR_${anchorCode} (0x${anchorCode.toString(16)})`;
                    const customMsg = `${msg} [Anchor Error: ${formattedName}]`;
                    try {
                        e.message = customMsg;
                    } catch (_) {
                        const newErr = new Error(customMsg);
                        newErr.logs = e.logs;
                        newErr.anchorCode = anchorCode;
                        throw newErr;
                    }
                }
                throw e;
            }
        }
    }

    // ========================= post_memo =========================

    /**
     * post_memo — replacement for the SPL Memo program.
     * Accounts: sender (signer, mut), service_wallet (mut), config (PDA), system_program
     * Args: data (bytes / Vec<u8>)
     */
    function buildPostMemoInstruction(senderPubkey, dataBytes) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        if (!_serviceWallet) throw new Error('Service wallet not configured');

        const [configPDA] = deriveConfigPDA();

        const ixData = concatBytes(
            DISC.post_memo,
            serializeBytes(dataBytes)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: senderPubkey, isSigner: true, isWritable: true },
                { pubkey: _serviceWallet, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'post_memo';
        return ix;
    }

    async function postMemo(data) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const dataBytes = (typeof data === 'string') ? new TextEncoder().encode(data) : data;
        const ix = buildPostMemoInstruction(w.publicKey, dataBytes);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.post_memo });
    }

    // ========================= create_user =========================

    /**
     * create_user(nickname)
     * Accounts: authority (signer, mut), user PDA (mut), system_program
     * Args: nickname (string)
     */
    function buildCreateUserInstruction(authorityPubkey, nickname) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [userPDA] = deriveUserPDA(authorityPubkey);
        const ixData = concatBytes(DISC.create_user, serializeString(nickname));

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: authorityPubkey, isSigner: true, isWritable: true },
                { pubkey: userPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'create_user';
        return ix;
    }

    async function createUser(nickname) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildCreateUserInstruction(w.publicKey, nickname);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.create_user });
    }

    // ========================= update_profile =========================

    /**
     * update_profile(nickname)
     * Accounts: authority (signer, relations: user), user PDA (mut)
     * Args: nickname (string)
     */
    function buildUpdateProfileInstruction(authorityPubkey, nickname) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [userPDA] = deriveUserPDA(authorityPubkey);
        const ixData = concatBytes(DISC.update_profile, serializeString(nickname));

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: authorityPubkey, isSigner: true, isWritable: false },
                { pubkey: userPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'update_profile';
        return ix;
    }

    async function updateProfile(nickname) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildUpdateProfileInstruction(w.publicKey, nickname);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.update_profile });
    }

    // ========================= close_user =========================

    /**
     * close_user()
     * Accounts: authority (signer, mut, relations: user), user PDA (mut)
     */
    function buildCloseUserInstruction(authorityPubkey) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [userPDA] = deriveUserPDA(authorityPubkey);

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: authorityPubkey, isSigner: true, isWritable: true },
                { pubkey: userPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.close_user,
        });
        ix._ixName = 'close_user';
        return ix;
    }

    async function closeUser() {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildCloseUserInstruction(w.publicKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.close_user });
    }

    // ========================= create_room =========================

    /**
     * create_room(title, category, access_mode, price_per_minute, price_per_session, deposit_lamports, nonce)
     * Accounts: host (signer, mut), host_user PDA (mut), room PDA (mut), system_program
     * Args: title (string), category (enum u8), access_mode (enum u8), connection_mode (enum u8),
     *       price_per_minute (u64), price_per_session (u64), deposit_lamports (u64), nonce (u64)
     *
     * `depositLamports` is the per-room ConnectSlot deposit pinned at room
     * creation time. Both `open_connect_slot` and `claim_connect_slot` validate
     * their passed value against this on-chain field, so it must be > 0.
     *
     * `pricePerSession` is the Phase 1 Pay-for-Access flat fee snapshotted into
     * `slot.access_price` at claim time. 0 = free room.
     */
    function buildCreateRoomInstruction(hostPubkey, title, category, accessMode, connectionMode, pricePerMinute, depositLamports, pricePerSession, nonce) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [hostUserPDA] = deriveUserPDA(hostPubkey);
        const [roomPDA] = deriveRoomPDA(hostPubkey, nonce);

        const categoryIdx = (typeof category === 'number') ? category : (ROOM_CATEGORY[category] || 0);
        const accessIdx = (typeof accessMode === 'number') ? accessMode : (ACCESS_MODE[accessMode] || 0);
        const connModeIdx = (typeof connectionMode === 'number') ? connectionMode : (CONNECTION_MODE[connectionMode] || 0);

        // IDL arg order: title, category, access_mode, connection_mode,
        // price_per_minute, price_per_session, deposit_lamports, nonce.
        const ixData = concatBytes(
            DISC.create_room,
            serializeString(title),
            serializeU8(categoryIdx),
            serializeU8(accessIdx),
            serializeU8(connModeIdx),
            serializeU64(pricePerMinute),
            serializeU64(pricePerSession),
            serializeU64(depositLamports),
            serializeU64(nonce)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: true },
                { pubkey: hostUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'create_room';
        return ix;
    }

    /**
     * createRoom — high-level wrapper.
     *
     * @param {number} [depositLamports]  Per-room ConnectSlot deposit. Defaults
     *   to `SOLS_CONFIG.CONNECT_SLOT_DEPOSIT_LAMPORTS` (1_000_000 = 0.001 SOL).
     *   Once the room is created, this value is the on-chain source of truth —
     *   `openConnectSlot` and `claimConnectSlot` must pass exactly this amount.
     *   Treat the config constant as the *default for new rooms*, not a runtime
     *   fallback for opens/claims.
     * @param {number} [pricePerSession]  Phase 1 Pay-for-Access flat fee
     *   (lamports) snapshotted into `slot.access_price` at claim time. Defaults
     *   to `SOLS_CONFIG.ROOM_PRICE_PER_SESSION_LAMPORTS` (0 = free room).
     */
    async function createRoom(title, category, accessMode, connectionMode, pricePerMinute, nonce, depositLamports, pricePerSession) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const CFG = window.SOLS_CONFIG || {};
        const dep = (typeof depositLamports === 'number' && depositLamports > 0)
            ? depositLamports
            : (CFG.CONNECT_SLOT_DEPOSIT_LAMPORTS || 1_000_000);
        const pps = (typeof pricePerSession === 'number' && pricePerSession >= 0)
            ? pricePerSession
            : (CFG.ROOM_PRICE_PER_SESSION_LAMPORTS || 0);
        const ix = buildCreateRoomInstruction(w.publicKey, title, category, accessMode, connectionMode, pricePerMinute, dep, pps, nonce);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.create_room });
    }

    // ========================= end_room =========================

    /**
     * end_room(roomPDA)
     * Accounts: host (signer), host_user PDA (mut), room (mut)
     */
    function buildEndRoomInstruction(hostPubkey, roomPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [hostUserPDA] = deriveUserPDA(hostPubkey);

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: false },
                { pubkey: hostUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.end_room,
        });
        ix._ixName = 'end_room';
        return ix;
    }

    async function endRoom(roomPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildEndRoomInstruction(w.publicKey, roomKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.end_room });
    }

    // ========================= close_room =========================

    /**
     * close_room(roomPDA)
     * Accounts: host (signer, mut), room (mut)
     */
    function buildCloseRoomInstruction(hostPubkey, roomPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        const [hostUserPDA] = deriveUserPDA(hostPubkey);

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: true },
                { pubkey: hostUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.close_room,
        });
        ix._ixName = 'close_room';
        return ix;
    }

    async function closeRoom(roomPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildCloseRoomInstruction(w.publicKey, roomKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.close_room });
    }

    // ========================= join_room =========================

    /**
     * join_room(roomPDA, hostUserPDA, configPDA)
     * Accounts: viewer (signer), viewer_user PDA (mut), room (mut), host_user, config PDA
     */
    function buildJoinRoomInstruction(viewerPubkey, roomPDA, hostUserPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [viewerUserPDA] = deriveUserPDA(viewerPubkey);
        const [configPDA] = deriveConfigPDA();

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: false },
                { pubkey: viewerUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
                { pubkey: hostUserPDA, isSigner: false, isWritable: false },
                { pubkey: configPDA, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: DISC.join_room,
        });
        ix._ixName = 'join_room';
        return ix;
    }

    async function joinRoom(roomPDA, hostUserPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const hostUserKey = (typeof hostUserPDA === 'string') ? new sw3.PublicKey(hostUserPDA) : hostUserPDA;
        const ix = buildJoinRoomInstruction(w.publicKey, roomKey, hostUserKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.join_room });
    }

    // ========================= leave_room =========================

    /**
     * leave_room(roomPDA)
     * Accounts: viewer (signer), viewer_user PDA (mut), room (mut)
     */
    function buildLeaveRoomInstruction(viewerPubkey, roomPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [viewerUserPDA] = deriveUserPDA(viewerPubkey);

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: false },
                { pubkey: viewerUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.leave_room,
        });
        ix._ixName = 'leave_room';
        return ix;
    }

    async function leaveRoom(roomPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildLeaveRoomInstruction(w.publicKey, roomKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.leave_room });
    }

    // ========================= become_relay =========================

    /**
     * become_relay()
     * Accounts: viewer (signer), viewer_user PDA (mut)
     */
    function buildBecomeRelayInstruction(viewerPubkey) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [viewerUserPDA] = deriveUserPDA(viewerPubkey);

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: false },
                { pubkey: viewerUserPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.become_relay,
        });
        ix._ixName = 'become_relay';
        return ix;
    }

    async function becomeRelay() {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildBecomeRelayInstruction(w.publicKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.become_relay });
    }

    // ========================= heartbeat =========================

    /**
     * heartbeat()
     * Accounts: viewer (signer), viewer_user PDA (mut), config PDA
     */
    function buildHeartbeatInstruction(viewerPubkey) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [viewerUserPDA] = deriveUserPDA(viewerPubkey);
        const [configPDA] = deriveConfigPDA();

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: false },
                { pubkey: viewerUserPDA, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: DISC.heartbeat,
        });
        ix._ixName = 'heartbeat';
        return ix;
    }

    async function heartbeat() {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildHeartbeatInstruction(w.publicKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.heartbeat });
    }

    // ========================= expire_viewer =========================

    /**
     * expire_viewer(targetUserPDA, roomPDA)
     * Accounts: caller (signer), target_user (mut), room (mut)
     */
    function buildExpireViewerInstruction(callerPubkey, targetUserPDA, roomPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: callerPubkey, isSigner: true, isWritable: false },
                { pubkey: targetUserPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.expire_viewer,
        });
        ix._ixName = 'expire_viewer';
        return ix;
    }

    async function expireViewer(targetUserPDA, roomPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const targetKey = (typeof targetUserPDA === 'string') ? new sw3.PublicKey(targetUserPDA) : targetUserPDA;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildExpireViewerInstruction(w.publicKey, targetKey, roomKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.expire_viewer });
    }

    // ========================= purchase_turn =========================

    /**
     * purchase_turn()
     * Accounts: buyer (signer, mut), buyer_user PDA (mut), service_wallet (mut), config PDA, system_program
     */
    function buildPurchaseTurnInstruction(buyerPubkey) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        if (!_serviceWallet) throw new Error('Service wallet not configured');

        const [buyerUserPDA] = deriveUserPDA(buyerPubkey);
        const [configPDA] = deriveConfigPDA();

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: buyerPubkey, isSigner: true, isWritable: true },
                { pubkey: buyerUserPDA, isSigner: false, isWritable: true },
                { pubkey: _serviceWallet, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: DISC.purchase_turn,
        });
        ix._ixName = 'purchase_turn';
        return ix;
    }

    async function purchaseTurn() {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const ix = buildPurchaseTurnInstruction(w.publicKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.purchase_turn });
    }

    // ========================= open_connect_slot =========================

    /**
     * open_connect_slot(roomPDA, slotNonce, depositLamports, expiresInSeconds)
     * Accounts: host (signer, mut), room, slot PDA (mut), system_program
     * Args: slot_nonce (u64), deposit_lamports (u64), expires_in_seconds (u64)
     *
     * The program validates `depositLamports == room.deposit_lamports` on-chain
     * (DepositMismatch error otherwise). Callers must read the Room first and
     * pass the exact stored value — do NOT use a hardcoded constant here.
     */
    function buildOpenConnectSlotInstruction(hostPubkey, roomPDA, slotNonce, depositLamports, expiresInSeconds) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [slotPDA] = deriveSlotPDA(roomPDA, slotNonce);

        const ixData = concatBytes(
            DISC.open_connect_slot,
            serializeU64(slotNonce),
            serializeU64(depositLamports),
            serializeU64(expiresInSeconds)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: false },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'open_connect_slot';
        return ix;
    }

    async function openConnectSlot(roomPDA, slotNonce, depositLamports, expiresInSeconds) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildOpenConnectSlotInstruction(w.publicKey, roomKey, slotNonce, depositLamports, expiresInSeconds);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.open_connect_slot });
    }

    // ========================= open_relay_slot =========================

    function buildOpenRelaySlotInstruction(relayPubkey, roomPDA, slotNonce, depositLamports, expiresInSeconds) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const [relayUserPDA] = deriveUserPDA(relayPubkey);
        const [slotPDA] = deriveSlotPDA(roomPDA, slotNonce);

        const ixData = concatBytes(
            DISC.open_relay_slot,
            serializeU64(slotNonce),
            serializeU64(depositLamports),
            serializeU64(expiresInSeconds)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: relayPubkey, isSigner: true, isWritable: true },
                { pubkey: relayUserPDA, isSigner: false, isWritable: false },
                { pubkey: roomPDA, isSigner: false, isWritable: false },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'open_relay_slot';
        return ix;
    }

    async function openRelaySlot(roomPDA, slotNonce, depositLamports, expiresInSeconds) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildOpenRelaySlotInstruction(w.publicKey, roomKey, slotNonce, depositLamports, expiresInSeconds);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.open_relay_slot });
    }

    // ========================= claim_connect_slot =========================

    /**
     * claim_connect_slot(slotPDA, roomPDA, depositLamports)
     * Accounts: viewer (signer, mut), slot (mut), room (read-only), system_program
     * Args: deposit_lamports (u64)
     *
     * The program validates `depositLamports == slot.host_deposit` on-chain
     * (DepositMismatch error otherwise). Callers must read the slot first and
     * pass `slot.host_deposit` — do NOT use a hardcoded constant.
     *
     * Upgrade 07: viewer is also debited `room.price_per_session` in the same
     * tx (single CPI). The price is read from the supplied Room account, so
     * pass the slot's parent Room PDA exactly. The program enforces
     * `room.key() == slot.room` (RoomMismatch otherwise).
     */
    function buildClaimConnectSlotInstruction(viewerPubkey, slotPDA, roomPDA, depositLamports) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const ixData = concatBytes(
            DISC.claim_connect_slot,
            serializeU64(depositLamports)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: true },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: roomPDA, isSigner: false, isWritable: false },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'claim_connect_slot';
        return ix;
    }

    async function claimConnectSlot(slotPDA, roomPDA, depositLamports) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const ix = buildClaimConnectSlotInstruction(w.publicKey, slotKey, roomKey, depositLamports);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.claim_connect_slot });
    }

    // ========================= write_offer =========================

    /**
     * write_offer(slotPDA, hostProtectedKey, offerData)
     * Accounts: host (signer), slot (mut)
     * Args: host_protected_key (bytes), offer_data (bytes)
     */
    function buildWriteOfferInstruction(hostPubkey, slotPDA, hostProtectedKey, offerData, finalize = false) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const keyBytes = (hostProtectedKey instanceof Uint8Array) ? hostProtectedKey : new TextEncoder().encode(hostProtectedKey);
        const dataBytes = (offerData instanceof Uint8Array) ? offerData : new TextEncoder().encode(offerData);

        const ixData = concatBytes(
            DISC.write_offer,
            serializeBytes(keyBytes),
            serializeBytes(dataBytes),
            serializeBool(finalize)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: true },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'write_offer';
        return ix;
    }

    async function writeOffer(slotPDA, hostProtectedKey, offerData, finalize = false) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const ix = buildWriteOfferInstruction(w.publicKey, slotKey, hostProtectedKey, offerData, finalize);
        // Use per-slot lane for parallel chunk writes; realloc-heavy → 256KB heap.
        return sendInstruction(ix, 'slot-' + slotKey.toString().substring(0, 12), {
            cuLimit: CU_PROFILE.write_offer,
            requestHeap: true,
        });
    }

    /**
     * Chunked offer write with sequential confirms.
     * Each chunk is confirmed before sending the next — reliable for large payloads.
     * Uses sendInstruction (with retry logic) for each chunk.
     */
    async function writeChunkedOffer(slotPDA, protectedKey, encryptedData, chunkSize) {
        chunkSize = chunkSize || (window.SOLS_CONFIG && window.SOLS_CONFIG.CHUNK_SIZE) || 800;
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const lane = 'slot-' + slotKey.toString().substring(0, 12);

        // Step 1: write protected key
        await writeOffer(slotPDA, protectedKey, '', false);

        // Step 2: write data chunks sequentially (each confirmed before next)
        const encBytes = (encryptedData instanceof Uint8Array) ? encryptedData : new TextEncoder().encode(encryptedData);
        const totalChunks = Math.ceil(encBytes.length / chunkSize);
        let lastSig;

        for (let i = 0; i < encBytes.length; i += chunkSize) {
            const chunk = encBytes.slice(i, i + chunkSize);
            const isLast = (i + chunkSize >= encBytes.length);
            const chunkStr = new TextDecoder().decode(chunk);
            lastSig = await writeOffer(slotPDA, '', chunkStr, isLast);
        }

        return { totalChunks, lastSig };
    }

    // ========================= write_answer =========================

    /**
     * write_answer(slotPDA, viewerProtectedKey, answerData)
     * Accounts: viewer (signer), slot (mut)
     * Args: viewer_protected_key (bytes), answer_data (bytes)
     */
    function buildWriteAnswerInstruction(viewerPubkey, slotPDA, viewerProtectedKey, answerData, finalize = false) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');

        const keyBytes = (viewerProtectedKey instanceof Uint8Array) ? viewerProtectedKey : new TextEncoder().encode(viewerProtectedKey);
        const dataBytes = (answerData instanceof Uint8Array) ? answerData : new TextEncoder().encode(answerData);

        const ixData = concatBytes(
            DISC.write_answer,
            serializeBytes(keyBytes),
            serializeBytes(dataBytes),
            serializeBool(finalize)
        );

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: viewerPubkey, isSigner: true, isWritable: true },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: sw3.SystemProgram.programId, isSigner: false, isWritable: false },
            ],
            programId: _programId,
            data: ixData,
        });
        ix._ixName = 'write_answer';
        return ix;
    }

    async function writeAnswer(slotPDA, viewerProtectedKey, answerData, finalize = false) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const ix = buildWriteAnswerInstruction(w.publicKey, slotKey, viewerProtectedKey, answerData, finalize);
        // Realloc-heavy → 256KB heap.
        return sendInstruction(ix, 'slot-' + slotKey.toString().substring(0, 12), {
            cuLimit: CU_PROFILE.write_answer,
            requestHeap: true,
        });
    }

    // ========================= close_connect_slot =========================

    /**
     * Cache the on-chain `ProgramConfig.service_wallet` so close-paths don't
     * round-trip every call. Falls back to the in-memory `_serviceWallet`
     * (set via initProgram → fetchConfig or SOLS_CONFIG fallback). Returns
     * null if no service wallet is available.
     */
    let _closeServiceWalletCache = null;
    async function _getCloseServiceWallet() {
        if (_closeServiceWalletCache) return _closeServiceWalletCache;
        if (_serviceWallet) {
            _closeServiceWalletCache = _serviceWallet;
            return _closeServiceWalletCache;
        }
        try {
            const config = await fetchConfig();
            if (config && config.serviceWallet) {
                const sw3 = window.solanaWeb3;
                _closeServiceWalletCache = (config.serviceWallet instanceof sw3.PublicKey)
                    ? config.serviceWallet
                    : new sw3.PublicKey(config.serviceWallet);
                _serviceWallet = _closeServiceWalletCache;
                return _closeServiceWalletCache;
            }
        } catch (_) {}
        return null;
    }

    /**
     * close_connect_slot(slotPDA)
     * Accounts: host (signer, mut), slot (mut), viewer (mut), config (PDA),
     *           service_wallet (mut)
     *
     * Upgrade 07: the program now skims a 1% service fee from `slot.lamports()`
     * on every close-path. The service wallet pubkey is read from
     * `ProgramConfig.service_wallet` (PDA at seeds=[b"config"]); both PDA and
     * wallet are required as accounts.
     */
    function buildCloseConnectSlotInstruction(hostPubkey, slotPDA, viewerPubkey, serviceWallet) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        if (!serviceWallet) throw new Error('Service wallet not configured');
        // If no viewer, use host as placeholder (unclaimed slot)
        const viewer = viewerPubkey || hostPubkey;
        const [configPDA] = deriveConfigPDA();

        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: hostPubkey, isSigner: true, isWritable: true },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
                { pubkey: viewer, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
                { pubkey: serviceWallet, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.close_connect_slot,
        });
        ix._ixName = 'close_connect_slot';
        return ix;
    }

    async function closeConnectSlot(slotPDA, viewerPubkey) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        // If viewer not provided, fetch from slot to return their deposit
        let viewer = viewerPubkey;
        if (!viewer) {
            try {
                const sd = await fetchConnectSlot(slotKey);
                if (sd && sd.viewer && sd.viewer.toString() !== '11111111111111111111111111111111') {
                    viewer = sd.viewer;
                }
            } catch (_) {}
        }
        const serviceWallet = await _getCloseServiceWallet();
        if (!serviceWallet) throw new Error('Service wallet unavailable for close');
        const ix = buildCloseConnectSlotInstruction(w.publicKey, slotKey, viewer, serviceWallet);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.close_connect_slot });
    }

    // ========================= confirm_connection =========================

    /**
     * confirm_connection(slotPDA)
     * Accounts: signer (mut), slot (mut)
     *
     * Upgrade 07: each party (host + viewer) calls this once after WebRTC
     * `connectionState === 'connected'`. The program flips the matching
     * `*_confirmed` flag and transitions `AnswerReady → Connected` when both
     * flags are true. Accepts state ∈ {AnswerReady, Connected} so the second
     * party's call succeeds after the first already flipped state.
     */
    function buildConfirmConnectionInstruction(signerPubkey, slotPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: signerPubkey, isSigner: true, isWritable: true },
                { pubkey: slotPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.confirm_connection,
        });
        ix._ixName = 'confirm_connection';
        return ix;
    }

    async function confirmConnection(slotPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const ix = buildConfirmConnectionInstruction(w.publicKey, slotKey);
        return sendInstruction(ix, 'confirm-' + slotKey.toString().substring(0, 8), {
            cuLimit: CU_PROFILE.confirm_connection,
        });
    }

    // ========================= cleanup_expired_slot =========================

    /**
     * cleanup_expired_slot — anyone can close an expired ConnectSlot.
     * Upgrade 07: the program runs the same distribution helper as
     * close_connect_slot — it skims 1% to the service wallet, pays the caller
     * a 1% bounty (only if caller ∉ {host, viewer}), and refunds the rest
     * pro-rata over deposits + rent contributions + access price.
     *
     * Accounts: caller (signer, mut), slot (mut), host (mut), viewer (mut),
     *           config (PDA), service_wallet (mut)
     */
    function buildCleanupExpiredSlotInstruction(callerPubkey, slotKey, hostKey, viewerKey, serviceWallet) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        if (!serviceWallet) throw new Error('Service wallet not configured');
        const [configPDA] = deriveConfigPDA();
        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: callerPubkey, isSigner: true, isWritable: true },
                { pubkey: slotKey, isSigner: false, isWritable: true },
                { pubkey: hostKey, isSigner: false, isWritable: true },
                { pubkey: viewerKey, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
                { pubkey: serviceWallet, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.cleanup_expired_slot,
        });
        ix._ixName = 'cleanup_expired_slot';
        return ix;
    }

    async function cleanupExpiredSlot(slotPDA, hostPubkey, viewerPubkey) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const hostKey = (typeof hostPubkey === 'string') ? new sw3.PublicKey(hostPubkey) : hostPubkey;
        const viewerKey = (typeof viewerPubkey === 'string') ? new sw3.PublicKey(viewerPubkey) : (viewerPubkey || sw3.PublicKey.default);
        const serviceWallet = await _getCloseServiceWallet();
        if (!serviceWallet) throw new Error('Service wallet unavailable for cleanup');
        const ix = buildCleanupExpiredSlotInstruction(w.publicKey, slotKey, hostKey, viewerKey, serviceWallet);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.cleanup_expired_slot });
    }

    // ============== cleanup_expired_slot_third_party =====================

    /**
     * cleanup_expired_slot_third_party — any signer EXCEPT the slot host or
     * viewer can call this once `slot.expires_at + 120 < now` (chain clock).
     *
     * Upgrade 07: payout math was rewritten. The program now skims 1% to the
     * service wallet, pays the caller a 5% cleanup bounty, and refunds the
     * remaining lamports pro-rata across host/viewer based on their deposits,
     * rent contributions, and access price.
     *
     * Accounts: caller (signer, mut), slot (mut), host (mut), viewer (mut),
     *           config (PDA), service_wallet (mut)
     */
    function buildCleanupExpiredSlotThirdPartyInstruction(callerPubkey, slotKey, hostKey, viewerKey, serviceWallet) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        if (!serviceWallet) throw new Error('Service wallet not configured');
        const [configPDA] = deriveConfigPDA();
        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: callerPubkey, isSigner: true, isWritable: true },
                { pubkey: slotKey, isSigner: false, isWritable: true },
                { pubkey: hostKey, isSigner: false, isWritable: true },
                { pubkey: viewerKey, isSigner: false, isWritable: true },
                { pubkey: configPDA, isSigner: false, isWritable: false },
                { pubkey: serviceWallet, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.cleanup_expired_slot_third_party,
        });
        ix._ixName = 'cleanup_expired_slot_third_party';
        return ix;
    }

    /**
     * cleanupExpiredSlotThirdParty — high-level wrapper.
     *
     * @param {PublicKey|string} slotPDA
     * @param {PublicKey|string} hostPubkey  must equal slot.host
     * @param {PublicKey|string} [viewerPubkey]  pass slot.viewer if claimed.
     *   When the slot was never claimed (viewer == default), pass any writable
     *   wallet pubkey here (the caller's own pubkey is fine) — the program
     *   short-circuits the viewer leg, but Anchor still requires a writable
     *   AccountMeta in the slot.
     */
    async function cleanupExpiredSlotThirdParty(slotPDA, hostPubkey, viewerPubkey) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const ZERO_KEY = '11111111111111111111111111111111';
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const hostKey = (typeof hostPubkey === 'string') ? new sw3.PublicKey(hostPubkey) : hostPubkey;
        let viewerKey = viewerPubkey;
        // For never-claimed (Open) slots, slot.viewer == Pubkey::default() == SystemProgram.
        // Solana treats that account as non-writable, which trips Anchor's `mut` constraint
        // (error 2000). Substitute the host's pubkey — the program checks `has_viewer` via
        // `slot.viewer != Pubkey::default()` and skips the viewer leg, so the swap is harmless
        // on-chain. We deliberately do NOT use the caller here: the third-party path forbids
        // caller == slot.viewer, so reusing caller_key as the viewer placeholder would still
        // be safe (slot.viewer is default, not caller), but using host keeps the placeholder
        // semantically tied to a slot participant and avoids any confusion.
        const viewerStr = viewerKey
            ? (typeof viewerKey === 'string' ? viewerKey : viewerKey.toString())
            : '';
        if (!viewerKey || viewerStr === ZERO_KEY) viewerKey = hostKey;
        if (typeof viewerKey === 'string') viewerKey = new sw3.PublicKey(viewerKey);
        const serviceWallet = await _getCloseServiceWallet();
        if (!serviceWallet) throw new Error('Service wallet unavailable for cleanup');
        const ix = buildCleanupExpiredSlotThirdPartyInstruction(w.publicKey, slotKey, hostKey, viewerKey, serviceWallet);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.cleanup_expired_slot_third_party });
    }

    // ========================= cleanup_stale_user =========================

    /**
     * cleanup_stale_user — any signer can reset a User PDA whose heartbeat
     * has lapsed past `expires_at + 300` seconds. Resets role to Idle and
     * clears `room` + `connected_to`; leaves nickname / authority / counters
     * untouched. The PDA stays alive (no rent transfer to caller).
     *
     * Accounts: caller (signer), target_user (mut)
     */
    function buildCleanupStaleUserInstruction(callerPubkey, targetUserPDA) {
        const sw3 = window.solanaWeb3;
        if (!_programId) throw new Error('Program ID not set');
        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: callerPubkey, isSigner: true, isWritable: false },
                { pubkey: targetUserPDA, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.cleanup_stale_user,
        });
        ix._ixName = 'cleanup_stale_user';
        return ix;
    }

    async function cleanupStaleUser(targetUserPDA) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const target = (typeof targetUserPDA === 'string') ? new sw3.PublicKey(targetUserPDA) : targetUserPDA;
        const ix = buildCleanupStaleUserInstruction(w.publicKey, target);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.cleanup_stale_user });
    }

    // ========================= cleanup_stale_room =========================

    /**
     * cleanup_stale_room — anyone can close a room whose host is dead.
     * Rent goes to caller as reward.
     * Accounts: caller (signer, mut), room (mut), host_user PDA (mut), host_wallet (mut)
     */
    function buildCleanupStaleRoomInstruction(callerPubkey, roomKey, hostUserPDA, hostWallet) {
        const sw3 = window.solanaWeb3;
        const ix = new sw3.TransactionInstruction({
            keys: [
                { pubkey: callerPubkey, isSigner: true, isWritable: true },
                { pubkey: roomKey, isSigner: false, isWritable: true },
                { pubkey: hostUserPDA, isSigner: false, isWritable: true },
                { pubkey: hostWallet, isSigner: false, isWritable: true },
            ],
            programId: _programId,
            data: DISC.cleanup_stale_room,
        });
        ix._ixName = 'cleanup_stale_room';
        return ix;
    }

    async function cleanupStaleRoom(roomPDA, hostPubkey) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;
        const hostKey = (typeof hostPubkey === 'string') ? new sw3.PublicKey(hostPubkey) : hostPubkey;
        const [hostUserPDA] = deriveUserPDA(hostKey);
        const ix = buildCleanupStaleRoomInstruction(w.publicKey, roomKey, hostUserPDA, hostKey);
        return sendInstruction(ix, null, { cuLimit: CU_PROFILE.cleanup_stale_room });
    }

    // ========================= Account Fetchers =========================

    /**
     * Ensure User PDA exists; create if missing. Returns the user PDA pubkey.
     */
    async function ensureUser(nickname) {
        const w = _getWallet();
        if (!w) throw new Error('Wallet not connected');
        const [userPDA] = deriveUserPDA(w.publicKey);
        const existing = await fetchUser(w.publicKey);
        if (existing) return userPDA;
        // Truncate nickname to 32 bytes (program limit)
        let nick = nickname || 'anon';
        if (new TextEncoder().encode(nick).length > 32) {
            nick = nick.substring(0, 32);
            while (new TextEncoder().encode(nick).length > 32) nick = nick.slice(0, -1);
        }
        await createUser(nick);
        return userPDA;
    }

    /**
     * fetchUser — read and deserialize a User PDA account.
     * User layout (after 8-byte discriminator):
     *   authority: Pubkey (32)
     *   nickname: String (4+len)
     *   role: u8 (enum)
     *   room: Pubkey (32)
     *   connected_to: Pubkey (32)
     *   last_heartbeat: i64 (8)
     *   expires_at: i64 (8)
     *   turn_expires_at: i64 (8)
     *   stream_count: u32 (4)
     *   total_earned: u64 (8)
     *   created_at: i64 (8)
     *   bump: u8 (1)
     */
    /** Parse User PDA from raw account data (no RPC). */
    function fetchUserFromData(userPDA, data) {
        if (!(data instanceof Uint8Array)) data = new Uint8Array(data);
        for (let i = 0; i < 8; i++) {
            if (data[i] !== ACCOUNT_DISC.User[i]) return null;
        }
        let off = 8;
        let authority, nickname, role, room, connectedTo, lastHeartbeat, expiresAt, turnExpiresAt, streamCount, totalEarned, createdAt, bump;
        [authority, off] = deserializePubkey(data, off);
        [nickname, off] = deserializeString(data, off);
        [role, off] = deserializeU8(data, off);
        [room, off] = deserializePubkey(data, off);
        [connectedTo, off] = deserializePubkey(data, off);
        [lastHeartbeat, off] = deserializeI64(data, off);
        [expiresAt, off] = deserializeI64(data, off);
        [turnExpiresAt, off] = deserializeI64(data, off);
        [streamCount, off] = deserializeU32(data, off);
        [totalEarned, off] = deserializeU64(data, off);
        [createdAt, off] = deserializeI64(data, off);
        [bump, off] = deserializeU8(data, off);
        return {
            address: userPDA, authority, nickname,
            role: USER_ROLE_REV[role] || 'Idle', roleIndex: role,
            room, connectedTo,
            lastHeartbeat: Number(lastHeartbeat), expiresAt: Number(expiresAt),
            turnExpiresAt: Number(turnExpiresAt), streamCount,
            totalEarned: Number(totalEarned), createdAt: Number(createdAt), bump,
        };
    }

    /**
     * Batch-fetch User PDAs for multiple wallet pubkeys using getMultipleAccounts.
     * Returns Map<walletPubkeyStr, userData>.
     */
    async function batchFetchUsers(walletPubkeys) {
        const conn = _getConn();
        if (!conn) return new Map();
        const sw3 = window.solanaWeb3;
        const entries = walletPubkeys.map(pk => {
            const key = (typeof pk === 'string') ? new sw3.PublicKey(pk) : pk;
            const [pda] = deriveUserPDA(key);
            return { walletKey: key, pda };
        });
        const pdas = entries.map(e => e.pda);
        const result = new Map();
        // getMultipleAccounts supports up to 100 per call
        for (let i = 0; i < pdas.length; i += 100) {
            const batch = pdas.slice(i, i + 100);
            try {
                const accts = await conn.getMultipleAccountsInfo(batch);
                for (let j = 0; j < batch.length; j++) {
                    const acct = accts[j];
                    if (!acct || !acct.data) continue;
                    const userData = fetchUserFromData(batch[j], new Uint8Array(acct.data));
                    if (userData) {
                        result.set(entries[i + j].walletKey.toString(), userData);
                    }
                }
            } catch (e) {
                console.warn('[batchFetchUsers] chunk error:', e.message);
            }
        }
        return result;
    }

    async function fetchUser(walletPubkey) {
        const conn = _getConn();
        if (!conn) throw new Error('Connection not available');
        const sw3 = window.solanaWeb3;
        const pubkey = (typeof walletPubkey === 'string') ? new sw3.PublicKey(walletPubkey) : walletPubkey;
        const [userPDA] = deriveUserPDA(pubkey);

        const acct = await conn.getAccountInfo(userPDA);
        if (!acct || !acct.data) return null;

        const data = new Uint8Array(acct.data);
        // Verify discriminator
        for (let i = 0; i < 8; i++) {
            if (data[i] !== ACCOUNT_DISC.User[i]) return null;
        }

        let off = 8;
        let authority, nickname, role, room, connectedTo, lastHeartbeat, expiresAt, turnExpiresAt, streamCount, totalEarned, createdAt, bump;
        [authority, off] = deserializePubkey(data, off);
        [nickname, off] = deserializeString(data, off);
        [role, off] = deserializeU8(data, off);
        [room, off] = deserializePubkey(data, off);
        [connectedTo, off] = deserializePubkey(data, off);
        [lastHeartbeat, off] = deserializeI64(data, off);
        [expiresAt, off] = deserializeI64(data, off);
        [turnExpiresAt, off] = deserializeI64(data, off);
        [streamCount, off] = deserializeU32(data, off);
        [totalEarned, off] = deserializeU64(data, off);
        [createdAt, off] = deserializeI64(data, off);
        [bump, off] = deserializeU8(data, off);

        return {
            address: userPDA,
            authority: authority,
            nickname: nickname,
            role: USER_ROLE_REV[role] || 'Idle',
            roleIndex: role,
            room: room,
            connectedTo: connectedTo,
            lastHeartbeat: Number(lastHeartbeat),
            expiresAt: Number(expiresAt),
            turnExpiresAt: Number(turnExpiresAt),
            streamCount: streamCount,
            totalEarned: Number(totalEarned),
            createdAt: Number(createdAt),
            bump: bump,
        };
    }

    /**
     * fetchRoom — read and deserialize a Room PDA account.
     * Room layout (after 8-byte discriminator) — filterable fields first:
     *   is_live: bool (1)           offset 8  ← memcmp filterable
     *   access_mode: u8 (1)         offset 9  ← memcmp filterable
     *   category: u8 (1)            offset 10 ← memcmp filterable
     *   bump: u8 (1)                offset 11
     *   host: Pubkey (32)           offset 12 ← memcmp filterable
     *   nonce: u64 (8)              offset 44
     *   started_at: i64 (8)         offset 52
     *   ended_at: i64 (8)           offset 60
     *   viewer_count: u32 (4)       offset 68
     *   total_viewers: u32 (4)      offset 72
     *   price_per_minute: u64 (8)   offset 76
     *   total_earned: u64 (8)       offset 84
     *   title: String (4+len)       offset 92 (variable, LAST)
     */
    async function fetchRoom(roomPDA) {
        const conn = _getConn();
        if (!conn) throw new Error('Connection not available');
        const sw3 = window.solanaWeb3;
        const roomKey = (typeof roomPDA === 'string') ? new sw3.PublicKey(roomPDA) : roomPDA;

        const acct = await conn.getAccountInfo(roomKey);
        if (!acct || !acct.data) return null;

        return fetchRoomFromData(roomKey, new Uint8Array(acct.data));
    }

    /**
     * findLiveRooms — scan all Room accounts and return live ones.
     * Returns array of { address, host, title, accessMode, viewerCount, ... }
     */
    async function findLiveRooms() {
        const conn = _getConn();
        if (!conn || !_programId) return [];
        const sw3 = window.solanaWeb3;
        try {
            // Server-side filters: Room discriminator (offset 0) + is_live=true (offset 8)
            const discB64 = btoa(String.fromCharCode(...ACCOUNT_DISC.Room));
            const liveB64 = btoa(String.fromCharCode(1)); // is_live = true = 1
            const accounts = await conn.getProgramAccounts(_programId, {
                filters: [
                    { memcmp: { offset: 0, bytes: discB64, encoding: 'base64' } },
                    { memcmp: { offset: 8, bytes: liveB64, encoding: 'base64' } },
                ],
            });
            // Parse all rooms from batch result (no extra RPC)
            const chainNowSec = Math.floor((window.getChainTimeMs ? window.getChainTimeMs() : Date.now()) / 1000);
            const parsedRooms = [];
            for (const { pubkey, account } of accounts) {
                try {
                    const room = fetchRoomFromData(pubkey, new Uint8Array(account.data));
                    if (room) parsedRooms.push(room);
                } catch (_) {}
            }
            // Batch-fetch all host User PDAs in 1 RPC call instead of N
            const uniqueHosts = [...new Set(parsedRooms.map(r => r.host.toString()))];
            const userMap = await batchFetchUsers(uniqueHosts);
            const rooms = [];
            for (const room of parsedRooms) {
                const hostUser = userMap.get(room.host.toString());
                const isHostRole = hostUser && hostUser.role === 'Host' && hostUser.room.toString() === room.address.toString();
                const hostExpiredHB = hostUser && hostUser.expiresAt > 0 && hostUser.expiresAt < chainNowSec;
                if (isHostRole && !hostExpiredHB) {
                    rooms.push(room);
                }
            }
            // Sort newest first — freshest rooms are most likely to have open slots
            rooms.sort((a, b) => b.startedAt - a.startedAt);
            return rooms;
        } catch (e) {
            console.warn('[findLiveRooms]', e.message);
            return [];
        }
    }

    /** Parse Room from raw account data (no RPC call) */
    /**
     * findLivePublicRooms — server-side filter: is_live=true + access_mode=Public
     * Uses single memcmp on contiguous bytes at offset 8: [1, 0] = live + public
     */
    async function findLivePublicRooms() {
        const conn = _getConn();
        if (!conn || !_programId) return [];
        try {
            const discB64 = btoa(String.fromCharCode(...ACCOUNT_DISC.Room));
            // is_live=true(1) + access_mode=Public(0) are contiguous at offset 8
            const livePublicB64 = btoa(String.fromCharCode(1, 0));
            const accounts = await conn.getProgramAccounts(_programId, {
                filters: [
                    { memcmp: { offset: 0, bytes: discB64, encoding: 'base64' } },
                    { memcmp: { offset: 8, bytes: livePublicB64, encoding: 'base64' } },
                ],
            });
            // Parse all rooms from batch result (no extra RPC)
            const chainNowSec = Math.floor((window.getChainTimeMs ? window.getChainTimeMs() : Date.now()) / 1000);
            const parsedRooms = [];
            for (const { pubkey, account } of accounts) {
                try {
                    const room = fetchRoomFromData(pubkey, new Uint8Array(account.data));
                    if (room) parsedRooms.push(room);
                } catch (_) {}
            }
            // Batch-fetch all host User PDAs in 1 RPC call instead of N
            const uniqueHosts = [...new Set(parsedRooms.map(r => r.host.toString()))];
            const userMap = await batchFetchUsers(uniqueHosts);
            const rooms = [];
            for (const room of parsedRooms) {
                const hostUser = userMap.get(room.host.toString());
                const isHostRole = hostUser && hostUser.role === 'Host' && hostUser.room.toString() === room.address.toString();
                const hostExpiredHB = hostUser && hostUser.expiresAt > 0 && hostUser.expiresAt < chainNowSec;
                if (isHostRole && !hostExpiredHB) {
                    rooms.push(room);
                } else if (hostUser) {
                    // Stale room — fire-and-forget cleanup
                    const hostExpired = hostUser.expiresAt > 0 && hostUser.expiresAt < chainNowSec;
                    const hostNotHosting = hostUser.role !== 'Host' || hostUser.room.toString() !== room.address.toString();
                    if (hostExpired || hostNotHosting) {
                        const roomAddr8 = room.address.toString().substring(0, 12);
                        if (typeof log === 'function') log(`[Cleanup] 🧹 Cleaning stale room ${roomAddr8} (expired=${hostExpired})`);
                        cleanupStaleRoom(room.address, room.host).catch(() => {});
                    }
                }
            }
            // Sort newest first — freshest rooms are most likely to have open slots
            rooms.sort((a, b) => b.startedAt - a.startedAt);
            return rooms;
        } catch (e) {
            console.warn('[findLivePublicRooms]', e.message);
            return [];
        }
    }

    /** Public: run viewer cleanup (call from setInterval, not every scan). */
    async function runViewerCleanup() {
        try {
            const rooms = await findLivePublicRooms();
            const chainNowSec = Math.floor((window.getChainTimeMs ? window.getChainTimeMs() : Date.now()) / 1000);
            await _cleanupExpiredViewers(rooms, chainNowSec);
        } catch (_) {}
    }

    /** Expire up to N stale viewers across rooms to keep viewer_count accurate. */
    async function _cleanupExpiredViewers(rooms, chainNowSec) {
        if (!rooms.length) return;
        const conn = _getConn();
        if (!conn || !_programId) return;
        // Scan User PDAs: find viewers/relays whose expiresAt < now
        const userDisc = btoa(String.fromCharCode(...ACCOUNT_DISC.User));
        let allUsers;
        try {
            allUsers = await conn.getProgramAccounts(_programId, {
                filters: [
                    { memcmp: { offset: 0, bytes: userDisc, encoding: 'base64' } },
                ],
            });
        } catch (_) { return; }
        const roomSet = new Set(rooms.map(r => r.address.toString()));
        let cleaned = 0;
        for (const { pubkey: userPDA, account } of allUsers) {
            if (cleaned >= 3) break;
            try {
                const data = new Uint8Array(account.data);
                // Quick parse: disc(8) + authority(32) + nickname_len(4) + nickname + role(1) + room(32) + connected_to(32) + last_hb(8) + expires_at(8)
                let off = 8;
                const [authority] = deserializePubkey(data, off); off += 32;
                const [nickLen] = deserializeU32(data, off); off += 4 + nickLen;
                const role = data[off]; off += 1; // 0=Idle,1=Host,2=Viewer,3=Relay
                const [room] = deserializePubkey(data, off); off += 32;
                off += 32; // skip connected_to
                off += 8; // skip last_heartbeat
                const [expiresAt] = deserializeI64(data, off);
                const expiresAtNum = Number(expiresAt);
                if (role !== 2 && role !== 3) continue; // not Viewer/Relay
                if (expiresAtNum <= 0 || expiresAtNum >= chainNowSec) continue; // not expired
                if (!roomSet.has(room.toString())) continue; // not in a live room
                const addr8 = authority.toString().substring(0, 8);
                if (typeof log === 'function') log(`[Cleanup] ♻️ Expiring stale viewer ${addr8} (expired ${chainNowSec - expiresAtNum}s ago)`);
                await expireViewer(userPDA, room);
                if (typeof log === 'function') log(`[Cleanup] ✅ Viewer ${addr8} expired — viewer_count decremented`);
                cleaned++;
            } catch (_) {}
        }
    }

    /** Parse Room from raw account data — matches new struct field order
     *
     * Layout (Upgrade 07 — `price_per_session` added at offset 101):
     *   offset 8   is_live (bool)
     *   offset 9   access_mode (u8)
     *   offset 10  category (u8)
     *   offset 11  connection_mode (u8)
     *   offset 12  bump (u8)
     *   offset 13  host (Pubkey, 32)
     *   offset 45  nonce (u64)
     *   offset 53  started_at (i64)
     *   offset 61  ended_at (i64)
     *   offset 69  viewer_count (u32)
     *   offset 73  total_viewers (u32)
     *   offset 77  price_per_minute (u64)
     *   offset 85  total_earned (u64)
     *   offset 93  deposit_lamports (u64)
     *   offset 101 price_per_session (u64)  ← Upgrade 07
     *   offset 109 title (String, 4 + N)
     */
    function fetchRoomFromData(pubkey, data) {
        for (let i = 0; i < 8; i++) {
            if (data[i] !== ACCOUNT_DISC.Room[i]) return null;
        }
        let off = 8;
        let isLive, accessMode, category, connectionMode, bump, host, nonce, startedAt, endedAt, viewerCount, totalViewers, pricePerMinute, totalEarned, depositLamports, pricePerSession, title;
        [isLive, off] = deserializeBool(data, off);
        [accessMode, off] = deserializeU8(data, off);
        [category, off] = deserializeU8(data, off);
        [connectionMode, off] = deserializeU8(data, off);
        [bump, off] = deserializeU8(data, off);
        [host, off] = deserializePubkey(data, off);
        [nonce, off] = deserializeU64(data, off);
        [startedAt, off] = deserializeI64(data, off);
        [endedAt, off] = deserializeI64(data, off);
        [viewerCount, off] = deserializeU32(data, off);
        [totalViewers, off] = deserializeU32(data, off);
        [pricePerMinute, off] = deserializeU64(data, off);
        [totalEarned, off] = deserializeU64(data, off);
        [depositLamports, off] = deserializeU64(data, off);
        [pricePerSession, off] = deserializeU64(data, off);
        [title, off] = deserializeString(data, off);
        return {
            address: pubkey,
            host, nonce: Number(nonce), title,
            category: ROOM_CATEGORY_REV[category] || 'General',
            categoryIndex: category,
            accessMode: ACCESS_MODE_REV[accessMode] || 'Public',
            accessModeIndex: accessMode,
            connectionMode: CONNECTION_MODE_REV[connectionMode] || 'stream',
            connectionModeIndex: connectionMode,
            startedAt: Number(startedAt), endedAt: Number(endedAt),
            isLive, viewerCount, totalViewers,
            pricePerMinute: Number(pricePerMinute),
            totalEarned: Number(totalEarned),
            depositLamports: Number(depositLamports),
            pricePerSession: Number(pricePerSession),
            bump,
        };
    }

    /**
     * fetchConfig — read and deserialize the ProgramConfig PDA.
     * ProgramConfig layout (after 8-byte discriminator):
     *   authority: Pubkey (32)
     *   service_wallet: Pubkey (32)
     *   turn_price: u64 (8)
     *   signal_fee: u64 (8)
     *   heartbeat_ttl: u64 (8)
     *   min_heartbeat_interval: u64 (8)
     *   bump: u8 (1)
     */
    async function fetchConfig() {
        const conn = _getConn();
        if (!conn) throw new Error('Connection not available');

        const [configPDA] = deriveConfigPDA();
        const acct = await conn.getAccountInfo(configPDA);
        if (!acct || !acct.data) return null;

        const data = new Uint8Array(acct.data);
        for (let i = 0; i < 8; i++) {
            if (data[i] !== ACCOUNT_DISC.ProgramConfig[i]) return null;
        }

        let off = 8;
        let authority, serviceWallet, turnPrice, signalFee, heartbeatTtl, minHeartbeatInterval, bump;
        [authority, off] = deserializePubkey(data, off);
        [serviceWallet, off] = deserializePubkey(data, off);
        [turnPrice, off] = deserializeU64(data, off);
        [signalFee, off] = deserializeU64(data, off);
        [heartbeatTtl, off] = deserializeU64(data, off);
        [minHeartbeatInterval, off] = deserializeU64(data, off);
        [bump, off] = deserializeU8(data, off);

        return {
            address: configPDA,
            authority: authority,
            serviceWallet: serviceWallet,
            turnPrice: Number(turnPrice),
            signalFee: Number(signalFee),
            heartbeatTtl: Number(heartbeatTtl),
            minHeartbeatInterval: Number(minHeartbeatInterval),
            bump: bump,
        };
    }

    /**
     * fetchConnectSlot — read and deserialize a ConnectSlot PDA.
     * ConnectSlot layout (after 8-byte discriminator):
     *   room: Pubkey (32)
     *   host: Pubkey (32)
     *   viewer: Pubkey (32)
     *   host_deposit: u64 (8)
     *   viewer_deposit: u64 (8)
     *   host_protected_key: bytes (4+len)
     *   offer_data: bytes (4+len)
     *   viewer_protected_key: bytes (4+len)
     *   answer_data: bytes (4+len)
     *   state: u8 (enum)
     *   created_at: i64 (8)
     *   expires_at: i64 (8)
     *   bump: u8 (1)
     *   --- Upgrade 07 (appended, +26 bytes) ---
     *   host_rent_paid: u64 (8)
     *   viewer_rent_paid: u64 (8)
     *   access_price: u64 (8)
     *   host_confirmed: bool (1)
     *   viewer_confirmed: bool (1)
     */
    /** Parse ConnectSlot from raw account data (no RPC call). */
    function fetchConnectSlotFromData(pubkey, data) {
        if (!(data instanceof Uint8Array)) data = new Uint8Array(data);
        for (let i = 0; i < 8; i++) {
            if (data[i] !== ACCOUNT_DISC.ConnectSlot[i]) return null;
        }
        let off = 8;
        let room, host, viewer, hostDeposit, viewerDeposit, hostProtectedKey, offerData, viewerProtectedKey, answerData, state, createdAt, expiresAt, bump;
        [room, off] = deserializePubkey(data, off);
        [host, off] = deserializePubkey(data, off);
        [viewer, off] = deserializePubkey(data, off);
        [hostDeposit, off] = deserializeU64(data, off);
        [viewerDeposit, off] = deserializeU64(data, off);
        [hostProtectedKey, off] = deserializeBytes(data, off);
        [offerData, off] = deserializeBytes(data, off);
        [viewerProtectedKey, off] = deserializeBytes(data, off);
        [answerData, off] = deserializeBytes(data, off);
        [state, off] = deserializeU8(data, off);
        [createdAt, off] = deserializeI64(data, off);
        [expiresAt, off] = deserializeI64(data, off);
        [bump, off] = deserializeU8(data, off);

        // Upgrade 07 fields. Pre-upgrade slots lack these; default to 0/false.
        // Pre-upgrade slots all expire within ~5 min of program deploy and
        // settle via the cleanup paths, so this branch is only relevant during
        // that transition window.
        let hostRentPaid = 0n, viewerRentPaid = 0n, accessPrice = 0n;
        let hostConfirmed = false, viewerConfirmed = false;
        if (off + 26 <= data.length) {
            [hostRentPaid, off] = deserializeU64(data, off);
            [viewerRentPaid, off] = deserializeU64(data, off);
            [accessPrice, off] = deserializeU64(data, off);
            [hostConfirmed, off] = deserializeBool(data, off);
            [viewerConfirmed, off] = deserializeBool(data, off);
        }

        return {
            address: pubkey,
            room, host, viewer,
            hostDeposit: Number(hostDeposit), viewerDeposit: Number(viewerDeposit),
            hostProtectedKey, offerData, viewerProtectedKey, answerData,
            state: SLOT_STATE_REV[state] || 'Open', stateIndex: state,
            createdAt: Number(createdAt), expiresAt: Number(expiresAt), bump,
            hostRentPaid: Number(hostRentPaid),
            viewerRentPaid: Number(viewerRentPaid),
            accessPrice: Number(accessPrice),
            hostConfirmed, viewerConfirmed,
        };
    }

    /** Fetch ConnectSlot via RPC (single account). Use fetchConnectSlotFromData when data is already available. */
    async function fetchConnectSlot(slotPDA) {
        const conn = _getConn();
        if (!conn) throw new Error('Connection not available');
        const sw3 = window.solanaWeb3;
        const slotKey = (typeof slotPDA === 'string') ? new sw3.PublicKey(slotPDA) : slotPDA;
        const acct = await conn.getAccountInfo(slotKey);
        if (!acct || !acct.data) return null;
        return fetchConnectSlotFromData(slotKey, new Uint8Array(acct.data));
    }

    // --- Initialization ---

    async function initProgram() {
        const CFG = window.SOLS_CONFIG || {};
        _programMode = CFG.SIGNALING_MODE || 'memo';

        if (CFG.PROGRAM_ID && _programMode === 'program') {
            const sw3 = window.solanaWeb3;
            if (!sw3) {
                console.warn('[ProgramClient] solanaWeb3 not loaded yet, deferring program init');
                return;
            }
            _programId = new sw3.PublicKey(CFG.PROGRAM_ID);

            // Try to read service_wallet from on-chain ProgramConfig
            try {
                const conn = _getConn();
                if (conn) {
                    const config = await fetchConfig();
                    if (config && config.serviceWallet) {
                        _serviceWallet = new sw3.PublicKey(config.serviceWallet);
                        console.log('[ProgramClient] Service wallet from config PDA: ' + config.serviceWallet.substring(0, 8) + '...');
                    }
                }
            } catch (_) {}

            // Fallback to config.js
            if (!_serviceWallet) {
                const serviceWalletStr = CFG.PROGRAM_SERVICE_WALLET || CFG.TURN_SERVICE_WALLET;
                if (serviceWalletStr) {
                    _serviceWallet = new sw3.PublicKey(serviceWalletStr);
                }
            }

            console.log('[ProgramClient] Program mode enabled: ' + CFG.PROGRAM_ID.substring(0, 8) + '...');
        } else {
            console.log('[ProgramClient] Memo mode (default)');
        }
    }

    function isProgramMode() {
        return _programMode === 'program' && !!_programId;
    }

    function getProgramId() {
        return _programId;
    }

    function getServiceWallet() {
        return _serviceWallet;
    }

    // --- Exports ---

    window.programClient = {
        // Init
        initProgram: initProgram,
        isProgramMode: isProgramMode,
        getProgramId: getProgramId,
        getServiceWallet: getServiceWallet,
        registerWalletProvider: registerWalletProvider,
        getActivePublicKey: getActivePublicKey,
        getConnection: _getConn,

        // PDA helpers
        deriveUserPDA: deriveUserPDA,
        deriveRoomPDA: deriveRoomPDA,
        deriveConfigPDA: deriveConfigPDA,
        deriveSlotPDA: deriveSlotPDA,

        // Instruction builders (low-level)
        buildPostMemoInstruction: buildPostMemoInstruction,
        buildCreateUserInstruction: buildCreateUserInstruction,
        buildUpdateProfileInstruction: buildUpdateProfileInstruction,
        buildCloseUserInstruction: buildCloseUserInstruction,
        buildCreateRoomInstruction: buildCreateRoomInstruction,
        buildEndRoomInstruction: buildEndRoomInstruction,
        buildCloseRoomInstruction: buildCloseRoomInstruction,
        buildJoinRoomInstruction: buildJoinRoomInstruction,
        buildLeaveRoomInstruction: buildLeaveRoomInstruction,
        buildBecomeRelayInstruction: buildBecomeRelayInstruction,
        buildHeartbeatInstruction: buildHeartbeatInstruction,
        buildExpireViewerInstruction: buildExpireViewerInstruction,
        buildPurchaseTurnInstruction: buildPurchaseTurnInstruction,
        buildOpenConnectSlotInstruction: buildOpenConnectSlotInstruction,
        buildClaimConnectSlotInstruction: buildClaimConnectSlotInstruction,
        buildWriteOfferInstruction: buildWriteOfferInstruction,
        buildWriteAnswerInstruction: buildWriteAnswerInstruction,
        buildCloseConnectSlotInstruction: buildCloseConnectSlotInstruction,
        buildConfirmConnectionInstruction: buildConfirmConnectionInstruction,
        buildCleanupExpiredSlotInstruction: buildCleanupExpiredSlotInstruction,
        buildCleanupExpiredSlotThirdPartyInstruction: buildCleanupExpiredSlotThirdPartyInstruction,
        buildCleanupStaleUserInstruction: buildCleanupStaleUserInstruction,

        // High-level operations (build + send)
        postMemo: postMemo,
        createUser: createUser,
        updateProfile: updateProfile,
        closeUser: closeUser,
        createRoom: createRoom,
        endRoom: endRoom,
        closeRoom: closeRoom,
        joinRoom: joinRoom,
        leaveRoom: leaveRoom,
        becomeRelay: becomeRelay,
        heartbeat: heartbeat,
        expireViewer: expireViewer,
        purchaseTurn: purchaseTurn,
        openConnectSlot: openConnectSlot,
        openRelaySlot: openRelaySlot,
        claimConnectSlot: claimConnectSlot,
        writeOffer: writeOffer,
        writeChunkedOffer: writeChunkedOffer,
        writeAnswer: writeAnswer,
        closeConnectSlot: closeConnectSlot,
        confirmConnection: confirmConnection,
        cleanupExpiredSlot: cleanupExpiredSlot,
        cleanupExpiredSlotThirdParty: cleanupExpiredSlotThirdParty,
        cleanupStaleRoom: cleanupStaleRoom,
        cleanupStaleUser: cleanupStaleUser,
        runViewerCleanup: runViewerCleanup,

        // Convenience: ensure user exists
        ensureUser: ensureUser,

        // Account fetchers
        fetchUser: fetchUser,
        fetchUserFromData: fetchUserFromData,
        fetchRoom: fetchRoom,
        fetchConfig: fetchConfig,
        fetchConnectSlot: fetchConnectSlot,
        fetchConnectSlotFromData: fetchConnectSlotFromData,
        findLiveRooms: findLiveRooms,
        findLivePublicRooms: findLivePublicRooms,

        // Send helper
        sendInstruction: sendInstruction,

        // Enum maps
        ROOM_CATEGORY: ROOM_CATEGORY,
        ACCESS_MODE: ACCESS_MODE,
        CONNECTION_MODE: CONNECTION_MODE,
        CONNECTION_MODE_REV: CONNECTION_MODE_REV,
        USER_ROLE: USER_ROLE,
        ROOM_CATEGORY_REV: ROOM_CATEGORY_REV,
        ACCESS_MODE_REV: ACCESS_MODE_REV,
        USER_ROLE_REV: USER_ROLE_REV,
        SLOT_STATE_REV: SLOT_STATE_REV,

        // Anchor error mapping
        SOLS_ERROR_NAMES: SOLS_ERROR_NAMES,
        extractAnchorErrorNumber: extractAnchorErrorNumber,

        // Discriminators
        DISC: DISC,
        ACCOUNT_DISC: ACCOUNT_DISC,

        // Borsh helpers
        serializeU8: serializeU8,
        serializeU32: serializeU32,
        serializeU64: serializeU64,
        serializeI64: serializeI64,
        serializeBool: serializeBool,
        serializeString: serializeString,
        serializeBytes: serializeBytes,
        serializePubkey: serializePubkey,
        concatBytes: concatBytes,
    };

    // Convenience global
    window.isProgramMode = isProgramMode;
})();
