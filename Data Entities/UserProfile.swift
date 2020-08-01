import Foundation
import RxSwift
import RxCocoa

class UserProfile {
    @objc dynamic var uuid: String?
    @objc dynamic var login: String?
    @objc dynamic var password: String?
    @objc dynamic var userName: String?
    @objc dynamic var userPhone: String?
    dynamic var status: Int?
    dynamic var address = BehaviorRelay<[Adress]>(value: [])
    
    // MARK: Init with Unboxer
    
    init(uuid: String = "", login: String = "", password: String = "", address: [Adress] = [], userName: String = "", userPhone: String = "", status: Int = 0) {
        self.uuid = uuid
        self.login = login
        self.userName = userName
        self.userPhone = userPhone
        self.password = password
        self.status = status
        self.address.accept(address)
    }
    
}
