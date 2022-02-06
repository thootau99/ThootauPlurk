import Foundation
import UserNotifications
class LongPullRequest {
    func pull(execute_url: URL, complete: @escaping (Data) -> ()) {
        let task = URLSession.shared.dataTask(with: execute_url) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                if let usableData = data {
                    complete(usableData)
                    self.pull(execute_url: execute_url, complete: complete)
                }
            }
        }
        task.resume()
    }
}

struct NotificationResponse: Codable, Hashable {
    var new_offset : Int?
    var data: [NotifictionResponseData]
}

struct NotifictionResponseData: Codable, Hashable {
    var plurk_id: Int?
    var plurk: PlurkPost?
    var response_count: Int?
    var response: Response?
    var user: PlurkUser?
    var type: String?
}

class UserChannelRequest: LongPullRequest {
    private func handleChange(usableData: Data) {
        print(type(of: usableData), String(decoding: usableData, as: UTF8.self))
        let decoder = JSONDecoder()
        do {
            var dataString = String(decoding: usableData, as: UTF8.self)
            dataString = dataString.replacingOccurrences(of: "CometChannel.scriptCallback(", with: "")
            dataString = dataString.replacingOccurrences(of: ");", with: "")

            let notificationDecoded = try decoder.decode(NotificationResponse.self, from: dataString.data(using: .utf8)!)
            print(notificationDecoded)
            
            let content = UNMutableNotificationContent()
            content.title = "Feed the cat"
            content.subtitle = "It looks hungry"
            content.sound = UNNotificationSound.default

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
            
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
    public func start(execute_url: URL) {
        self.pull(execute_url: execute_url, complete: self.handleChange)
    }
}

