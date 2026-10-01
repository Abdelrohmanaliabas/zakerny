import UIKit

public class PrayerWidgetRenderer {
    public static let shared = PrayerWidgetRenderer()
    
    public static func renderClockImage(data: PrayerData) -> UIImage? {
        var baseImage: UIImage? = UIImage(named: "al_fajia_widget_base")
        if baseImage == nil {
            if let path = Bundle.main.path(forResource: "al_fajia_widget_base", ofType: "png") {
                baseImage = UIImage(contentsOfFile: path)
            }
        }
        if baseImage == nil {
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zakerny.app") {
                let imgURL = groupURL.appendingPathComponent("al_fajia_widget_base.png")
                baseImage = UIImage(contentsOfFile: imgURL.path)
            }
        }
        
        guard let base = baseImage else {
            return nil
        }
        
        let size = base.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        let renderedImage = renderer.image { context in
            let cg = context.cgContext
            
            // Draw background golden arch frame
            base.draw(in: CGRect(origin: .zero, size: size))
            
            let w = size.width
            let h = size.height
            let sx = w / 768.0
            let sy = h / 1288.0
            
            let redColor = UIColor(red: 1.0, green: 0x22 / 255.0, blue: 0x22 / 255.0, alpha: 1.0)
            let amberColor = UIColor(red: 1.0, green: 0xA0 / 255.0, blue: 0x28 / 255.0, alpha: 1.0)
            let cityColor = UIColor(red: 0x7A / 255.0, green: 0x4F / 255.0, blue: 0x18 / 255.0, alpha: 1.0)
            
            func drawCenteredText(_ text: String, cx: CGFloat, cy: CGFloat, font: UIFont, color: UIColor) {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
                let str = text as NSString
                let textSize = str.size(withAttributes: attrs)
                let rect = CGRect(
                    x: cx - (textSize.width / 2.0),
                    y: cy - (textSize.height / 2.0),
                    width: textSize.width,
                    height: textSize.height
                )
                str.draw(in: rect, withAttributes: attrs)
            }
            
            // 1. Temp & Iqamah (top round bezels: x=318, x=467, y=358)
            let tempFont = UIFont.monospacedDigitSystemFont(ofSize: 38.0 * sy, weight: .black)
            let cleanTemp = data.temp.replacingOccurrences(of: "°C", with: "").replacingOccurrences(of: "C", with: "").trimmingCharacters(in: .whitespaces)
            let cleanIqamah = data.iqamah.replacingOccurrences(of: "°F", with: "").replacingOccurrences(of: "F", with: "").trimmingCharacters(in: .whitespaces)
            drawCenteredText(cleanTemp, cx: 318.0 * sx, cy: 358.0 * sy, font: tempFont, color: redColor)
            drawCenteredText(cleanIqamah, cx: 467.0 * sx, cy: 358.0 * sy, font: tempFont, color: redColor)
            
            // 2. Main Time (central bezel: x=394, y=460) - BIG & BOLD
            let mainTimeFont = UIFont.monospacedDigitSystemFont(ofSize: 84.0 * sy, weight: .black)
            drawCenteredText(data.currentTime, cx: 394.0 * sx, cy: 460.0 * sy, font: mainTimeFont, color: redColor)
            
            // 3. Date Matrix (centered at x=394, y=578) - BOLD AMBER
            let dateFont = UIFont.monospacedDigitSystemFont(ofSize: 28.0 * sy, weight: .bold)
            let displayDate = String(data.gregDate.prefix(20))
            drawCenteredText(displayDate, cx: 394.0 * sx, cy: 578.0 * sy, font: dateFont, color: amberColor)
            
            // 4. City Name (under date display: x=392, y=633)
            let cityFont = UIFont.systemFont(ofSize: 24.0 * sy, weight: .heavy)
            let shortCity = String(data.city.prefix(20))
            drawCenteredText(shortCity, cx: 392.0 * sx, cy: 633.0 * sy, font: cityFont, color: cityColor)
            
            // 5. 6 Prayer Times (individual bezels: x=392, y = 685, 773, 861, 949, 1036, 1123)
            let prayerFont = UIFont.monospacedDigitSystemFont(ofSize: 46.0 * sy, weight: .black)
            let prayers: [(key: String, time: String)] = [
                ("fajr", data.fajr),
                ("sunrise", data.sunrise),
                ("dhuhr", data.dhuhr),
                ("asr", data.asr),
                ("maghrib", data.maghrib),
                ("isha", data.isha)
            ]
            let prayerY: [CGFloat] = [685.0, 773.0, 861.0, 949.0, 1036.0, 1123.0]
            
            for (idx, item) in prayers.enumerated() {
                guard idx < prayerY.count else { continue }
                let cy = prayerY[idx] * sy
                drawCenteredText(item.time, cx: 392.0 * sx, cy: cy, font: prayerFont, color: redColor)
                
                // Active red LED indicator dot next to the active prayer
                if item.key.caseInsensitiveCompare(data.activePrayerKey) == .orderedSame {
                    let dotCx = 496.0 * sx
                    
                    // Glow
                    cg.setFillColor(UIColor(red: 1.0, green: 0x44 / 255.0, blue: 0x44 / 255.0, alpha: 0.6).cgColor)
                    cg.fillEllipse(in: CGRect(x: dotCx - 11.0 * sx, y: cy - 11.0 * sx, width: 22.0 * sx, height: 22.0 * sx))
                    
                    // Core
                    cg.setFillColor(UIColor(red: 1.0, green: 0x22 / 255.0, blue: 0x22 / 255.0, alpha: 1.0).cgColor)
                    cg.fillEllipse(in: CGRect(x: dotCx - 8.0 * sx, y: cy - 8.0 * sx, width: 16.0 * sx, height: 16.0 * sx))
                    
                    // Highlight
                    cg.setFillColor(UIColor(red: 1.0, green: 0xE0 / 255.0, blue: 0xE0 / 255.0, alpha: 1.0).cgColor)
                    cg.fillEllipse(in: CGRect(x: dotCx - 2.5 * sx - 2.0 * sx, y: cy - 2.5 * sy - 2.0 * sx, width: 4.5 * sx, height: 4.5 * sx))
                }
            }
        }
        
        return renderedImage
    }
    
    public static func saveRenderedImageToAppGroup(image: UIImage) {
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zakerny.app") {
            let fileURL = groupURL.appendingPathComponent("al_fajia_rendered_clock.png")
            if let pngData = image.pngData() {
                try? pngData.write(to: fileURL, options: .atomic)
            }
        }
        if let docsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = docsURL.appendingPathComponent("al_fajia_rendered_clock.png")
            if let pngData = image.pngData() {
                try? pngData.write(to: fileURL, options: .atomic)
            }
        }
    }
    
    public static func loadRenderedImageFromSharedStorage() -> UIImage? {
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.zakerny.app") {
            let fileURL = groupURL.appendingPathComponent("al_fajia_rendered_clock.png")
            if let img = UIImage(contentsOfFile: fileURL.path) {
                return img
            }
        }
        if let docsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = docsURL.appendingPathComponent("al_fajia_rendered_clock.png")
            if let img = UIImage(contentsOfFile: fileURL.path) {
                return img
            }
        }
        return nil
    }
}
