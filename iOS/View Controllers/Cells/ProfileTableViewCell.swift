import UIKit
import RxSwift
import RxCocoa
import Firebase
import RxFirebase
import Alamofire
import RxAlamofire

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var backView: UIView!
    private(set) var bag = DisposeBag()
    var deleteStatus = BehaviorRelay<Bool>(value: false)
    var editStatus = BehaviorRelay<[String]>(value: [])
    var viewModel: ProfileViewModel?
    let error = BehaviorRelay<String>(value: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designFor(view: backView)
    }
    
    func update(with data: Adress, index: Int) {
        name.text = data.name ?? ""
        adress.text = data.adress ?? ""
        phone.text = data.phoneNumber ?? ""
        
        editStatus.asObservable()
            .filter{ $0 != [] }
            .bind { value in
                
                guard let uid = self.viewModel!.userInfo.uuid else {
                    return
                }
                
                let adresValue = self.viewModel!.userInfo.address.value
                
                var address = [[String: String]]()
                for i in 0..<adresValue.count {
                    if i == index {
                        adresValue[i].name = value[0]
                        adresValue[i].phoneNumber = value[2]
                        adresValue[i].adress = value[1]
                    }
                    address.append([
                        "name" : adresValue[i].name ?? "",
                        "phoneNumber" : adresValue[i].phoneNumber ?? "",
                        "adress" : adresValue[i].adress ?? ""
                    ])
                }
                
                let ditionaryValue = ["Login": self.viewModel!.userInfo.login ?? "", "UserName": self.viewModel!.userInfo.userName ?? "", "UserPhone": self.viewModel!.userInfo.userPhone ?? "", "Adress" : address] as [String : Any]
                let value = [ uid: ditionaryValue ] as [String : Any]
                
                let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
                
                reachabilityManager?.listener = { status in
                    switch status {
                    case .notReachable:
                        self.error.accept("Нет подключения к интернету")
                    case .unknown :
                        self.error.accept("Нет подключения к интернету")
                    default:
                        Firestore.firestore().collection("Users")
                            .document(uid)
                            .rx
                            .setData(value).subscribe(onNext: { _ in
                            }, onError: { error in
                                print(error.localizedDescription)
                            }).disposed(by: self.bag)
                    }
                }
                reachabilityManager?.startListening()
                
                
                
        }
        .disposed(by: bag)
        
        deleteStatus.asObservable()
            .filter{ $0 == true }
            .bind { _ in
                
                guard let uid = self.viewModel!.userInfo.uuid else {
                    return
                }
                
                let adresValue = self.viewModel!.userInfo.address.value
                
                var address = [[String: String]]()
                for i in 0..<adresValue.count {
                    address.append([
                        "name" : adresValue[i].name ?? "",
                        "phoneNumber" : adresValue[i].phoneNumber ?? "",
                        "adress" : adresValue[i].adress ?? ""
                    ])
                }
                address.remove(at: index)
                
                let ditionaryValue = ["Login": self.viewModel!.userInfo.login ?? "", "UserName": self.viewModel!.userInfo.userName ?? "", "UserPhone": self.viewModel!.userInfo.userPhone ?? "", "Adress" : address] as [String : Any]
                let value = [ uid: ditionaryValue ] as [String : Any]
                
                let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
                
                reachabilityManager?.listener = { status in
                    switch status {
                    case .notReachable:
                        self.error.accept("Нет подключения к интернету")
                    case .unknown :
                        self.error.accept("Нет подключения к интернету")
                    default:
                        Firestore.firestore().collection("Users")
                            .document(uid)
                            .rx
                            .setData(value).subscribe(onNext: { _ in
                            }, onError: { error in
                                print(error.localizedDescription)
                            }).disposed(by: self.bag)
                    }
                }
                reachabilityManager?.startListening()
                
                
        }
        .disposed(by: bag)
    }
    
}
