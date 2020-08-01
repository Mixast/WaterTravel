import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var countion: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        name.numberOfLines = 0
        price.numberOfLines = 0
        designFor(view: backView)
    }
    
    func update(with data: Price) {
        name.text = data.name
        price.text = "Цена " + String(describing: data.price) + "р./шт."
        data.countBag.asObservable()
            .bind { pop in
                guard let countBag = pop else {
                    return
                }
                self.countion.text = String(describing: countBag) + "шт."
        }
        .disposed(by: bag)
    }
    
}
