import Foundation
import RxSwift
import RxCocoa
import Firebase
import RxFirebase

class SignUpViewModel {
    private let bag = DisposeBag()
    let user: UserProfile
    let checkOut = BehaviorRelay<Bool>(value: false)
    let error = BehaviorRelay<String>(value: "")
    

    init(user: UserProfile) {
        self.user = user
    }
    
    func auth() {
        Auth.auth().rx.createUser(withEmail: user.login!, password: user.password!)
            .subscribe(onNext: { authResult in
                
                let uid = authResult.user.uid
                
                let adresValue = self.user.address.value
                
                let address: [String: String] = [
                    "name" : adresValue[0].name ?? "",
                    "phoneNumber" : adresValue[0].phoneNumber ?? "",
                    "adress" : adresValue[0].adress ?? ""
                ]
                
                let ditionaryValue = ["Login" : self.user.login ?? "","Status": 0, "UserName": adresValue[0].name ?? "", "UserPhone": adresValue[0].phoneNumber ?? "", "Adress" : [address]] as [String : Any]
                let value = [ uid: ditionaryValue ]
                
                Firestore.firestore().collection("Users")
                    .document(uid)
                    .rx
                    .setData(value).subscribe(onNext: { (resault) in
                        self.checkOut.accept(true)
                    }, onError: { error in
                        self.error.accept(error.localizedDescription)
                    }).disposed(by: self.bag)
                
            }, onError: { error in
                self.error.accept(error.localizedDescription)
            }).disposed(by: bag)
  
    }
}

