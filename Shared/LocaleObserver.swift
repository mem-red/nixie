//
//  LocaleObserver.swift
//  NixieClock
//
//  Created by zignis on 03/07/25.
//

import Combine
import Foundation

final class LocaleObserver: ObservableObject {
    @Published var is24HourCycle = detect24HourCycle()
    private var observer: AnyCancellable?

    init() {
        observer = NotificationCenter.default
            .publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                is24HourCycle = LocaleObserver.detect24HourCycle()
            }
    }

    deinit {
        observer?.cancel()
        observer = nil
    }

    private static func detect24HourCycle() -> Bool {
        if #available(macOS 13.0, *) {
            return Locale.current.hourCycle == .zeroToTwentyThree
        }

        let template = "j"
        let format =
            DateFormatter.dateFormat(
                fromTemplate: template,
                options: 0,
                locale: Locale.current,
            ) ?? ""
        return !format.lowercased().contains("a")
    }
}
