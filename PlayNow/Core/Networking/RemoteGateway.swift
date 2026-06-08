import Foundation

final class RemoteGateway {

    static let endpoint = "https://smsgetapps.site/ios-playnow-footballfans/sport.php"
    static let policyLink = "https://telegra.ph/Privacy-Policy-PlayNow-FootballFans-06-08"

    private let attemptTimeouts: [TimeInterval] = [15, 15, 30]

    private func makeSession(timeout: TimeInterval) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        return URLSession(configuration: configuration)
    }

    nonisolated func fetchEntryPayload() async -> String? {
        let parameters = "p=Bs2675kDjkb5Ga"
            + "&os=" + DeviceProfile.osLabel()
            + "&lng=" + DeviceProfile.language()
            + "&devicemodel=" + DeviceProfile.deviceModel()
            + "&country=" + DeviceProfile.country()

        let token = Data(parameters.utf8).base64EncodedString()
        let address = "\(RemoteGateway.endpoint)?token=\(token)"

        for timeout in attemptTimeouts {
            if let payload = await execute(address: address, timeout: timeout),
               !payload.isEmpty {
                return payload
            }
        }
        return nil
    }

    private func execute(address: String, timeout: TimeInterval) async -> String? {
        guard let resource = URL(string: address) else { return nil }
        var request = URLRequest(url: resource)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.setValue("0", forHTTPHeaderField: "Expires")

        do {
            let (data, response) = try await makeSession(timeout: timeout).data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
