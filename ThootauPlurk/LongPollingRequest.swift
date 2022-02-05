import Foundation
class LongPullRequest {
    public func pull(execute_url: URL) {
        let task = URLSession.shared.dataTask(with: execute_url) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                if let usableData = data {
                    print(type(of: usableData), String(decoding: usableData, as: UTF8.self))
                    self.pull(execute_url: execute_url)
                }
            }
        }
        task.resume()
    }
}
