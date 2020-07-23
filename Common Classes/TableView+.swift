import Foundation
import UIKit

extension UITableView {
    func dequeueCell<T>(ofType type: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }
    
    func dequeueHeader<T>(ofType type: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as! T
    }
    
}
