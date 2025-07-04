//
//  ContentView.swift
//  NixieClock
//
//  Created by zignis on 02/07/25.
//

import Sparkle
import SwiftUI

let screenSaverDownloadUrl = URL(
    string: "https://github.com/mem-red/nixie?tab=readme-ov-file#screen-saver",
)!

struct ContentView: View {
    private let updater: SPUUpdater?

    init(_ updater: SPUUpdater? = nil) {
        self.updater = updater
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Add the Nixie widget")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Label(
                            "Go to your Home Screen and long-press on an empty area.",
                            systemImage: "hand.tap",
                        )
                        .padding(.trailing, 120)

                        Label(
                            "Tap the '+' button in the top left corner.",
                            systemImage: "plus.circle",
                        )

                        Label(
                            "Search for 'Nixie' in the widgets list.",
                            systemImage: "magnifyingglass",
                        )

                        Label(
                            "Tap 'Add Widget' to place it on your Home Screen.",
                            systemImage: "square.and.arrow.down",
                        )
                    }
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.top)
                }

                Image("AppIconPreview")
                    .resizable()
                    .frame(width: 76, height: 76)
                    .shadow(radius: 1)
                    .padding(.trailing, 10)
                    .padding(.top, 10)
            }

            Spacer()

            Divider()

            HStack {
                Link(
                    "Get Nixie Screen Saver",
                    destination: screenSaverDownloadUrl,
                )
                .buttonStyle(.link)

                Spacer()

                if let updater {
                    UpdaterView(updater)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .frame(
            maxWidth: 420,
            maxHeight: 240,
        )
}
