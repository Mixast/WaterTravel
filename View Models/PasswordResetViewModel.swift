import Foundation
import RxSwift
import RxCocoa
import Firebase
import RxFirebase

class PasswordResetViewModel {
    private let bag = DisposeBag()
    let user: UserProfile
    let checkOut = BehaviorRelay<Bool>(value: false)
    let error = BehaviorRelay<String>(value: "")
    
    init(user: UserProfile) {
        self.user = user
    }
    func refreshPasword() {
        Auth.auth().rx.sendPasswordReset(withEmail: user.login!)
            .subscribe(onNext: { _ in
                print("Ok")
                self.checkOut.accept(true)
            }, onError: { error in
                self.error.accept(error.localizedDescription)
            }).disposed(by: bag)

    }
}

