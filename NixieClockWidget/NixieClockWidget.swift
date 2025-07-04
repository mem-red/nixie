//
//  NixieClockWidget.swift
//  NixieWidget
//
//  Created by zignis on 02/07/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> NixieEntry {
        NixieEntry(date: Date())
    }

    func getSnapshot(
        in _: Context,
        completion: @escaping (NixieEntry) -> Void,
    ) {
        completion(NixieEntry(date: Date()))
    }

    func getTimeline(
        in _: Context,
        completion: @escaping (Timeline<Entry>) -> Void,
    ) {
        var entries: [NixieEntry] = []

        for minuteOffset in 0 ..< 15 {
            let currentDate = Date()
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: minuteOffset,
                to: currentDate,
            )!
            let entry = NixieEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct NixieEntry: TimelineEntry {
    let date: Date
}

struct NixieWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let comps = Calendar.current.dateComponents(
            [.hour, .minute],
            from: entry.date,
        )

        CanvasView(
            container: family == .systemMedium
                ? .widgetMedium : .widgetExtraLarge,
            hour: comps.hour,
            minute: comps.minute,
        )
        .padding(.top, family == .systemMedium ? 8 : 20)
        .aspectRatio(
            27 / (family == .systemMedium ? 14.2 : 14.5),
            contentMode: .fill,
        ) // Show more of the support rods
        .frame(maxWidth: .infinity)
    }
}

struct NixieClockWidget: Widget {
    let kind: String = "NixieWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, *) {
                NixieWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                NixieWidgetEntryView(entry: entry)
                    .padding()
                    .background(.clear)
            }
        }
        .configurationDisplayName("Nixie Clock")
        .description("Display time using a realistic Nixie tube clock.")
        .supportedFamilies(
            {
                if #available(macOS 14.0, *) {
                    [.systemMedium, .systemExtraLarge]
                } else {
                    [.systemMedium]
                }
            }(),
        )
    }
}
