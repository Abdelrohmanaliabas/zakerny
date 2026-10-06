import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let widgetChannelName = "com.zakerny.app/prayer_widget"
    private var pendingRoute: String?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {
            setupWidgetChannel(controller: controller)
        }

        if let url = launchOptions?[.url] as? URL {
            handleDeepLink(url: url)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleDeepLink(url: url)
        return super.application(app, open: url, options: options)
    }

    private func setupWidgetChannel(controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: widgetChannelName, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }

            switch call.method {
            case "updateWidget":
                guard let dataMap = call.arguments as? [String: String] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Widget data is null", details: nil))
                    return
                }
                self.handleWidgetUpdate(data: dataMap)
                result(true)

            case "getInitialRoute":
                result(self.pendingRoute)
                self.pendingRoute = nil

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func handleDeepLink(url: URL) {
        if url.scheme == "zakerny" {
            let route: String
            if url.host == "prayers" || url.path.contains("prayers") {
                route = "/prayers"
            } else if url.host == "adhkar" || url.path.contains("adhkar") {
                route = "/adhkar"
            } else if url.host == "prayer-clock" || url.path.contains("prayer-clock") {
                route = "/prayer-clock"
            } else {
                route = "/prayers"
            }
            pendingRoute = route
            if let controller = window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(name: widgetChannelName, binaryMessenger: controller.binaryMessenger)
                channel.invokeMethod("onDeepLink", route)
            }
        }
    }

    private func handleWidgetUpdate(data: [String: String]) {
        let appGroupId = "group.com.zakerny.app"
        let groupDefaults = UserDefaults(suiteName: appGroupId)
        let standardDefaults = UserDefaults.standard

        for (k, v) in data {
            groupDefaults?.set(v, forKey: k)
            standardDefaults.set(v, forKey: k)
        }
        groupDefaults?.synchronize()
        standardDefaults.synchronize()

        // Ensure base image exists in App Group container for extension access
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
            let destURL = groupURL.appendingPathComponent("al_fajia_widget_base.png")
            if !FileManager.default.fileExists(atPath: destURL.path) {
                if let sourcePath = Bundle.main.path(forResource: "al_fajia_widget_base", ofType: "png") {
                    try? FileManager.default.copyItem(atPath: sourcePath, toPath: destURL.path)
                }
            }
        }

        // Render high-definition Al-Fajia clock image and persist to shared App Group cache
        let prayerData = PrayerData.loadFromSharedDefaults()
        if let rendered = PrayerWidgetRenderer.renderClockImage(data: prayerData) {
            PrayerWidgetRenderer.saveRenderedImageToAppGroup(image: rendered)
        }

        // Reload WidgetKit timelines across all widgets
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
