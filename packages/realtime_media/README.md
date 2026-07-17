# realtime_media

WebRTC peer media session runtime.

Owns local media acquisition, peer connection lifecycle, SDP offer/answer
creation, ICE gathering, media track toggles, remote stream events, and disposal.
Features render the exposed media handles but do not own the WebRTC runtime.

Media controls have directional semantics:

- Camera off detaches the outgoing video sender but preserves local preview.
- Mic off detaches the outgoing audio sender and releases microphone capture.
- Incoming audio/video remain active when local publication is disabled.
- Local-stream identities are rejected from the remote-stream event channel.
- A typed `RemoteMediaState` mirrors peer camera and microphone publication.
- The control data channel sends the complete `media-state` on open and after
  each local media toggle; it never carries SDP, ICE, or credentials.
