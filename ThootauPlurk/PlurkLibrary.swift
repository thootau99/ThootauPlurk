import Foundation
import OAuthSwift
import SwiftSoup
import KeychainAccess
import DotEnv
import PromiseKit
import SwiftUI

struct Profile: Codable, Hashable {
    var avatar_medium : String?
    var about : String?
    var display_name : String?
    var nick_name : String?
}

struct ProfileResponse: Codable, Hashable {
    var fans_count: Int?
    var friends_count: Int?
    var user_info: Profile
}

struct ParsedPost: Codable, Hashable {
    var url: URL?
    var content: String?
    var tag: String?
    var thumbnails: String?
}

struct PlurkPost : Codable, Hashable, Identifiable {
    
    let id: UUID = UUID()
    var photos: [URL] = []
    var avatar_url: String?
    var contentParsed : [ParsedPost] = []
    
    var owner_id : Int?
    var user_id : Int?
    var content : String?
    var display_name: String?
    var response_count: Int?
    var posted: String?
    var plurk_id : Int?
    
    private enum CodingKeys : String, CodingKey { case owner_id, user_id, content, display_name, response_count, posted, plurk_id }
}

struct PlurkUser : Codable, Hashable {
    var id : Int?
    var display_name: String?
    var has_profile_image: Int?
    var avatar: Int?
}


struct GetPlurkResponse : Codable, Hashable {
    
    var plurks: [PlurkPost]
    var plurk_users: [String: PlurkUser]
}

struct Response: Codable, Hashable {
    var user_id : Int
    var content : String?
    var display_name: String?
    var response_count: Int?
    var plurk_id : Int?
}

struct GetResponse: Codable {
    var responses: [PlurkPost]
    var friends: [String: PlurkUser]
}

class PlurkLibrary : ObservableObject {
    @Published var loginSuccess = false
    @Published var lastPlurkTime: String = ""
    @Published var plurks: GetPlurkResponse = GetPlurkResponse(plurks: [], plurk_users: [:])
    let dateFormatter = DateFormatter()
    let _OAuthSwift : OAuth1Swift
    init() {
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        do {
            var fileURL: String = ""
            if let url = Bundle.main.url(forResource: ".env", withExtension: "") {
                fileURL = url.absoluteString
                fileURL = fileURL.replacingOccurrences(of: "file://", with: "")
                fileURL = fileURL.replacingOccurrences(of: "%20", with: " ")
            }
            let env = try DotEnv.read(path: fileURL)
            env.load()
        } catch {
            print("read env error \(error)")
        }
        
        if let consumerKey = ProcessInfo.processInfo.environment["CONSUMER_KEY"],
           let consumerSecret = ProcessInfo.processInfo.environment["CONSUMER_SECRET"] {
            self._OAuthSwift = OAuth1Swift(
                consumerKey:    consumerKey,
                consumerSecret: consumerSecret,
                requestTokenUrl: "https://www.plurk.com/OAuth/request_token",
                authorizeUrl:    "https://www.plurk.com/m/authorize",
                accessTokenUrl:  "https://www.plurk.com/OAuth/access_token"
            )
            let keychain = Keychain(service: "org.thootau.plurkwatch")
            guard let token = try? keychain.get("oauthToken"),
                  let tokenSecret = try? keychain.get("oauthTokenSecret") else { return }
            self._OAuthSwift.client.credential.oauthToken = token
            self._OAuthSwift.client.credential.oauthTokenSecret = tokenSecret
            testToken() { fail in
                if fail {
                    self._OAuthSwift.client.credential.oauthToken = ""
                    self._OAuthSwift.client.credential.oauthTokenSecret = ""
                    keychain["oauthToken"] = ""
                    keychain["oauthTokenSecret"] = ""
                } else {
                    self.loginSuccess = true
                }
            }
        } else {
            // if .env not exist, fall here
            self._OAuthSwift = OAuth1Swift(
                consumerKey:    "",
                consumerSecret: "",
                requestTokenUrl: "https://www.plurk.com/OAuth/request_token",
                authorizeUrl:    "https://www.plurk.com/m/authorize",
                accessTokenUrl:  "https://www.plurk.com/OAuth/access_token"
            )
        }
    }
    
    
    func testToken(fail: @escaping (Bool) -> ()) {
        let _ = _OAuthSwift.client.get("https://www.plurk.com/APP/Profile/getOwnProfile") {(result) in
            switch result {
            case .success( _):
                    fail(false)
            case .failure(_):
                    fail(true)
            }
        }
    }
    
    func login() -> Promise<Bool> {
        return Promise<Bool> {seal in
            let keychain = Keychain(service: "org.thootau.plurkwatch")
            guard let token = try? keychain.get("oauthToken"),
                  let tokenSecret = try? keychain.get("oauthTokenSecret") else {
                  _OAuthSwift.authorize(
                    withCallbackURL: "thootau-plurk://oauth-callback/plurk") { result in
                        switch result {
                        case .success(let (credential, _, _)):
                            self.loginSuccess = true
                            self._OAuthSwift.client.credential.oauthToken = credential.oauthToken
                            self._OAuthSwift.client.credential.oauthTokenSecret = credential.oauthTokenSecret
                            keychain["oauthToken"] = credential.oauthToken as String
                            keychain["oauthTokenSecret"] = credential.oauthTokenSecret as String
                            self.loginSuccess = true
                            return seal.fulfill(true)
                        case .failure(let error):
                          print(error.localizedDescription)
                        }
                    }
                return
            }
            self._OAuthSwift.client.credential.oauthToken = token
            self._OAuthSwift.client.credential.oauthTokenSecret = tokenSecret
            testToken() { fail in
                if fail {
                    self._OAuthSwift.client.credential.oauthToken = ""
                    self._OAuthSwift.client.credential.oauthTokenSecret = ""
                    keychain["oauthToken"] = ""
                    keychain["oauthTokenSecret"] = ""
                    self._OAuthSwift.authorize(
                      withCallbackURL: "thootau-plurk://oauth-callback/plurk") { result in
                          switch result {
                          case .success(let (credential, _, _)):
                              self.loginSuccess = true
                              self._OAuthSwift.client.credential.oauthToken = credential.oauthToken
                              self._OAuthSwift.client.credential.oauthTokenSecret = credential.oauthTokenSecret
                              keychain["oauthToken"] = credential.oauthToken as String
                              keychain["oauthTokenSecret"] = credential.oauthTokenSecret as String
                              self.loginSuccess = true
                              return seal.fulfill(true)
                          case .failure(let error):
                            print(error.localizedDescription)
                          }
                      }
                } else {
                    self.loginSuccess = true
                    return seal.fulfill(true)
                }
            }
        }
    }
    func getProfile(me: Bool, user_id: String) -> Promise<ProfileResponse> {
        return Promise<ProfileResponse> { seal in
            let requestURL = me ? "https://www.plurk.com/APP/Profile/getOwnProfile": "https://www.plurk.com/APP/Profile/getPublicProfile?user_id=\(user_id)"
            let _ = _OAuthSwift.client.get(requestURL) {(result) in
                switch result {
                    case .success(let response):
                        let decoder = JSONDecoder()
                        do {
                            let data = response.string?.data(using: .utf8)
                            let meResult = try decoder.decode(ProfileResponse.self, from: data!)
                            seal.fulfill(meResult)
                        } catch {
                            print("ERROR IN JSON PARSING")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    func getProfilePhotoURL(hasProfile: Int?, avatar: Int?, owner_id: Int) -> String {
        var avatar_url: String = ""
        if (hasProfile == 1 && avatar == nil) {
            avatar_url = "https://avatars.plurk.com/\(owner_id)-small.gif"
        } else if (hasProfile != nil && avatar != nil) {
            avatar_url = "https://avatars.plurk.com/\(owner_id)-small\(avatar!).gif"
        } else {
            avatar_url = "https://www.plurk.com/static/default_small.jpg"
        }
        
        return avatar_url
    }
    
    func getContenParsed(plurk: PlurkPost, content: String)  throws -> PlurkPost {
        var copyPlurk = plurk
        do {
            let contentParsed = try SwiftSoup.parseBodyFragment(content)
            for _element: Element in try contentParsed.body()!.getAllElements() {
                switch _element.tag().toString() {
                case "a":
                    if _element.childNodeSize() > 0 {
                        if let url = try? _element.attr("href"), let title = try? _element.text() {
                            if title.isEmpty {
                                break
                            }
                            if let parsedURL = URL(string: url) {
                                for child: Element in _element.children() {
                                    if child.tag().toString() == "img" {
                                        if let imageURL = try? child.attr("src").description {
                                                let link: ParsedPost = ParsedPost(url: parsedURL, content: title, tag: "a", thumbnails: imageURL)
                                                copyPlurk.contentParsed.append(link)
                                        }
                                    }
                                }
                            }
                        }
                    }
                case "img":
                    if let url = try? _element.attr("src").description {
                        if let parsedURL = URL(string: url) {
                            copyPlurk.photos.append(parsedURL)
                        }
                    }
                case "br":
                    let br: ParsedPost = ParsedPost(url: nil, content: nil, tag: "br")
                    copyPlurk.contentParsed.append(br)
                case "span":
                    if let title = try? _element.text() {
                        let span: ParsedPost = ParsedPost(url: nil, content: title, tag: "span")
                        copyPlurk.contentParsed.append(span)
                    }
                default:
                    if let title = try? _element.text() {
                        let span: ParsedPost = ParsedPost(url: nil, content: title, tag: "span")
                        print(_element.tag().toString(), title)
                        copyPlurk.contentParsed.append(span)
                    }
                }
            }
        }
        return copyPlurk
    }
    
    func getPlurks(me: Bool) -> Promise<GetPlurkResponse> {
        return Promise<GetPlurkResponse> { seal in
            var parameters = OAuthSwift.Parameters()
            if me {
                parameters["filter"] = "my"
            }
            parameters["offset"] = lastPlurkTime.isEmpty ? "" : lastPlurkTime
            self._OAuthSwift.client.get("https://www.plurk.com/APP/Timeline/getPlurks", parameters: parameters) {(result) in
                    switch result {
                        case .success(let response):
                            let decoder = JSONDecoder()
                            do {
                                let data = response.string?.data(using: .utf8)
                                var plurkResult = try decoder.decode(GetPlurkResponse.self, from: data!)
                                var plurkExecuted: [PlurkPost] = []
                                for var (index, plurk) in plurkResult.plurks.enumerated() {
                                    // なまえをだいにゅうする
                                    if let owner_id = plurk.owner_id {
                                        let ownerIdToString = String(owner_id)
                                        if let display_name = plurkResult.plurk_users[ownerIdToString]?.display_name {
                                            plurk.display_name = display_name
                                        }
                                        plurk.avatar_url = self.getProfilePhotoURL(hasProfile: plurkResult.plurk_users[ownerIdToString]?.has_profile_image, avatar: plurkResult.plurk_users[ownerIdToString]?.avatar, owner_id: owner_id)
                                    }
                                    plurkExecuted.append(try self.getContenParsed(plurk: plurk, content: plurk.content ?? ""))
                                    if index == plurkResult.plurks.count - 1 {
                                        if let time = plurk.posted {
                                            let date = self.dateFormatter.date(from: time)
                                            if let ISO8601Date = date?.ISO8601Format() {
                                                self.lastPlurkTime = ISO8601Date
                                            }
                                        }
                                    }
                                }
                                plurkResult.plurks = plurkExecuted
                                self.plurks.plurks += plurkExecuted
                                seal.fulfill(self.plurks)
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
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
            }
    }
    
    func getPlurkResponses(plurk_id: Int) -> Promise<GetResponse> {
        return Promise<GetResponse> {seal in

            self._OAuthSwift.client.get("https://www.plurk.com/APP/Responses/getById", parameters: ["plurk_id": String(plurk_id)]) {(result) in
                switch result {
                    case .success(let response):
                        let decoder = JSONDecoder()
                        do {
                            let data = response.string?.data(using: .utf8)
                            var plurkResult = try decoder.decode(GetResponse.self, from: data!)
                            var plurkExecuted: [PlurkPost] = []
                            for var plurk in plurkResult.responses {
                                // なまえをだいにゅうする
                                if let user_id = plurk.user_id {
                                    let userIdToString = String(user_id)
                                    if let display_name = plurkResult.friends[userIdToString]?.display_name {
                                        plurk.display_name = display_name
                                    }
                                    plurk.avatar_url = self.getProfilePhotoURL(hasProfile: plurkResult.friends[userIdToString]?.has_profile_image, avatar: plurkResult.friends[userIdToString]?.avatar, owner_id: user_id)
                                }
                                plurkExecuted.append(try self.getContenParsed(plurk: plurk, content: plurk.content ?? ""))
                            }
                            plurkResult.responses = plurkExecuted
                            seal.fulfill(plurkResult)
                        } catch {
                            print("error: ", error)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    func postPlurk(plurk_id : Int?, content: String, qualifier: String) {
        guard let checkPlurkId : Int = plurk_id else {
            let _ = self._OAuthSwift.client.post("https://www.plurk.com/APP/Timeline/plurkAdd", parameters: ["content": content, "qualifier": qualifier]) {result in
                switch result {
                    case .success(let response):
                        print(response.string as Any)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
            return
        }
        let _ = self._OAuthSwift.client.post("https://www.plurk.com/APP/Responses/responseAdd", parameters: ["plurk_id": checkPlurkId, "content": content, "qualifier": qualifier]) {result in
            
            switch result {
                case .success(let response):
                    print(response.string as Any)
                    
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    func logout() {
        let keychain = Keychain(service: "org.thootau.plurkwatch")
        self._OAuthSwift.client.credential.oauthToken = ""
        self._OAuthSwift.client.credential.oauthTokenSecret = ""
        keychain["oauthToken"] = ""
        keychain["oauthTokenSecret"] = ""
        self.loginSuccess = false
    }
}



