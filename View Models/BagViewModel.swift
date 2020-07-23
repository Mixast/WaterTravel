import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Firebase
import RxFirebase
import Alamofire
import RxAlamofire

class BagViewModel {
    private let bag = DisposeBag()
    let shoppingList = BehaviorRelay<[Price]?>(value: [])
    var price = 0
    var userInfo = UserProfile()
    let checkOut = BehaviorRelay<String>(value: "")
    let error = BehaviorRelay<String>(value: "")
    var adress: Adress = Adress()
    var data = Date()
    
    private let activityIndicator = UIActivityIndicatorView()
    
    init(element: BehaviorRelay<[Price]?>, user: UserProfile) {
        
        userInfo = user
        element.asObservable()
            .map { event in
                return event
        }
        .bind(to: shoppingList)
        .disposed(by: bag)
        shoppingListFilter()
    }
    
    private func shoppingListFilter() {
        shoppingList.asDriver()
            .distinctUntilChanged()
            .drive(onNext: { list in
                var arr = [Int:Int]()
                guard let valueList = list else {
                    return
                }
                
                for i in 0..<valueList.count {
                    arr[i] = 0
                    valueList[i].priceBag.asDriver()
                        .filter{ ($0 != nil) && ($0 != 0) }
                        .drive(onNext: { [weak self] element in
                            guard let value = element else {
                                return
                            }
                            arr[i] = value

                            var end = 0
                            for m in 0..<arr.count {
                                end += arr[m] ?? 0
                            }
                            self?.price = end
                        })
                        .disposed(by: self.bag)
                }
            })
            .disposed(by: bag)
    }
    
    func step(LineText: LineTextField) {
        guard let list = shoppingList.value else {
            return
        }
        if LineText.row < list.count {
            let listValue = shoppingList.value!
            guard let text = LineText.text else {
                return
            }
            let intText = Int(text)
            if listValue[LineText.row].countBag.value != intText {
                listValue[LineText.row].countBag.accept(intText)
            }
        }
    }
    
    func buy() {
        guard let uid = userInfo.uuid else {
            return
        }
        
        guard let shoppingListNew = shoppingList.value else {
            return
        }

        var list = [Any]()
        for i in 0..<shoppingListNew.count {
            let element: [String : Any] = ["Name": shoppingListNew[i].name,
                                           "Count": shoppingListNew[i].countBag.value!,
                                           "Price": shoppingListNew[i].price]
            list.append(element)

        }

        let now = Date()
        
        let ditionaryValue = ["Name": adress.name as Any,
                              "Adress" : adress.adress as Any,
                              "Phone Number" : adress.phoneNumber as Any,
                              "orderData" : now,
                              "deliveryDate" : data,
                              "status" : 0,
                              "flight" : "",
                              "Shopping List" : list]
        
        let value: [String : Any] = [ uid : ditionaryValue ]
        let numberBuy = randomString(length: 6)
        
        let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
        
        reachabilityManager?.listener = { status in
            switch status {
                case .notReachable:
                    self.error.accept("Нет подключения к интернету")
                case .unknown :
                    self.error.accept("Нет подключения к интернету")
                default:
                    Firestore.firestore().collection("ShoppingList")
                        .document(numberBuy)
                        .rx
                        .setData(value).subscribe(onNext: { resault in
                            self.checkOut.accept(numberBuy)
                        }).disposed(by: self.bag)

                }
            }
            reachabilityManager?.startListening()
    }
    
    private func randomString(length: Int) -> String {
        
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        
        var randomString = "Mac-"
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
}

