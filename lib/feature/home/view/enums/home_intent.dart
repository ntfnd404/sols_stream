/// Why the user opened Home, chosen on the Hub. Maps to an initial transport
/// and role. Serialised in the URL as `intent=<name>` — renaming a value
/// breaks shareable links, so treat these names as a URL contract.
enum HomeIntent { stream, joinRoom, p2pCall }
