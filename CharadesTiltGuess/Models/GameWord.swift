struct GameWord: Codable, Hashable, Identifiable {
    let id: String
    let text: String
    var meaning: String? = nil
}
