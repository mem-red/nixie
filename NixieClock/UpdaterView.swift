//
//  UpdaterView.swift
//  NixieClock
//
//  Created by zignis on 04/07/25.
//

import Sparkle
import SwiftUI

// This view model class publishes when new updates can be checked by the user
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

// This intermediate view is necessary for the disabled state on the menu item to work properly before Monterey.
// See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more info.
struct UpdaterView: View {
    @ObservedObject private var checkForUpdatesViewModel:
        CheckForUpdatesViewModel
    private let updater: SPUUpdater

    init(_ updater: SPUUpdater) {
        self.updater = updater

        // Create our view model for our CheckForUpdatesView
        checkForUpdatesViewModel = CheckForUpdatesViewModel(
            updater: updater,
        )
    }

    var body: some View {
        Button(
            "Check for updates…",
            action: {
                updater.checkForUpdates()
            },
        )
        .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}
