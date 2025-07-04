//
//  NixieSaver.swift
//  NixieClock
//
//  Created by zignis on 03/07/25.
//  Taken from https://digitalbunker.dev/creating-a-macos-screensaver-in-swiftui/
//

import Foundation
import ScreenSaver
import SwiftUI

let saverMaxWidth: CGFloat = 1160.0

class NixieSaver: ScreenSaverView {
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        wantsLayer = true

        let hostingController = NSHostingController(
            rootView: ZStack {
                CanvasView(
                    container: .screenSaver,
                    bundle: Bundle(for: Self.self),
                    screenMidY: bounds.midY,
                )
                .frame(maxWidth: saverMaxWidth)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity),
        )

        hostingController.view.frame = bounds
        hostingController.view.autoresizingMask = [.width, .height]
        addSubview(hostingController.view)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        fatalError("not implemented")
    }
}
