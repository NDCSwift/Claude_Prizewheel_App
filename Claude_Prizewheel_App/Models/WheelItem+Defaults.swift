import Foundation

extension WheelItem {

    /// Default items to populate the wheel on first launch.
    static var defaults: [WheelItem] {
        [
            WheelItem(name: "Pizza Night", colorHex: "#FF5733"),
            WheelItem(name: "Movie Time", colorHex: "#33A1FF"),
            WheelItem(name: "Ice Cream", colorHex: "#FF33A8"),
            WheelItem(name: "Game Night", colorHex: "#33FF57"),
            WheelItem(name: "Day Off", colorHex: "#FFD633"),
            WheelItem(name: "Surprise", colorHex: "#8D33FF"),
        ]
    }
}
