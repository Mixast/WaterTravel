
import Foundation

extension Date {
    var timestamp: String {
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "ru_RU")
        dataFormatter.dateFormat = "dd MMMM (EEEE)"
        return String(format: "%@", dataFormatter.string(from: self))
    }
}

