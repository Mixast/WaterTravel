import UIKit
import RxSwift
import RxCocoa

class AlertViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var price: UILabel!
    private(set) var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with data: Price) {
        name.text = data.name
        data.countBag.asObservable()
            .bind { pop in
                guard let countBag = pop else {
                    return
                }
                self.count.text = "Кол-во: " + String(describing: countBag)
                let priceBag = data.price
                let bayPrice = priceBag * countBag
                self.price.text = "Цена " + String(describing: bayPrice) + ".р"
        }
        .disposed(by: bag)
    }
}
