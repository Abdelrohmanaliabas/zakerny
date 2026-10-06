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
        let entry = PrayerEntry(date: Date(), data: data, renderedImage: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let data = PrayerData.loadFromSharedDefaults()
        let currentDate = Date()
        let entry = PrayerEntry(date: currentDate, data: data, renderedImage: nil)

        // Refresh every 15 minutes to keep times and countdown accurate
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
        .widgetBackground(Color(red: 0.02, green: 0.12, blue: 0.09))
        .widgetURL(URL(string: "zakerny://prayers"))
    }
}

// MARK: - Islamic Color Theme
private enum IslamicTheme {
    static let darkGreen1 = Color(red: 0.02, green: 0.12, blue: 0.09)
    static let darkGreen2 = Color(red: 0.05, green: 0.24, blue: 0.18)
    static let darkGreen3 = Color(red: 0.01, green: 0.08, blue: 0.06)
    static let cardBg = Color(red: 0.04, green: 0.16, blue: 0.12)
    static let cardActiveBg = Color(red: 0.08, green: 0.35, blue: 0.27)
    
    static let gold = Color(red: 0.85, green: 0.70, blue: 0.25)
    static let goldLight = Color(red: 0.99, green: 0.90, blue: 0.54)
    static let emeraldLight = Color(red: 0.20, green: 0.83, blue: 0.60)
    static let textSecondary = Color(red: 0.60, green: 0.90, blue: 0.75)
}

// MARK: - 1. Medium Luxury Islamic Banner View (Primary 4x2 Widget)
struct PrayerWidgetMediumView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [IslamicTheme.darkGreen1, IslamicTheme.darkGreen2, IslamicTheme.darkGreen3],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            // Islamic Gold Frame Border
            RoundedRectangle(cornerRadius: 18)
                .stroke(IslamicTheme.gold.opacity(0.35), lineWidth: 1.2)
                .padding(2)

            HStack(spacing: 12) {
                // Prayers Schedule (Left side in LTR, Right side conceptually in RTL)
                VStack(spacing: 4) {
                    prayerRow(name: "الفجر", key: "fajr", time: entry.data.fajr)
                    prayerRow(name: "الشروق", key: "sunrise", time: entry.data.sunrise)
                    prayerRow(name: "الظهر", key: "dhuhr", time: entry.data.dhuhr)
                    prayerRow(name: "العصر", key: "asr", time: entry.data.asr)
                    prayerRow(name: "المغرب", key: "maghrib", time: entry.data.maghrib)
                    prayerRow(name: "العشاء", key: "isha", time: entry.data.isha)
                }
                .frame(maxWidth: .infinity)

                // Divider Line
                Rectangle()
                    .fill(IslamicTheme.gold.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 4)

                // Featured Next Prayer Column
                VStack(alignment: .trailing, spacing: 5) {
                    // Header: Mosque + City
                    HStack(spacing: 4) {
                        Text(entry.data.city)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(IslamicTheme.goldLight)
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 11))
                            .foregroundColor(IslamicTheme.gold)
                    }

                    // Hijri Date
                    Text(entry.data.hijriDate)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(IslamicTheme.textSecondary)

                    Spacer()

                    // Hero Next Prayer Badge
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("الصلاة القادمة")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(IslamicTheme.emeraldLight)

                        Text(entry.data.nextPrayerName)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)

                        Text(entry.data.nextPrayerTime)
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(IslamicTheme.goldLight)
                    }

                    Spacer()

                    // Countdown pill
                    if !entry.data.timeRemaining.isEmpty {
                        Text(entry.data.timeRemaining)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(IslamicTheme.darkGreen1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(IslamicTheme.goldLight)
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
        }
    }

    private func prayerRow(name: String, key: String, time: String) -> some View {
        let isActive = key.caseInsensitiveCompare(entry.data.activePrayerKey) == .orderedSame
        return HStack {
            Text(time)
                .font(.system(size: 10.5, weight: isActive ? .black : .bold, design: .monospaced))
                .foregroundColor(isActive ? .white : Color.white.opacity(0.85))

            Spacer()

            Text(name)
                .font(.system(size: 11, weight: isActive ? .black : .medium))
                .foregroundColor(isActive ? IslamicTheme.goldLight : IslamicTheme.textSecondary)

            if isActive {
                Circle()
                    .fill(IslamicTheme.goldLight)
                    .frame(width: 5, height: 5)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2.5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive ? IslamicTheme.cardActiveBg : IslamicTheme.cardBg.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isActive ? IslamicTheme.gold.opacity(0.7) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - 2. Large Luxury Islamic Sanctuary View (4x4 Widget)
struct PrayerWidgetLargeView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [IslamicTheme.darkGreen1, IslamicTheme.darkGreen2, IslamicTheme.darkGreen3],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 22)
                .stroke(IslamicTheme.gold.opacity(0.4), lineWidth: 1.5)
                .padding(2)

            VStack(spacing: 8) {
                // Top Header Row
                HStack {
                    Text(entry.data.currentTime)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(IslamicTheme.goldLight)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        HStack(spacing: 4) {
                            Text("ذكرني • \(entry.data.city)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(IslamicTheme.goldLight)
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 12))
                                .foregroundColor(IslamicTheme.gold)
                        }
                        Text(entry.data.hijriDate)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(IslamicTheme.textSecondary)
                    }
                }

                // Next Prayer Hero Card
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.data.nextPrayerTime)
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(IslamicTheme.goldLight)
                        if !entry.data.timeRemaining.isEmpty {
                            Text(entry.data.timeRemaining)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(IslamicTheme.darkGreen1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(IslamicTheme.goldLight))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("الصلاة القادمة بإذن الله")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(IslamicTheme.emeraldLight)
                        Text(entry.data.nextPrayerName)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(IslamicTheme.cardActiveBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(IslamicTheme.gold.opacity(0.6), lineWidth: 1)
                        )
                )

                // 6 Prayer Times in 3x2 Grid
                VStack(spacing: 5) {
                    HStack(spacing: 6) {
                        prayerGridCard(name: "الفجر", key: "fajr", time: entry.data.fajr)
                        prayerGridCard(name: "الشروق", key: "sunrise", time: entry.data.sunrise)
                        prayerGridCard(name: "الظهر", key: "dhuhr", time: entry.data.dhuhr)
                    }
                    HStack(spacing: 6) {
                        prayerGridCard(name: "العصر", key: "asr", time: entry.data.asr)
                        prayerGridCard(name: "المغرب", key: "maghrib", time: entry.data.maghrib)
                        prayerGridCard(name: "العشاء", key: "isha", time: entry.data.isha)
                    }
                }

                Spacer(minLength: 2)

                // Daily Dhikr Card at Bottom
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundColor(IslamicTheme.gold)

                    Text(entry.data.dailyDhikrText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(IslamicTheme.goldLight)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(IslamicTheme.cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(IslamicTheme.gold.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .padding(14)
        }
    }

    private func prayerGridCard(name: String, key: String, time: String) -> some View {
        let isActive = key.caseInsensitiveCompare(entry.data.activePrayerKey) == .orderedSame
        return VStack(spacing: 2) {
            Text(name)
                .font(.system(size: 11, weight: isActive ? .black : .bold))
                .foregroundColor(isActive ? IslamicTheme.goldLight : IslamicTheme.textSecondary)

            Text(time)
                .font(.system(size: 12, weight: isActive ? .black : .bold, design: .monospaced))
                .foregroundColor(isActive ? .white : Color.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? IslamicTheme.cardActiveBg : IslamicTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? IslamicTheme.gold : IslamicTheme.gold.opacity(0.15), lineWidth: isActive ? 1.2 : 0.8)
                )
        )
    }
}

// MARK: - 3. Small Compact Luxury Islamic Clock View (2x2 Widget)
struct PrayerWidgetSmallView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [IslamicTheme.darkGreen1, IslamicTheme.darkGreen2],
                startPoint: .top,
                endPoint: .bottom
            )

            RoundedRectangle(cornerRadius: 18)
                .stroke(IslamicTheme.gold.opacity(0.35), lineWidth: 1.2)
                .padding(2)

            VStack(spacing: 3) {
                // Header: City and Icon
                HStack {
                    Text(entry.data.city)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(IslamicTheme.goldLight)
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 11))
                        .foregroundColor(IslamicTheme.gold)
                }

                Spacer()

                // Next Prayer Title
                Text("الصلاة القادمة")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(IslamicTheme.emeraldLight)

                Text(entry.data.nextPrayerName)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                Text(entry.data.nextPrayerTime)
                    .font(.system(size: 19, weight: .black, design: .monospaced))
                    .foregroundColor(IslamicTheme.goldLight)

                Spacer()

                // Countdown / Hijri Date
                if !entry.data.timeRemaining.isEmpty {
                    Text(entry.data.timeRemaining)
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(IslamicTheme.darkGreen1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(Capsule().fill(IslamicTheme.goldLight))
                } else {
                    Text(entry.data.hijriDate)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(IslamicTheme.textSecondary)
                }
            }
            .padding(11)
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
                    if !entry.data.timeRemaining.isEmpty {
                        Text("• \(entry.data.timeRemaining)")
                            .font(.system(size: 10))
                    }
                }
            }
        case .accessoryInline:
            Text("🕌 \(entry.data.nextPrayerName) \(entry.data.nextPrayerTime)")
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
