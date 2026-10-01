import Foundation

public struct PrayerData {
    public var city: String = "القاهرة"
    public var activePrayerKey: String = "fajr"
    public var nextPrayerName: String = "الفجر"
    public var nextPrayerTime: String = "05:22"
    public var currentTime: String = "07:41"
    public var hijriDate: String = "١٤ ربيع الأول ١٤٤٦"
    public var gregDate: String = "01 OCT 2026"
    public var temp: String = "19"
    public var iqamah: String = "66"
    public var fajr: String = "05:22"
    public var sunrise: String = "06:48"
    public var dhuhr: String = "12:46"
    public var asr: String = "04:08"
    public var maghrib: String = "06:41"
    public var isha: String = "07:58"
    
    public init() {}
    
    public static func loadFromSharedDefaults() -> PrayerData {
        let appGroupId = "group.com.zakerny.app"
        let groupDefaults = UserDefaults(suiteName: appGroupId)
        let stdDefaults = UserDefaults.standard
        
        var data = PrayerData()
        
        func val(_ key: String) -> String? {
            return groupDefaults?.string(forKey: key) ?? stdDefaults.string(forKey: key)
        }
        
        if let v = val("city"), !v.isEmpty { data.city = v }
        if let v = val("active_prayer_key"), !v.isEmpty { data.activePrayerKey = v }
        if let v = val("next_prayer_name"), !v.isEmpty { data.nextPrayerName = v }
        if let v = val("next_prayer_time"), !v.isEmpty { data.nextPrayerTime = v }
        if let v = val("current_time"), !v.isEmpty { data.currentTime = v }
        if let v = val("hijri_date"), !v.isEmpty { data.hijriDate = v }
        if let v = val("greg_date"), !v.isEmpty { data.gregDate = v }
        if let v = val("temp"), !v.isEmpty { data.temp = v }
        if let v = val("iqamah"), !v.isEmpty { data.iqamah = v }
        if let v = val("fajr"), !v.isEmpty { data.fajr = v }
        if let v = val("sunrise"), !v.isEmpty { data.sunrise = v }
        if let v = val("dhuhr"), !v.isEmpty { data.dhuhr = v }
        if let v = val("asr"), !v.isEmpty { data.asr = v }
        if let v = val("maghrib"), !v.isEmpty { data.maghrib = v }
        if let v = val("isha"), !v.isEmpty { data.isha = v }
        
        return data
    }
}
