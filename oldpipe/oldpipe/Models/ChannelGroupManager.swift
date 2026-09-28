import Foundation

// MARK: - ChannelGroupManager
// Persists channel groups to UserDefaults (key `channel_groups`), newest first.
// Mirrors the PlaylistManager / SubscriptionManager pattern.

class ChannelGroupManager {

    private static let defaultsKey = "channel_groups"

    static func all() -> [ChannelGroup] {
        return rawList().compactMap { ChannelGroup.from(dict: $0) }
    }

    static func group(id: String) -> ChannelGroup? {
        return rawList().first { ($0["id"] as? String) == id }.flatMap { ChannelGroup.from(dict: $0) }
    }

    // Create an empty group (inserted newest-first) and return it.
    @discardableResult
    static func create(name: String) -> ChannelGroup {
        let group = ChannelGroup(id: UUID().uuidString, name: name, channelIds: [],
                                 createdAt: Date().timeIntervalSince1970)
        var list = rawList()
        list.insert(group.toDict(), at: 0)
        save(list)
        return group
    }

    static func rename(id: String, to name: String) {
        var list = rawList()
        for i in 0..<list.count where (list[i]["id"] as? String) == id {
            list[i]["name"] = name
        }
        save(list)
    }

    static func delete(id: String) {
        var list = rawList()
        list.removeAll { ($0["id"] as? String) == id }
        save(list)
    }

    // Remove all groups (Settings → Reset All).
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        UserDefaults.standard.synchronize()
    }

    static func contains(channelId: String, in groupId: String) -> Bool {
        guard let g = group(id: groupId) else { return false }
        return g.channelIds.contains(channelId)
    }

    static func add(channelId: String, to groupId: String) {
        mutate(groupId) { ids in
            guard !ids.contains(channelId) else { return }
            ids.append(channelId)
        }
    }

    static func remove(channelId: String, from groupId: String) {
        mutate(groupId) { ids in
            ids.removeAll { $0 == channelId }
        }
    }

    // Merge imported groups into storage (config import). Upsert by id: an existing group
    // keeps its position and gains any channel ids not already present; a group with an
    // unknown id is inserted newest-first.
    static func merge(_ groups: [ChannelGroup]) {
        var list = rawList()
        for g in groups {
            if let idx = list.firstIndex(where: { ($0["id"] as? String) == g.id }) {
                var ids = (list[idx]["channelIds"] as? [String]) ?? []
                for cid in g.channelIds where !ids.contains(cid) {
                    ids.append(cid)
                }
                list[idx]["channelIds"] = ids
            } else {
                list.insert(g.toDict(), at: 0)
            }
        }
        save(list)
    }

    // MARK: - Private

    private static func mutate(_ groupId: String, _ body: (inout [String]) -> Void) {
        var list = rawList()
        for i in 0..<list.count where (list[i]["id"] as? String) == groupId {
            var ids = (list[i]["channelIds"] as? [String]) ?? []
            body(&ids)
            list[i]["channelIds"] = ids
        }
        save(list)
    }

    private static func save(_ list: [[String: Any]]) {
        UserDefaults.standard.set(list, forKey: defaultsKey)
        UserDefaults.standard.synchronize()
    }

    private static func rawList() -> [[String: Any]] {
        return (UserDefaults.standard.array(forKey: defaultsKey) as? [[String: Any]]) ?? []
    }
}
