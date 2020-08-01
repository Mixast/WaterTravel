import UIKit
import RxSwift
import RxCocoa
import Firebase
import RxFirebase
import Alamofire
import RxAlamofire

class HistoryTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var deliveryDate: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var shere: UIButton!
    private(set) var bag = DisposeBag()
    let status = BehaviorRelay<Int>(value: 0)
    var deleteStatus = BehaviorRelay<Bool>(value: false)
    let checkOut = BehaviorRelay<String>(value: "")
    let error = BehaviorRelay<String>(value: "")
    var viewModel: HistoryViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image()
        
        
    }
        
    private func image() {
        status.asDriver()
            .drive(onNext: { pop in
                switch pop {
                case 0:
                    self.statusImage.image = R.image.processing()
                    self.delete.isEnabled = true
                    self.delete.alpha = 1
                case 1:
                    self.statusImage.image = R.image.transit()
                    self.delete.alpha = 0
                case 2:
                    self.statusImage.image = R.image.success()
                    self.delete.alpha = 0
                default: break
                }
            })
            .disposed(by: bag)
    }
    
    func update(with data: Order, nameOrder: String) {
        name.text = "Заказ №: " + data.name
        
        data.adress.asObservable()
            .bind { value in
                self.adress.text = "Адрес доставки: " + value
        }
        .disposed(by: bag)
        
        data.deliveryDate.asObservable()
            .bind { value in
                self.deliveryDate.text = "Дата доставки: " + value
        }
        .disposed(by: bag)
        
        data.status.asObservable()
            .bind { value in
                self.status.accept(value)
        }
        .disposed(by: bag)
        
        deleteStatus.asObservable()
            .filter{ $0 == true }
            .bind { _ in
                guard let shoppingListNew = self.viewModel!.list.value else {
                    return
                }
                
                for i in 0..<shoppingListNew.count {
                    if shoppingListNew[i].name == nameOrder {
                        let uidCheck = shoppingListNew[i].name
                        self.deleteStatus.accept(false)
                        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")

                        reachabilityManager?.listener = { status in
                            switch status {
                                case .notReachable:
                                    self.error.accept("Нет подключения к интернету")
                                case .unknown :
                                    self.error.accept("Нет подключения к интернету")
                                default:
                                    Firestore.firestore().collection("ShoppingList")
                                        .document(uidCheck)
                                        .rx
                                        .delete().subscribe(onNext: { resault in
                                            self.checkOut.accept(uidCheck)
                                        }).disposed(by: self.bag)
                                }
                            }
                            reachabilityManager?.startListening()
                            reachabilityManager?.stopListening()    
                    }
                }
        }
        .disposed(by: bag)
        
    }
    
}
