internal struct IdentifiableCharacter: Identifiable {
    var id: String { "\(index) \(character)" }

    let index: Int
    let character: Character
}

extension IdentifiableCharacter {
    var string: String { "\(character)" }
}
