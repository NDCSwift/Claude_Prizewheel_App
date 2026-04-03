import Foundation
import SwiftData

@Observable
final class WheelViewModel {
    var items: [WheelItem] = []

    func fetchItems(context: ModelContext) {
        let descriptor = FetchDescriptor<WheelItem>(
            sortBy: [SortDescriptor(\.createdAt)]
        )

        do {
            items = try context.fetch(descriptor)

            if items.isEmpty {
                for item in WheelItem.defaults {
                    context.insert(item)
                }
                items = try context.fetch(descriptor)
                
            }
        } catch {
            items = []
        }
    }

    func recordWin(_ item: WheelItem, context: ModelContext) {
        let record = WinRecord(
            itemName: item.name,
            itemColorHex: item.colorHex
        )
        context.insert(record)
    }

    func addItem(_ item: WheelItem, context: ModelContext) {
        context.insert(item)
        fetchItems(context: context)
        
    }

    func updateItem(_ item: WheelItem, name: String, colorHex: String, context: ModelContext) {
        item.name = name
        item.colorHex = colorHex
        fetchItems(context: context)
    }

    func deleteItem(_ item: WheelItem, context: ModelContext) {
        context.delete(item)
        fetchItems(context: context)
        try? context.save()
    }
}
