import WidgetKit
import SwiftUI

@main
struct PrayerWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerClockWidget()
    }
}

struct PrayerClockWidget: Widget {
    let kind: String = "PrayerClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ساعة الفجر والصلوات")
        .description("ساعة الحرمين الرقمية الفاخرة لمواقيت الصلاة ودرجة الحرارة والتاريخ.")
        .supportedFamilies(supportedFamiliesList)
        .contentMarginsDisabledIfAvailable()
    }

    private var supportedFamiliesList: [WidgetFamily] {
        if #available(iOS 16.0, *) {
            return [.systemLarge, .systemMedium, .systemSmall, .accessoryRectangular, .accessoryInline]
        } else {
            return [.systemLarge, .systemMedium, .systemSmall]
        }
    }
}
