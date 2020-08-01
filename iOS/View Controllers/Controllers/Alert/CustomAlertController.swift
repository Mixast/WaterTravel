import UIKit

class CustomAlertController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var alerttitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    var message = [Price]()
    
    init(title: String, message: [Price], leftBut: String, rightBut: String, price: String, deliveryDate: Date, adres: String) {
        super.init(nibName: "CustomAlertController", bundle: .none)
        Bundle.main.loadNibNamed("CustomAlertController", owner: self, options: nil)
        view.designFor(view: containerView)
        self.message = message
        self.alerttitle.text = title
        self.price.text = price
        self.leftButton.setTitle(leftBut, for: .normal)
        self.rightButton.setTitle(rightBut, for: .normal)
        self.bindTableView()
        self.bindButton(title: title, message: message, price: price, deliveryDate: deliveryDate, adres: adres)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func bindTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.tintColor = .red
        self.tableView.backgroundColor = .white
        self.tableView.register(UINib.init(nibName: "AlertViewCell", bundle: nil), forCellReuseIdentifier: "AlertViewCell")
    }
    
    fileprivate func bindButton(title: String, message: [Price], price: String, deliveryDate: Date, adres: String){
        leftButton.rx.tap
            .subscribe(onNext: { _ in
                
                var text = "\t\t\t\t" + title
                for i in 0..<message.count {
                    text += "\n"
                    text += String(i+1) + ". "
                    text += message[i].name + "    "
                    guard let count = message[i].countBag.value else {
                        return
                    }
                    text += String(describing: count)  + "шт.    "
                    text += String(describing: message[i].price) + "р./шт.    "
                }
                text += "\n" + "Итого: " + price
                text += "\n" + "\n" + "Дата доставки: " + deliveryDate.timestamp
                text += "\n" + "Адрес доставки: " + adres
                
                let textData = text.data(using: .utf8)
                let textURL = textData?.dataToFile(fileName: title + ".txt")
                var filesToShare = [Any]()
                filesToShare.append(textURL!)
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
                
            })
            .disposed(by: bag)
    }
}

extension CustomAlertController: UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(ofType: AlertViewCell.self).then { cell in
            cell.update(with: message[indexPath.row])
            
        }
    }
}
