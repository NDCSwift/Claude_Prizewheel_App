import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WheelViewModel()
    @State private var winnerItem: WheelItem?
    @State private var showItemsSheet = false
    @State private var showHistorySheet = false

    var body: some View {
        NavigationStack {
            PrizeWheelView(items: viewModel.items) { winner in
                viewModel.recordWin(winner, context: modelContext)
                winnerItem = winner
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showItemsSheet = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showHistorySheet = true
                    } label: {
                        Image(systemName: "trophy")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchItems(context: modelContext)
        }
        .sheet(item: $winnerItem) { winner in
            VStack(spacing: 24) {
                Text("Winner!")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                Circle()
                    .fill(Color(hex: winner.colorHex))
                    .frame(width: 80, height: 80)
                    .shadow(radius: 4)

                Text(winner.name)
                    .font(.largeTitle.bold())

                Button("Spin Again") {
                    winnerItem = nil
                }
                .font(.title3.bold())
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showItemsSheet) {
            WheelItemsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showHistorySheet) {
            WinHistoryView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [WheelItem.self, WinRecord.self],
            inMemory: true
        )
}
