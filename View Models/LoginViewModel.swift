import Foundation
import RxSwift
import RxCocoa
import Firebase
import UIKit

class LoginViewModel {
    let checkOut = BehaviorRelay<UserProfile>(value: UserProfile())
    let error = BehaviorRelay<String>(value: "")
    init() {}
    
    func auth(login: String, password: String) {
        Auth.auth().signIn(withEmail: login, password: password) { (user, error) in
            if let err = error {
                self.error.accept(err.localizedDescription)
                return
            }
            
            FirebaseAPI.auth().asObservable()
                .bind(onNext: { user in
                    if user == nil {
                        self.error.accept("Ошибка авторизации")
                    } else {
                        self.checkOut.accept(user ?? UserProfile())
                    }
                })
                .disposed(by: bag)
        }
    }
}
