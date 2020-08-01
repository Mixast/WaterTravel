import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Firebase
import RxFirebase
import Alamofire
import RxAlamofire

class ProfileViewModel {
    private let bag = DisposeBag()
    var userInfo = UserProfile()
    
    init(user: UserProfile) {
        userInfo = user
    }
    
}
