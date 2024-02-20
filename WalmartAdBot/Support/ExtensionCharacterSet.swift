import Cocoa
import Foundation

extension CharacterSet {
    static var allowedQuery: CharacterSet = {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return allowed
    }()
}
