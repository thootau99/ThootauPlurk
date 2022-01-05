import WatchConnectivity

struct Message {
    let key : String
    let value : Any
}

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage = "WATCH : まだ受けでいません"
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state= \(activationState.rawValue)")
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage: \(message)")
    }
    func send(messages: Array<Message>) {
        print("Is watch reached?",WCSession.default.isReachable)
        if WCSession.default.isReachable {
            for message in messages {
                self.receivedMessage = "\(message)"
                WCSession.default.sendMessage([message.key: message.value], replyHandler: nil) { error in
                    print(error)
                }
            }
        }
    }
    
    
}
