import 'package:realtime_media/realtime_media.dart';

final class FakeMediaStream extends MediaStream {
  final List<MediaStreamTrack> _tracks;

  @override
  bool? get active => true;

  factory FakeMediaStream({
    String id = 'fake-stream-id',
    List<MediaStreamTrack> tracks = const [],
  }) => FakeMediaStream._(id, tracks);

  FakeMediaStream._(
    String id,
    this._tracks,
  ) : super(id, 'fake-owner-tag');

  @override
  List<MediaStreamTrack> getVideoTracks() => _tracks.where((track) => track.kind == 'video').toList();

  @override
  List<MediaStreamTrack> getAudioTracks() => _tracks.where((track) => track.kind == 'audio').toList();

  @override
  List<MediaStreamTrack> getTracks() => List.unmodifiable(_tracks);

  @override
  Future<void> getMediaTracks() async {}

  @override
  Future<void> addTrack(
    MediaStreamTrack track, {
    bool addToNative = true,
  }) async {}

  @override
  Future<void> removeTrack(
    MediaStreamTrack track, {
    bool removeFromNative = true,
  }) async {}

  @override
  Future<void> dispose() async {}
}
