import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WheelViewModel()
    @State private var winnerItem: WheelItem?
    @State private var showWinnerSheet = false
    @State private var showItemsSheet = false

    var body: some View {
        NavigationStack {
            PrizeWheelView(items: viewModel.items) { winner in
                winnerItem = winner
                showWinnerSheet = true
                viewModel.recordWin(winner, context: modelContext)
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
            }
        }
        .onAppear {
            viewModel.fetchItems(context: modelContext)
        }
        .sheet(isPresented: $showWinnerSheet) {
            winnerSheet
        }
        .sheet(isPresented: $showItemsSheet) {
            WheelItemsView(viewModel: viewModel)
        }
    }

    // MARK: - Winner Sheet

    @ViewBuilder
    private var winnerSheet: some View {
        if let winner = winnerItem {
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
                    showWinnerSheet = false
                }
                .font(.title3.bold())
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .presentationDetents([.medium])
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
