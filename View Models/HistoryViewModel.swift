import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import Unbox

class HistoryViewModel {
    let apiType: FirebaseAPIProtocol.Type
    private let bag = DisposeBag()
    // MARK: - Output
    let list = BehaviorRelay<[Order]?>(value: [])
    var userInfo = UserProfile()
    var price = 0
    
    init(apiType: FirebaseAPIProtocol.Type = FirebaseAPI.self, user: UserProfile) {
        self.apiType = apiType
        bindOutput()
    }
    
    private func bindOutput() {
        apiType.history().asObservable()
            .map { price in
                return (try? unbox(dictionaries: price, allowInvalidElements: true) as [Order]) ?? []
        }
        .bind(to: list)
        .disposed(by: bag)
    }
    
}

