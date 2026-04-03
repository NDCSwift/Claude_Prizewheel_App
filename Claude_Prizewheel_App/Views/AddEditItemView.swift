import SwiftUI
import SwiftData

struct AddEditItemView: View {
    let editingItem: WheelItem?
    let viewModel: WheelViewModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = Color.blue

    private var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $name)
                ColorPicker("Color", selection: $color, supportsOpacity: false)
            }
            .navigationTitle(isEditing ? "Edit Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item = editingItem {
                    name = item.name
                    color = Color(hex: item.colorHex)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let hex = color.toHex()

        if let item = editingItem {
            viewModel.updateItem(item, name: trimmedName, colorHex: hex, context: modelContext)
        } else {
            let newItem = WheelItem(name: trimmedName, colorHex: hex)
            viewModel.addItem(newItem, context: modelContext)
        }

        dismiss()
    }
}

#Preview("Add Mode") {
    AddEditItemView(editingItem: nil, viewModel: WheelViewModel())
        .modelContainer(for: WheelItem.self, inMemory: true)
}
