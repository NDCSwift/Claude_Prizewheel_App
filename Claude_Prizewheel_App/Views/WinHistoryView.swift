import SwiftUI
import SwiftData

struct WinHistoryView: View {
    @Query(sort: \WinRecord.timestamp, order: .reverse)
    private var records: [WinRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .navigationTitle("Win History")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No wins yet",
            systemImage: "trophy",
            description: Text("Give the wheel a spin!")
        )
    }

    // MARK: - Record List

    private var recordList: some View {
        List(groupedRecords, id: \.name) { entry in
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: entry.colorHex))
                    .frame(width: 28, height: 28)

                Text(entry.name)

                Spacer()

                Text("\(entry.count)")
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Grouping

    private var groupedRecords: [WinEntry] {
        Dictionary(grouping: records, by: \.itemName)
            .map { name, records in
                WinEntry(
                    name: name,
                    colorHex: records.first?.itemColorHex ?? "#888888",
                    count: records.count
                )
            }
            .sorted { $0.count > $1.count }
    }
}

// MARK: - Supporting Type

private struct WinEntry {
    let name: String
    let colorHex: String
    let count: Int
}

#Preview {
    WinHistoryView()
        .modelContainer(
            for: [WinRecord.self],
            inMemory: true
        )
}
