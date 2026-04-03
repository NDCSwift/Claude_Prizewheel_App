import SwiftUI

struct PrizeWheelView: View {
    let items: [WheelItem]
    var showSpinButton: Bool = true
    let onWin: (WheelItem) -> Void

    @State private var rotationDegrees: Double = 0
    @State private var isSpinning = false

    private let pointerHeight: CGFloat = 28

    var body: some View {
        VStack(spacing: 20) {
            wheelSection
            if showSpinButton {
                spinButton
            }
        }
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
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Spin Button

    private var spinButton: some View {
        Button {
            spin()
        } label: {
            Text("SPIN")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSpinning ? Color.gray : Color.blue, in: .capsule)
        }
        .disabled(isSpinning)
        .padding(.horizontal)
    }

    // MARK: - Spin Logic

    private func spin() {
        guard !items.isEmpty else { return }
        isSpinning = true

        let extraDegrees = Double.random(in: 1800...3600)
        let targetDegrees = rotationDegrees + extraDegrees

        withAnimation(.easeOut(duration: 3.5)) {
            rotationDegrees = targetDegrees
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let winnerIndex = calculateWinnerIndex()
            isSpinning = false
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
            let baseWidth: CGFloat = 20
            var path = Path()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            path.addLine(to: CGPoint(x: size.width / 2 - baseWidth / 2, y: 0))
            path.addLine(to: CGPoint(x: size.width / 2 + baseWidth / 2, y: 0))
            path.closeSubpath()

            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                ctx.fill(path, with: .color(.red))
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
            context.stroke(wedgePath, with: .color(.white.opacity(0.3)), lineWidth: 1)

            let bisector = startAngle + wedgeAngle / 2
            let wedgeColor = Color(hex: item.colorHex)
            drawLabel(
                in: &context,
                text: item.name,
                angle: bisector,
                center: center,
                radius: radius,
                textColor: .white
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
