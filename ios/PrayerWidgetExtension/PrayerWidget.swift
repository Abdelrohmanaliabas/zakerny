import WidgetKit
import SwiftUI

struct PrayerEntry: TimelineEntry {
    let date: Date
    let data: PrayerData
    let renderedImage: UIImage?
}

struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        let sampleData = PrayerData()
        return PrayerEntry(date: Date(), data: sampleData, renderedImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        let data = PrayerData.loadFromSharedDefaults()
        let img = PrayerWidgetRenderer.loadRenderedImageFromSharedStorage() ?? PrayerWidgetRenderer.renderClockImage(data: data)
        let entry = PrayerEntry(date: Date(), data: data, renderedImage: img)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let data = PrayerData.loadFromSharedDefaults()
        let img = PrayerWidgetRenderer.loadRenderedImageFromSharedStorage() ?? PrayerWidgetRenderer.renderClockImage(data: data)
        let currentDate = Date()
        let entry = PrayerEntry(date: currentDate, data: data, renderedImage: img)

        // Refresh every 15 minutes to keep battery consumption low while remaining accurate
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct PrayerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: PrayerEntry

    var body: some View {
        Group {
            switch family {
            case .systemLarge:
                PrayerWidgetLargeView(entry: entry)
            case .systemMedium:
                PrayerWidgetMediumView(entry: entry)
            case .systemSmall:
                PrayerWidgetSmallView(entry: entry)
            default:
                if #available(iOS 16.0, *) {
                    PrayerWidgetAccessoryView(entry: entry, family: family)
                } else {
                    PrayerWidgetSmallView(entry: entry)
                }
            }
        }
        .widgetBackground(Color.black)
        .widgetURL(URL(string: "zakerny://prayer-clock"))
    }
}

// MARK: - 1. Large 3D Al-Fajia Mosque Clock View (Identical to Android)
struct PrayerWidgetLargeView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            Color.black

            if let img = entry.renderedImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let rendered = PrayerWidgetRenderer.renderClockImage(data: entry.data) {
                Image(uiImage: rendered)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Fallback SwiftUI render using base image
                ZStack {
                    Image("al_fajia_widget_base")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack(spacing: 8) {
                        Spacer().frame(height: 70)
                        Text(entry.data.currentTime)
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.15, blue: 0.15))
                        Text(entry.data.gregDate)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
                        Text(entry.data.city)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.1))
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - 2. Medium Luxury Islamic Banner View
struct PrayerWidgetMediumView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.06, blue: 0.08), Color(red: 0.08, green: 0.11, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 12) {
                // Left Column: City, Live Time, Date, Next Prayer Chip
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.85, green: 0.70, blue: 0.25))
                        Text(entry.data.city)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.90, green: 0.80, blue: 0.50))
                        Spacer()
                        Text("\(entry.data.temp)°C")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                    }

                    Text(entry.data.currentTime)
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.15, blue: 0.15))
                        .shadow(color: Color.red.opacity(0.4), radius: 6, x: 0, y: 0)

                    Text(entry.data.gregDate)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))

                    Spacer()

                    // Next Prayer Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.2, blue: 0.2))
                            .frame(width: 7, height: 7)
                        Text("القادمة: \(entry.data.nextPrayerName)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Text(entry.data.nextPrayerTime)
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0.95, green: 0.80, blue: 0.35))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.15, green: 0.18, blue: 0.22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.85, green: 0.70, blue: 0.25).opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.70, blue: 0.25).opacity(0.25))
                    .frame(width: 1)

                // Right Column: Prayers Grid
                VStack(spacing: 3) {
                    prayerRow(name: "الفجر", key: "fajr", time: entry.data.fajr)
                    prayerRow(name: "الشروق", key: "sunrise", time: entry.data.sunrise)
                    prayerRow(name: "الظهر", key: "dhuhr", time: entry.data.dhuhr)
                    prayerRow(name: "العصر", key: "asr", time: entry.data.asr)
                    prayerRow(name: "المغرب", key: "maghrib", time: entry.data.maghrib)
                    prayerRow(name: "العشاء", key: "isha", time: entry.data.isha)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
    }

    private func prayerRow(name: String, key: String, time: String) -> some View {
        let isActive = key.caseInsensitiveCompare(entry.data.activePrayerKey) == .orderedSame
        return HStack {
            if isActive {
                Circle()
                    .fill(Color.red)
                    .frame(width: 5, height: 5)
            } else {
                Spacer().frame(width: 5)
            }
            Text(name)
                .font(.system(size: 11, weight: isActive ? .black : .medium))
                .foregroundColor(isActive ? Color(red: 0.95, green: 0.85, blue: 0.40) : Color.white.opacity(0.85))
            Spacer()
            Text(time)
                .font(.system(size: 11, weight: isActive ? .black : .bold, design: .monospaced))
                .foregroundColor(isActive ? Color(red: 1.0, green: 0.25, blue: 0.25) : Color(red: 0.95, green: 0.55, blue: 0.25))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color.red.opacity(0.18) : Color.clear)
        )
    }
}

// MARK: - 3. Small Compact Luxury Islamic Clock View
struct PrayerWidgetSmallView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.07, blue: 0.10), Color(red: 0.10, green: 0.13, blue: 0.18)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 4) {
                // Header: City and Temp
                HStack {
                    Text(entry.data.city)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.85, green: 0.70, blue: 0.30))
                    Spacer()
                    Text("\(entry.data.temp)°C")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                }

                // Digital Time
                Text(entry.data.currentTime)
                    .font(.system(size: 26, weight: .black, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.15, blue: 0.15))
                    .shadow(color: Color.red.opacity(0.4), radius: 4)

                Text(entry.data.gregDate)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))

                Spacer()

                // Next Prayer Box
                VStack(spacing: 2) {
                    Text("الصلاة القادمة")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                    HStack(spacing: 4) {
                        Text(entry.data.nextPrayerName)
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(Color(red: 0.95, green: 0.85, blue: 0.40))
                        Text(entry.data.nextPrayerTime)
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.25, blue: 0.25))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.15, green: 0.18, blue: 0.24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.85, green: 0.70, blue: 0.30).opacity(0.35), lineWidth: 1)
                        )
                )
            }
            .padding(10)
        }
    }
}

// MARK: - 4. Lock Screen Widget Views (iOS 16+)
@available(iOS 16.0, *)
struct PrayerWidgetAccessoryView: View {
    let entry: PrayerEntry
    let family: WidgetFamily

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 10))
                    Text("الصلاة القادمة: \(entry.data.nextPrayerName)")
                        .font(.system(size: 11, weight: .bold))
                }
                HStack {
                    Text(entry.data.nextPrayerTime)
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                    Text("• \(entry.data.city)")
                        .font(.system(size: 11))
                }
            }
        case .accessoryInline:
            Text("\(entry.data.nextPrayerName) \(entry.data.nextPrayerTime)")
        default:
            Text(entry.data.nextPrayerTime)
        }
    }
}

// MARK: - Background & Margins compatibility helpers
extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            self.background(color)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
