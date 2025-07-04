//
//  CanvasView.swift
//  Nixie
//
//  Created by zignis on 02/07/25.
//

import SwiftUI

private struct Elements {
    let base: CElement
    let colon: CElement
    //
    let tubeADigits: [CElement]
    let tubeAEnvOff: CElement
    let tubeAOff: CElement
    //
    let tubeBDigits: [CElement]
    let tubeBEnvOff: CElement
    let tubeBOff: CElement
    //
    let tubeCDigits: [CElement]
    let tubeCEnvOff: CElement
    let tubeCOff: CElement
    //
    let tubeDDigits: [CElement]
    let tubeDEnvOff: CElement
    let tubeDOff: CElement
    //
    let supportRodA: CElement
    let supportRodB: CElement
    let supportRodC: CElement
}

public enum CanvasContainer {
    case widgetMedium, widgetExtraLarge, screenSaver

    fileprivate var imageScale: String {
        switch self {
        case .widgetMedium: "1x"
        case .widgetExtraLarge: "2x"
        case .screenSaver: "3x"
        }
    }
}

private enum MeridiemIndicator: String {
    case am = "AM"
    case pm = "PM"
}

public struct CanvasView: View {
    private let container: CanvasContainer
    private let hour: Int?
    private let minute: Int?
    private let elements: Elements?
    private let screenMidY: CGFloat

    @State private var primaryCanvasHeight: CGFloat = .zero
    @StateObject private var localeObserver = LocaleObserver()

    /// Initializes the canvas with image scale and optional static time values.
    /// - Parameters:
    ///   - container: The container that wraps this canvas view.
    ///   - hour: Optional hour value for static rendering.
    ///   - minute: Optional minute value for static rendering.
    ///   - bundle: Optional bundle to search for the resources (default is the main app bundle).
    ///   - screenMidY: Optional screen Y axis center value for the screen saver.
    init(
        container: CanvasContainer = .widgetExtraLarge,
        hour: Int? = nil,
        minute: Int? = nil,
        bundle: Bundle = .main,
        screenMidY: CGFloat = .zero
    ) {
        self.container = container
        self.hour = hour
        self.minute = minute
        self.screenMidY = screenMidY

        do {
            let scale = container.imageScale

            elements = try Elements(
                base: CElement(.base, "base_default_\(scale)", bundle: bundle),
                colon: CElement(.colon, "colon_on_\(scale)", bundle: bundle),
                // Tube A
                tubeADigits: (0 ... 2).map {
                    try CElement(
                        .tube(.a),
                        "tube_a_0\($0)_\(scale)",
                        bundle: bundle,
                    )
                },
                tubeAEnvOff: CElement(
                    .tube(.a),
                    "tube_a_env_off_\(scale)",
                    bundle: bundle,
                ),
                tubeAOff: CElement(
                    .tube(.a),
                    "tube_a_off_\(scale)",
                    bundle: bundle,
                ),
                // Tube B
                tubeBDigits: (0 ... 9).map {
                    try CElement(
                        .tube(.b),
                        "tube_b_0\($0)_\(scale)",
                        bundle: bundle,
                    )
                },
                tubeBEnvOff: CElement(
                    .tube(.b),
                    "tube_b_env_off_\(scale)",
                    bundle: bundle,
                ),
                tubeBOff: CElement(
                    .tube(.b),
                    "tube_b_off_\(scale)",
                    bundle: bundle,
                ),
                // Tube C
                tubeCDigits: (0 ... 5).map {
                    try CElement(
                        .tube(.c),
                        "tube_c_0\($0)_\(scale)",
                        bundle: bundle,
                    )
                },
                tubeCEnvOff: CElement(
                    .tube(.c),
                    "tube_c_env_off_\(scale)",
                    bundle: bundle,
                ),
                tubeCOff: CElement(
                    .tube(.c),
                    "tube_c_off_\(scale)",
                    bundle: bundle,
                ),
                // Tube D
                tubeDDigits: (0 ... 9).map {
                    try CElement(
                        .tube(.d),
                        "tube_d_0\($0)_\(scale)",
                        bundle: bundle,
                    )
                },
                tubeDEnvOff: CElement(
                    .tube(.d),
                    "tube_d_env_off_\(scale)",
                    bundle: bundle,
                ),
                tubeDOff: CElement(
                    .tube(.d),
                    "tube_d_off_\(scale)",
                    bundle: bundle,
                ),
                //
                supportRodA: CElement(.supportRod(.a), "rod", bundle: bundle),
                supportRodB: CElement(.supportRod(.b), "rod", bundle: bundle),
                supportRodC: CElement(.supportRod(.c), "rod", bundle: bundle),
            )
        } catch {
            elements = nil
            print("element load failed:", error)
        }
    }

    public var body: some View {
        if let elements {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    ZStack {
                        // Digit tubes
                        if let hour, let minute {
                            Canvas(opaque: false) {
                                context,
                                    size in
                                drawDigitTubes(
                                    in: &context,
                                    canvasSize: size,
                                    hour: hour,
                                    minute: minute,
                                )
                            }
                        } else {
                            // Start from the full minute to avoid clock lag
                            let start =
                                Calendar.current.dateInterval(
                                    of: .minute,
                                    for: Date(),
                                )?.start ?? Date()

                            TimelineView(
                                .periodic(from: start, by: 60.0),
                            ) {
                                tlCtx in
                                Canvas(opaque: true) {
                                    context,
                                        size in
                                    let comps = Calendar.current.dateComponents(
                                        [.hour, .minute],
                                        from: tlCtx.date,
                                    )
                                    let hour = comps.hour ?? 0
                                    let minute = comps.minute ?? 0

                                    drawDigitTubes(
                                        in: &context,
                                        canvasSize: size,
                                        hour: hour,
                                        minute: minute,
                                    )
                                }
                            }
                        }

                        // Colon and base plate
                        Canvas(opaque: false) {
                            context,
                                size in
                            drawElement(
                                in: context,
                                canvasSize: size,
                                element: elements.colon,
                            )
                            drawElement(
                                in: context,
                                canvasSize: size,
                                element: elements.base,
                            )
                        }
                    }
                    .onAppear {
                        primaryCanvasHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size.height) { newHeight in
                        primaryCanvasHeight = newHeight
                    }
                }
                .aspectRatio(canvasAspectRatio, contentMode: .fill)
                .frame(maxWidth: .infinity)

                // Support rods
                Canvas(opaque: false) {
                    context,
                        size in
                    for rod in [
                        elements.supportRodA, elements.supportRodB,
                        elements.supportRodC,
                    ] {
                        drawRod(in: context, canvasSize: size, rod: rod)
                    }
                }
                .frame(maxWidth: .infinity)
                .layoutPriority(1)
            }
            .padding(.top, max(0, screenMidY - (primaryCanvasHeight / 2))) // Center the primary canvas in screen saver
        } else {
            Text(
                container == .screenSaver
                    ? "Assets are missing for the Nixie screen saver. Please reinstall the bundle."
                    : "Missing assets",
            ).foregroundStyle(.secondary)
        }
    }

    /// Draws the digit tubes in the canvas.
    ///
    /// - Parameters:
    ///   - context: The canvas context.
    ///   - canvasSize: The size of canvas.
    ///   - hour: The clock hour value (must be in 24 hour cycle).
    ///   - minute: The clock minute value.
    private func drawDigitTubes(
        in context: inout GraphicsContext,
        canvasSize: CGSize,
        hour hour24Cycle: Int,
        minute: Int,
    ) {
        guard let elements else { return }

        let hour =
            if localeObserver.is24HourCycle {
                hour24Cycle
            } else {
                hour24Cycle % 12 == 0 ? 12 : hour24Cycle % 12
            }

        for element in [
            elements.tubeADigits[min(hour / 10, 2)],
            elements.tubeBDigits[hour % 10],
            elements.tubeCDigits[min(minute / 10, 5)],
            elements.tubeDDigits[minute % 10],
        ] {
            drawElement(
                in: context,
                canvasSize: canvasSize,
                element: element,
            )
        }

        if !localeObserver.is24HourCycle {
            drawMeridiem(
                in: &context,
                canvasSize: canvasSize,
                indicator: hour24Cycle >= 12 ? .pm : .am,
            )
        }
    }

    /// Draws a meridiem indicator (AM/PM) in the canvas.
    ///
    /// - Parameters:
    ///   - context: The canvas context.
    ///   - canvasSize: The size of canvas.
    ///   - indicator: The value of indicator to draw.
    private func drawMeridiem(
        in context: inout GraphicsContext,
        canvasSize: CGSize,
        indicator: MeridiemIndicator,
    ) {
        // < 900 = inside the screen saver preview window
        if container == .screenSaver, primaryCanvasHeight < 150 {
            return
        }

        let fontSize =
            switch container {
            case .widgetMedium: 14.0
            case .widgetExtraLarge: 18.0
            case .screenSaver: 20.0
            }

        var text = context.resolve(
            Text(indicator.rawValue).font(.system(size: fontSize)),
        )
        text.shading = .color(.secondary)

        let textSize = text.measure(in: canvasSize)
        let (centerX, centerY) = (0.5, 0.12)
        let rect = CGRect(
            origin: CGPoint(
                x: centerX * canvasSize.width - textSize.width / 2,
                y: centerY * canvasSize.height - textSize.height / 2,
            ),
            size: textSize,
        )

        context.opacity = 0.35
        context.draw(text, in: rect)
        context.opacity = 1
    }

    /// Draws an element inside a canvas.
    ///
    /// - Parameters:
    ///   - context: The canvas context.
    ///   - canvasSize: The size of canvas.
    ///   - element: The element to draw.
    private func drawElement(
        in context: GraphicsContext,
        canvasSize: CGSize,
        element: CElement,
    ) {
        let center = element.type.getRelativeCenter()
        let elSize = element.type.getRelativeSize()

        let absSize = CGSize(
            width: elSize.width * canvasSize.width,
            height: elSize.height * canvasSize.height,
        )
        let absOrigin = CGPoint(
            x: center.x * canvasSize.width - absSize.width / 2,
            y: center.y * canvasSize.height - absSize.height / 2,
        )

        context.draw(
            context.resolve(element.inner),
            in: CGRect(origin: absOrigin, size: absSize),
        )
    }

    /// Draws a support rod inside a canvas that spans the entire height.
    ///
    /// - Parameters:
    ///   - context: The canvas context.
    ///   - canvasSize: The size of canvas.
    ///   - rod: The rod element to draw.
    private func drawRod(
        in context: GraphicsContext,
        canvasSize: CGSize,
        rod: CElement,
    ) {
        let center = rod.type.getRelativeCenter()
        let elSize = rod.type.getRelativeSize()

        let absSize = CGSize(
            width: elSize.width * canvasSize.width,
            height: canvasSize.height, // Full height
        )
        let absOrigin = CGPoint(
            x: center.x * canvasSize.width - absSize.width / 2,
            y: 0, // Top of the canvas
        )

        context.draw(
            context.resolve(rod.inner),
            in: CGRect(origin: absOrigin, size: absSize),
        )
    }
}

#Preview("Size: Medium") {
    CanvasView(container: .widgetMedium)
        .frame(width: 364, height: 180)
}

#Preview("Size: Extra large") {
    CanvasView(container: .widgetExtraLarge)
        .frame(width: 744, height: 378)
}

#Preview("Screen Saver") {
    VStack(alignment: .center) {
        Spacer()
        CanvasView(container: .screenSaver)
            .frame(maxWidth: 500).padding(.top, 50)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
