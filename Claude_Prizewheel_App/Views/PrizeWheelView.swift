import SwiftUI

struct PrizeWheelView: View {
    let items: [WheelItem]
    var showSpinButton: Bool = true
    let onWin: (WheelItem) -> Void

    @State private var rotationDegrees: Double = 0
    @State private var isSpinning = false
    @State private var highlightedItemID: UUID?
    @State private var isPulsing = false
    @State private var winTrigger = 0

    private let pointerHeight: CGFloat = 36

    var body: some View {
        VStack(spacing: 20) {
            wheelSection
            if showSpinButton {
                spinArea
            }
        }
        .sensoryFeedback(.success, trigger: winTrigger)
    }

    // MARK: - Wheel + Pointer

    private var wheelSection: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            let wheelDiameter = size - pointerHeight
            let wheelRadius = wheelDiameter / 2

            VStack(spacing: 0) {
                pointer
                    .frame(width: size, height: pointerHeight)

                wheelCanvas(radius: wheelRadius)
                    .frame(width: wheelDiameter, height: wheelDiameter)
                    .rotationEffect(.degrees(rotationDegrees))
                    .scaleEffect(isPulsing ? 1.03 : 1.0)
                    .animation(
                        isPulsing
                            ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                            : .default,
                        value: isPulsing
                    )
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Spin Area

    @ViewBuilder
    private var spinArea: some View {
        if items.count < 2 {
            Text("Add at least 2 items to spin")
                .foregroundStyle(.secondary)
        } else {
            spinButton
        }
    }

    // MARK: - Spin Button

    private var spinButton: some View {
        Button {
            spin()
        } label: {
            Group {
                if isSpinning {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("SPIN")
                        .font(.title2.bold())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .disabled(isSpinning)
        .padding(.horizontal)
    }

    // MARK: - Spin Logic

    private func spin() {
        guard !items.isEmpty else { return }
        isSpinning = true
        highlightedItemID = nil
        isPulsing = false

        let extraDegrees = Double.random(in: 1800...3600)
        let targetDegrees = rotationDegrees + extraDegrees

        withAnimation(.easeOut(duration: 3.5)) {
            rotationDegrees = targetDegrees
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let winnerIndex = calculateWinnerIndex()
            isSpinning = false
            highlightedItemID = items[winnerIndex].id
            isPulsing = true
            winTrigger += 1
            onWin(items[winnerIndex])
        }
    }

    private func calculateWinnerIndex() -> Int {
        let wedgeDegrees = 360.0 / Double(items.count)
        var normalized = rotationDegrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }

        let pointerAngle = (360 - normalized).truncatingRemainder(dividingBy: 360)
        return Int(pointerAngle / wedgeDegrees) % items.count
    }

    // MARK: - Wheel Canvas

    private func wheelCanvas(radius: CGFloat) -> some View {
        let center = CGPoint(x: radius, y: radius)
        return Canvas { context, _ in
            drawWedges(in: &context, center: center, radius: radius)
        }
    }

    // MARK: - Pointer

    private var pointer: some View {
        Canvas { context, size in
            let baseWidth: CGFloat = 28
            var path = Path()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            path.addLine(to: CGPoint(x: size.width / 2 - baseWidth / 2, y: 0))
            path.addLine(to: CGPoint(x: size.width / 2 + baseWidth / 2, y: 0))
            path.closeSubpath()

            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2))
                ctx.fill(path, with: .color(.primary))
            }
        }
    }

    // MARK: - Drawing

    private func drawWedges(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        guard !items.isEmpty else { return }

        let wedgeAngle = 2 * .pi / Double(items.count)
        let startOffset = -Double.pi / 2

        for (index, item) in items.enumerated() {
            let startAngle = startOffset + wedgeAngle * Double(index)
            let endAngle = startAngle + wedgeAngle

            var wedgePath = Path()
            wedgePath.move(to: center)
            wedgePath.addArc(
                center: center,
                radius: radius,
                startAngle: .radians(startAngle),
                endAngle: .radians(endAngle),
                clockwise: false
            )
            wedgePath.closeSubpath()

            context.fill(wedgePath, with: .color(Color(hex: item.colorHex)))

            if item.id == highlightedItemID {
                context.fill(wedgePath, with: .color(.white.opacity(0.25)))
            }

            context.stroke(wedgePath, with: .color(.white.opacity(0.3)), lineWidth: 1)

            let bisector = startAngle + wedgeAngle / 2
            let wedgeColor = Color(hex: item.colorHex)
            drawLabel(
                in: &context,
                text: item.name,
                angle: bisector,
                center: center,
                radius: radius,
                textColor: wedgeColor.isDark ? .white : .black
            )
        }

        let ring = Circle().path(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        context.stroke(ring, with: .color(.white.opacity(0.5)), lineWidth: 2)
    }

    private func drawLabel(
        in context: inout GraphicsContext,
        text: String,
        angle: Double,
        center: CGPoint,
        radius: CGFloat,
        textColor: Color
    ) {
        let distance = radius * 0.62
        let fontSize = radius * 0.08
        let flipped = cos(angle) < 0
        let shadowColor: Color = textColor == .white ? .black : .white

        context.drawLayer { ctx in
            ctx.addFilter(.shadow(color: shadowColor.opacity(0.7), radius: 1, x: 0, y: 1))
            ctx.translateBy(x: center.x, y: center.y)

            let resolved = ctx.resolve(
                Text(text)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundStyle(textColor)
            )

            if flipped {
                ctx.rotate(by: .radians(angle + .pi))
                ctx.draw(resolved, at: CGPoint(x: -distance, y: 0), anchor: .center)
            } else {
                ctx.rotate(by: .radians(angle))
                ctx.draw(resolved, at: CGPoint(x: distance, y: 0), anchor: .center)
            }
        }
    }
}

#Preview {
    PrizeWheelView(items: WheelItem.defaults) { winner in
        print("Winner: \(winner.name)")
    }
    .padding()
}
