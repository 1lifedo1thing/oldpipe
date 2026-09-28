import Foundation

// MARK: - ChannelGroup
// A user-defined subset of the subscribed channels ("Music", "News"...). Stores channel
// ids only: membership is always intersected with the live subscription list at read time,
// so unsubscribing needs no cleanup pass — a stale id is simply inert.

struct ChannelGroup {
    let id: String              // UUID
    var name: String
    var channelIds: [String]    // UC…
    let createdAt: Double       // epoch seconds

    func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "channelIds": channelIds,
            "createdAt": createdAt
        ]
    }

    static func from(dict: [String: Any]) -> ChannelGroup? {
        guard let id = dict["id"] as? String, !id.isEmpty else { return nil }
        // (createdAt read via NSNumber — `as? Double` silently fails on the 5.1.5 runtime)
        return ChannelGroup(
            id: id,
            name: (dict["name"] as? String) ?? "",
            channelIds: (dict["channelIds"] as? [String]) ?? [],
            createdAt: (dict["createdAt"] as? NSNumber)?.doubleValue ?? 0
        )
    }
}
