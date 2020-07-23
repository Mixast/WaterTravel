import UIKit
import RxSwift
import RxCocoa

class PriceTableViewCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var price: UITextView!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var stepper: LineStepper!
    @IBOutlet weak var backView: UIView!
    var viewModel: PriceViewModel!
    private(set) var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designFor(textView: name)
        designFor(textView: price)
        designFor(textField: number)
        designFor(view: backView)
        bind()
    }
        
    fileprivate func bind() {
        if self.stepper != nil {
            stepper.rx.value.asObservable()
                .skip(1)
                .distinctUntilChanged()
                .bind { sender in
                    self.number.text = String(describing: Int(sender))
                    self.viewModel.step(steper: self.stepper)
                    
            }
            .disposed(by: bag)
            
            number.rx.text.asObservable()
                .filter{ ($0 != nil) && ($0 != "") }
                .distinctUntilChanged()
                .bind(onNext: { value in
                    
                    self.number.rx.controlEvent(.editingDidEnd).asObservable()
                        .bind { _ in
                            
                            guard let text = value else {
                                return
                            }
                            
                            guard let number = Double(text) else {
                                return
                            }
                            
                            if number != self.stepper.value {
                                self.stepper.value = number
                                self.viewModel.step(steper: self.stepper)
                            }
                            
                    }
                    .disposed(by: self.bag)
                })
                .disposed(by: bag)
  
        }
    }
    
    func update(with data: Price) {
        name.text = data.name
        price.text = "Цена " + String(describing:data.price) + " рублей"
        data.countBag.asObservable()
            .bind { value in
                guard let number = value else {
                    return
                }
                self.stepper.value = Double(number)
        }
        .disposed(by: bag)
        DispatchQueue.main.async {
            self.photo.setImage(with: URL(string: data.imageUrl))
        }
        
        guard let countBag = data.countBag.value else {
            return
        }
        number.text = String(describing: countBag)

    }
}

