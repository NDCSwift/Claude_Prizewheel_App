Claude Creates Feature Prompts (Prize Wheel)

PROMPT 1 — Context Brief

You are helping me build a Prize Wheel feature for an iOS app.

Here is the complete scope so you have full context before we write any code:

Feature overview:
- A customisable spinning prize wheel
- Users can add, edit, and delete custom wheel items (each with a name and colour)
- Tapping Spin triggers a realistic deceleration animation
- The winning item is determined by where the wheel stops
- Each win is saved to SwiftData with a timestamp
- A win history view shows total wins grouped by item

Technical constraints:
- SwiftUI only — no UIKit
- SwiftData for persistence — iOS 17+ minimum deployment target
- @Observable for all view models — no ObservableObject
- No third-party libraries
- MVVM structure — models, view model, and views in separate files
- Canvas-based wheel drawing — not a ZStack of rotated shapes

We will build this in stages. Each prompt will have one job.
Do not write any code yet.
Confirm you understand the full scope and list back what you plan to build in order.


PROMPT 2 — SwiftData Models

Build the SwiftData data models. Two models:

1. WheelItem
   - id: UUID, default UUID()
   - name: String
   - colorHex: String (we store color as a hex string — SwiftData cannot store Color directly)
   - createdAt: Date, default .now

2. WinRecord
   - id: UUID, default UUID()
   - itemName: String (store the name at the time of the win — the item may be deleted later)
   - itemColorHex: String
   - timestamp: Date, default .now

Also create:
- A Color+Hex.swift extension with init(hex:) and a .toHex() -> String method
- A WheelItem+Defaults.swift file with at least 6 default WheelItem values for first launch

Use @Model for both. Each model in its own file. No views. No view model yet.


PROMPT 3 — Prize Wheel View (Static)

Build PrizeWheelView — a static visual of the prize wheel. No animation or spin logic yet.

Requirements:
- Takes [WheelItem] as input
- Draws the wheel using Canvas — not a ZStack of rotated shapes
- Wedges are divided equally based on item count
- Each wedge is filled with its item's Color (converted from colorHex)
- Each wedge has the item's name as text, rotated to sit along the wedge radius, readable from outside the wheel
- A solid triangular pointer sits at the top centre of the wheel, outside the circle
- The wheel is square and fills available width using a GeometryReader
- Text in wedges uses white with a shadow for legibility on any colour

Add a #Preview that passes the default WheelItems so I can see it immediately in the canvas.
Do not add a spin button or any gesture yet.

PROMPT 4 — Spin Animation + Winner Logic

Add spin animation and winner selection to PrizeWheelView.

Requirements:
- Add @State var rotationDegrees: Double = 0
- Add @State var isSpinning: Bool = false
- The spin adds a random amount between 1800 and 3600 degrees (5–10 full rotations) to the current rotationDegrees
- Use withAnimation(.easeOut(duration: 3.5)) for the spin
- Apply .rotationEffect(Angle(degrees: rotationDegrees)) to the Canvas
- After the animation completes, calculate the winning wedge from the final rotationDegrees

Winner calculation:
- The pointer is at the top (270 degrees in standard coordinates)
- Normalise the final rotation to 0–360 using fmod
- Each wedge spans 360 / items.count degrees
- The winning index = Int((normalised angle) / wedgeDegrees) modulo items.count

Add a Spin button below the wheel:
- Disabled while isSpinning is true
- On tap: set isSpinning = true, trigger the animation, call onWin(items[winnerIndex]) via a completion, set isSpinning = false

Add an onWin: (WheelItem) -> Void closure parameter to PrizeWheelView.
The view only reports the winner — it does not decide what to do with it.

PROMPT 5 — ViewModel + SwiftData Wiring

Create WheelViewModel and wire the app together.

WheelViewModel — @Observable class:
- Holds var items: [WheelItem] (fetched from SwiftData via ModelContext)
- func fetchItems(context: ModelContext) — fetches and sorts WheelItems by createdAt ascending
- func recordWin(_ item: WheelItem, context: ModelContext) — creates and inserts a WinRecord
- func addItem(_ item: WheelItem, context: ModelContext)
- func deleteItem(_ item: WheelItem, context: ModelContext)
- On first launch (items is empty after fetch), insert the default WheelItems

ContentView:
- @Environment(\.modelContext) private var modelContext
- @State private var viewModel = WheelViewModel()
- @State private var winnerItem: WheelItem? = nil
- @State private var showWinnerSheet = false
- Call viewModel.fetchItems(context: modelContext) in .onAppear
- Pass viewModel.items to PrizeWheelView
- On onWin: call viewModel.recordWin, set winnerItem, set showWinnerSheet = true
- Present a sheet when showWinnerSheet is true showing the winner's name and a coloured circle using the item's Color
- Add a "Spin Again" button in the sheet that dismisses it

Update PrizeWheelDemoApp to include .modelContainer(for: [WheelItem.self, WinRecord.self])


PROMPT 6 — Item Management

Build the wheel item management UI.

WheelItemsView — a sheet for managing items:
- List of current WheelItems with swipe-to-delete
  - Validation: prevent deletion if it would leave fewer than 2 items — show an alert
- A toolbar button (top-right) to add a new item
- Tapping an existing row opens AddEditItemView in edit mode
- Tapping the add button opens AddEditItemView in add mode

AddEditItemView — a separate struct (not inline):
- TextField for the item name
- ColorPicker for the item colour
- On appear in edit mode: pre-fill with the existing item's values
- On save:
  - Validate name is not empty
  - Convert chosen Color to hex using .toHex()
  - Call viewModel.addItem or viewModel.updateItem via the passed ModelContext
- A Cancel button that dismisses without saving

Present WheelItemsView as a sheet from ContentView via a toolbar button (list icon).
The sheet should show a live preview of the wheel as items change — embed a smaller PrizeWheelView at the top of WheelItemsView using the current items array.


PROMPT 7 — Bug Fixes

Bug: White text is unreadable on light-coloured wedges (yellow, green).
Tested on Simulator

Expected: Text on light backgrounds should adapt to Black and text on dark backgrounds should adapt to white text for accessibility.

Do not change anything else in PrizeWheelView.

Bug: The winner sheet appears blank on the very first spin. In older versions landing on a sheet would appear with the proper color and name however now the blank sheet appears consistently. Tested on Simulator  Expected: Spinning the wheel and receiving a prize has the small sheet with prize name and color after winner is selected on any spin not the buggy blank full sheet

Bug: Default wheel items and any added items do not persist
across app launches unless a spin has occurred first. Tested on Simulator

Expected: After saving new items without spinning the user should be able to close the app and re launch with their changes in tact and properly saved.



PROMPT 8 — Win History View

Build WinHistoryView.

Requirements:
- Fetches all WinRecords using @Query sorted by timestamp descending
- Groups records by itemName using Dictionary(grouping:)
- Displays each unique item as a row with:
  - A coloured circle (Color from itemColorHex)
  - The item name
  - Total win count as a bold number on the right
- Sorted by win count descending
- Empty state: if no records exist, show a centred message — "No wins yet. Give the wheel a spin!"
- Present as a sheet from ContentView via a toolbar button (trophy icon)

Do not pass the records array from the parent — use @Query directly in WinHistoryView


PROMPT 9 — Polish

Final polish pass. Visual and haptic changes only — do not touch any data layer or existing business logic.

1. Haptic feedback: when the wheel stops and onWin fires, trigger UINotificationFeedbackGenerator with .success
2. Winner wedge highlight: when the winner sheet appears, apply a subtle pulsing scale animation (.scaleEffect) to the winning wedge in PrizeWheelView — pass the winning item's id in and highlight that wedge in the Canvas with a slightly lighter fill
3. Spin button states:
   - Default: "Spin" — filled, prominent
   - Spinning: show a ProgressView spinner instead of text, button disabled
   - If items.count < 2: hide the spin button entirely and show Text("Add at least 2 items to spin").foregroundStyle(.secondary)
4. Pointer visibility: make the triangular pointer larger, fill it with Color.primary, and add a small drop shadow
5. Wedge text legibility: ensure all wedge text uses white with a heavier text shadow — increase shadow radius to 4 and add a second shadow pass

Do not change PrizeWheelView's interface or the onWin closure signature.

PROMT 10 — Quick Bug Fix
Bug after the first spin the wheel goes very fast through its animation - hangs and finally shows the result instead of spinning fully until its actually done

Expected Result
The wheel spins until it slows and lands on the correct item
