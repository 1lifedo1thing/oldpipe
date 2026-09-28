import Foundation

// MARK: - YTPlaylist
// A playlist listed on a YouTube channel page. Transient — fetched per visit and never
// persisted, so it has no toDict/from(dict:). Saving one locally goes through
// PlaylistManager, which stores the resolved Videos instead.

struct YTPlaylist {
    let id: String             // PL…
    let title: String
    let thumbnailURL: String
    let countText: String      // e.g. "8 videos" (empty when the badge is absent)
}
