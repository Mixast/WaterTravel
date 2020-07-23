import Foundation
import UIKit
import RxSwift
import RxCocoa

let bag = DisposeBag()
extension UIAlertController {
    static func present(
        in viewController: UIViewController,
        title: String,
        message: [Price],
        price: String,
        date: Date,
        adres: String)
        -> Observable<Int>
    {
        return Observable.create { observer in
            let alertVC = CustomAlertController(title: title, message: message, leftBut: "Сохранить", rightBut: "Ok", price: price, deliveryDate: date, adres: adres)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            viewController.present(alertVC, animated: true, completion: nil)
            
            alertVC.rightButton.rx.tap
                .subscribe(onNext: { _ in
                    observer.onNext(2)
                    observer.onCompleted()
                })
                .disposed(by: bag)
            
            return Disposables.create {
                alertVC.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}
