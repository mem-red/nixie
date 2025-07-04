//
//  NixieClockApp.swift
//  NixieClock
//
//  Created by zignis on 02/07/25.
//

import Sparkle
import SwiftUI

@main
struct NixieClockApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var updaterController: SPUStandardUpdaterController?

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let updaterController {
                    ContentView(updaterController.updater)
                        .frame(
                            minWidth: 420,
                            maxWidth: 420,
                            minHeight: 240,
                            maxHeight: 240,
                        )
                } else {
                    Text("Nixie update checker has not been initialized yet.")
                        .padding()
                }
            }
            .onReceive(appDelegate.$updaterController) { newValue in
                updaterController = newValue
            }
        }
        .windowResizability(.contentSize)
    }
}
