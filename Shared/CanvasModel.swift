//
//  CanvasModel.swift
//  NixieClock
//
//  Created by zignis on 04/07/25.
//

import SwiftUI

public final class CanvasModel: ObservableObject {
    // Provides height of the primary canvas (excluding the support rods).
    // Used for centering the canvas to the screen.
    @Published public var primaryCanvasHeight: CGFloat = 0
}
