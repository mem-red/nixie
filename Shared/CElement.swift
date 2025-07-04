//
//  CElement.swift
//  Nixie
//
//  Created by zignis on 02/07/25.
//

import SwiftUI

// MARK: - Constants

private let imgExtension = "png"

// MARK: - Element sizes and coordinates

// Canvas aspect ratio is 81:38 (based on 4050x1900 resolution)
let canvasAspectRatio = 81.0 / 38.0

// Element sizes computed relative to the 4050x1900 base resolution.
private let tubeSize = CGSize(width: 0.18059, height: 0.95936) // 731.4 x 1822.8
private let colonSize = CGSize(width: 0.06469, height: 0.74553) // 262 x 1416.5
private let baseSize = CGSize(width: 1.0, height: 0.08368) // 4050 x 159
let supportRodScale = CGSize(width: 0.02345, height: 1.0) // 95px width (height is irrelevant here)

/// Center points were determined by overlaying individual image elements in Figma,
/// measuring their distances from the origin, and normalizing them relative to the 4050x1900 canvas.

// Base plate
private let baseCenter = CGPoint(x: 0.5, y: 0.95832)

// Nixie tubes
private let colonCenter = CGPoint(x: 0.5, y: 0.62615)
private let tubeACenter = CGPoint(x: 0.14739, y: 0.48601)
private let tubeBCenter = CGPoint(x: 0.34511, y: 0.48601)
private let tubeCCenter = CGPoint(x: 0.65488, y: 0.48601)
private let tubeDCenter = CGPoint(x: 0.85260, y: 0.48601)

// Support rods
let supportRodACenter = CGPoint(x: 0.05913, y: 0.0)
let supportRodBCenter = CGPoint(x: 0.5, y: 0.0)
let supportRodCCenter = CGPoint(x: 0.94111, y: 0.0)

// MARK: - Enums

/// Index identifying one of the four digit tubes.
enum TubeIndex: Int {
    case a, b, c, d
}

/// Index identifying one of the three support rods.
enum SupportRodIndex: Int {
    case a, b, c
}

/// Represents the type of canvas element.
enum CElementType {
    case tube(TubeIndex)
    case colon, base
    case supportRod(SupportRodIndex)

    /// Returns the relative size of the element with respect to the canvas size.
    func getRelativeSize() -> CGSize {
        switch self {
        case .tube: tubeSize
        case .colon: colonSize
        case .base: baseSize
        case .supportRod: supportRodScale
        }
    }

    /// Returns the relative center point of the element with respect to the canvas.
    func getRelativeCenter() -> CGPoint {
        switch self {
        case let .tube(idx):
            switch idx {
            case .a: tubeACenter
            case .b: tubeBCenter
            case .c: tubeCCenter
            case .d: tubeDCenter
            }
        case let .supportRod(idx):
            switch idx {
            case .a: supportRodACenter
            case .b: supportRodBCenter
            case .c: supportRodCCenter
            }
        case .colon: colonCenter
        case .base: baseCenter
        }
    }
}

/// Represents a drawable canvas image element
struct CElement: Equatable {
    let id: String // Image names are unique
    let inner: Image
    let type: CElementType

    enum LoadError: Error {
        case notFound(String)
        case other(String)
    }

    /// Initializes a new canvas element by loading an image resource.
    /// - Parameters:
    ///   - type: The type of the element.
    ///   - src: The resource name of the image file (without extension).
    ///   - bundle: The bundle to search for the resources.
    /// - Throws: `LoadError.notFound` if the resource cannot be found, or `LoadError.other` if loading fails.
    init(
        _ type: CElementType,
        _ src: String,
        bundle: Bundle
    )
        throws
    {
        guard
            let url = bundle.url(
                forResource: src,
                withExtension: imgExtension,
            )
        else {
            throw LoadError.notFound(
                "image element \(src).\(imgExtension) not found in bundle",
            )
        }

        guard let nsImage = NSImage(contentsOf: url) else {
            throw LoadError.other(
                "failed to load image element from \(url.path)",
            )
        }

        id = src
        inner = Image(nsImage: nsImage)
        self.type = type
    }

    static func == (lhs: CElement, rhs: CElement) -> Bool {
        lhs.id == rhs.id
    }
}
