import Foundation
import SwiftData

@Model
final class WinRecord {
    var id: UUID
    var itemName: String
    var itemColorHex: String
    var timestamp: Date

    init(
        id: UUID = UUID(),
        itemName: String,
        itemColorHex: String,
        timestamp: Date = .now
    ) {
        self.id = id
        self.itemName = itemName
        self.itemColorHex = itemColorHex
        self.timestamp = timestamp
    }
}
