import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Unbox

class PriceViewModel {
    let apiType: FirebaseAPIProtocol.Type
    private let bag = DisposeBag()
    // MARK: - Output
    let list = BehaviorRelay<[Price]?>(value: [])
    let basket = BehaviorRelay<[Price]?>(value: [])
    var userInfo = UserProfile()
    
    init(apiType: FirebaseAPIProtocol.Type = FirebaseAPI.self, user: UserProfile) {
        self.apiType = apiType
        userInfo = user
        bindOutput()
        bind()
        clear()
    }
    
    private func bind() {
        basket.asObservable()
            .skip(1)
            .bind { value in
                guard let element = value else {
                    return
                }
                guard let list = self.list.value else {
                    return
                }
                
                for m in 0..<list.count {
                    for i in 0..<element.count {
                        if list[m].name == element[i].name {
                            list[m].countBag.accept(element[i].countBag.value)
                        }
                    }
                }
        }
        .disposed(by: bag)
        
    }
    
    private func bindOutput() {
        //fetch list members
        apiType.list(user: userInfo).asObservable()
            .map { price in
                return (try? unbox(dictionaries: price, allowInvalidElements: true) as [Price]) ?? []
        }
        .bind(to: list)
        .disposed(by: bag)
    }
    
    private func clear() {
        basket.asDriver()
            .filter { value in
                if value != [] {
                    return true
                } else {
                    return false
                }
            }
        .distinctUntilChanged()
        .drive(onNext: { list in
            guard let valueList = list else {
                return
            }
            for i in 0..<valueList.count {
                
                valueList[i].countBag.asDriver()
                    .filter { value in
                        if i >= self.basket.value!.count{
                            return false
                        }
                        if value != nil && value == 0 {
                            return true
                        } else {
                            return false
                        }
                }
                .drive(onNext: { [weak self] element in
                    guard var fixList = self?.basket.value else {
                        return
                    }
                    for m in 0..<fixList.count {
                        if fixList[m].countBag.value == 0 {
                            fixList.remove(at: m)
                            self?.basket.accept(fixList)
                            break
                        }
                    }
                }).disposed(by: self.bag)
            }
        }).disposed(by: bag)
    }
    
    func step(steper: LineStepper) {
        guard let listValue = list.value else {
            return
        }
        listValue[steper.row].countBag.accept(Int(steper.value))
    }
}
