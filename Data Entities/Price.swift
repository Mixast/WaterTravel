import Foundation
import RealmSwift
import Unbox
import RxCocoa
import RxSwift

class Price: Object, Unboxable {
    @objc dynamic var name: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var imageUrl: String = ""
    dynamic var countBag = BehaviorRelay<Int?>(value: 0)
    dynamic var priceBag = BehaviorRelay<Int?>(value: 0)
    private let bag = DisposeBag()
    dynamic var time: String = ""
    
    // MARK: Init with Unboxer
    convenience required init(unboxer: Unboxer) throws {
        self.init()
        name = try unboxer.unbox(keyPath: "name")
        price = try unboxer.unbox(keyPath: "price")
        imageUrl = try unboxer.unbox(keyPath: "imageUrl")
        bindPriceBag()
    }
    
    convenience required init(name: String, price: Int, countBag: Int, time: String) throws {
        self.init()
        self.name = name
        self.price = price
        self.time = time
        self.countBag.accept(countBag)
    }
    
    private func bindPriceBag() {
        countBag.asObservable()
            .bind { val in
                
                guard let value = val else {
                    return
                }
                let namber = self.price * value
                self.priceBag.accept(namber)
        }
        .disposed(by: bag)
    }
}
