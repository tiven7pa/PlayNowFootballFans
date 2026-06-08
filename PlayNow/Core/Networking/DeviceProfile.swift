import UIKit

enum DeviceProfile {

    static func osLabel() -> String {
        "iOS" + UIDevice.current.systemVersion
    }

    static func language() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if let dash = preferred.firstIndex(of: "-") {
            return String(preferred[preferred.startIndex..<dash])
        }
        return preferred
    }

    static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
    }

    static func country() -> String {
        Locale.current.region?.identifier ?? ""
    }
}
