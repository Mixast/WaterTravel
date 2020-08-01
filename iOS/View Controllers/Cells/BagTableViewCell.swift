import UIKit
import RxSwift
import RxCocoa

class BagTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var countion: LineTextField!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var backView: UIView!
    var viewModel: BagViewModel!
    private(set) var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        name.numberOfLines = 0
        price.numberOfLines = 0
        designFor(textField: countion)
        designFor(view: backView)
        bind()
    }
    
    fileprivate func bind() {
        countion.rx.text.asObservable()
            .filter{ ($0 != nil) && ($0 != "") }
            .distinctUntilChanged()
            .bind(onNext: { value in
                guard let text = value else {
                    return
                }
                
                self.countion.text  = text
                guard let countBag = self.viewModel.shoppingList.value else {
                    return
                }
                
                self.countion.rx.controlEvent(.editingDidEnd).asObservable()
                    .bind { _ in
                        
                        if Int(text) != countBag[self.countion.row].countBag.value {
                            self.viewModel.step(LineText: self.countion)
                        }
                }
                .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
    
    func update(with data: Price) {
        name.text = data.name
        data.countBag.asObservable()
            .bind { pop in
                guard let countBag = pop else {
                    return
                }
                self.countion.text = String(describing: countBag)
                let priceBag = data.price
                let bayPrice = priceBag * countBag
                self.price.text = "Цена " + String(describing: bayPrice) + ".р"
        }
        .disposed(by: bag)
    }
    
}
