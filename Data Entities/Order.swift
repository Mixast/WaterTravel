import Foundation
import RealmSwift
import Unbox
import RxCocoa
import RxSwift

class Order: Object, Unboxable {
    @objc dynamic var name: String = ""
    let status = BehaviorRelay<Int>(value: 0)
    let adress = BehaviorRelay<String>(value: "")
    let deliveryDate = BehaviorRelay<String>(value: "")
    var price: [Price] = []
    
    // MARK: Init with Unboxer
    convenience required init(unboxer: Unboxer) throws {
        self.init()
        name = try unboxer.unbox(keyPath: "name")
        price = try unboxer.unbox(keyPath: "price")
        status.accept(try unboxer.unbox(keyPath: "status"))
        adress.accept(try unboxer.unbox(keyPath: "adress"))
        deliveryDate.accept(try unboxer.unbox(keyPath: "deliveryDate"))
    }
    
}
