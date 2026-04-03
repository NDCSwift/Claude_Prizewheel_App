import SwiftUI
import SwiftData

struct WheelItemsView: View {
    let viewModel: WheelViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var showingItemForm = false
    @State private var editingItem: WheelItem?
    @State private var showMinItemsAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                wheelPreview
                itemList
            }
            .navigationTitle("Wheel Items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingItem = nil
                        showingItemForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingItemForm) {
                AddEditItemView(
                    editingItem: editingItem,
                    viewModel: viewModel
                )
            }
            .alert("Minimum Items", isPresented: $showMinItemsAlert) {
                Button("OK") {}
            } message: {
                Text("The wheel needs at least 2 items.")
            }
        }
    }

    // MARK: - Wheel Preview

    private var wheelPreview: some View {
        PrizeWheelView(
            items: viewModel.items,
            showSpinButton: false
        ) { _ in }
            .allowsHitTesting(false)
            .padding(.horizontal, 60)
            .padding(.vertical, 8)
    }

    // MARK: - Item List

    private var itemList: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                Button {
                    editingItem = item
                    showingItemForm = true
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: item.colorHex))
                            .frame(width: 28, height: 28)

                        Text(item.name)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        guard let index = offsets.first else { return }

        if viewModel.items.count <= 2 {
            showMinItemsAlert = true
        } else {
            viewModel.deleteItem(viewModel.items[index], context: modelContext)
        }
    }
}

#Preview {
    WheelItemsView(viewModel: WheelViewModel())
        .modelContainer(
            for: [WheelItem.self, WinRecord.self],
            inMemory: true
        )
}
