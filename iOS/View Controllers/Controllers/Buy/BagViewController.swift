import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then
import FSCalendar

class BagViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var adressView: UIView!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var adress: UIPickerView!
    @IBOutlet weak var deliveryDate: CalendarView!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: BagViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.designFor(button: buyButton)
        bindUI()
        bindBuy()
        bindTableView()
        bindPicker()
    }
    
    fileprivate func bindPicker() {
        viewModel.userInfo.address.asObservable()
        .bind(to: adress.rx.itemTitles) { _, item in
            self.viewModel.adress = item
            return "\(item.adress!)"
        }
        .disposed(by: bag)
    
        adress.rx.itemSelected
            .subscribe { (event) in
                switch event {
                case .next(let selected):
                    let adress = self.viewModel.userInfo.address.value
                    if adress.count > 1 {
                        self.viewModel.adress = adress[selected.row]
                    }
                default:
                    break
                }
        }
        .disposed(by: bag)
    
        let date = Date()
        
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = +1
        let currentCalander: Calendar = Calendar.current
        guard let dateCurrent = currentCalander.date(byAdding:dateComponents, to: date) else {
            return
        }
        
        deliveryDate.date.accept(dateCurrent)
        deliveryDate.DateText.text = String(describing: dateCurrent.timestamp)
        deliveryDate.DateText.textColor = .darkText
        self.viewModel.data = deliveryDate.date.value
        
        deliveryDate.date.asDriver()
            .skip(1)
            .drive(onNext: { value in
                self.deliveryDate.DateText.text = value.timestamp
                self.viewModel.data = value
            })
            .disposed(by: bag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        deliveryDate.addGestureRecognizer(tap)
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {

        let alertVC = CalendarViewController()
        
        alertVC.dateRX.asDriver()
            .skip(1)
            .drive(onNext: { value in
                self.deliveryDate.date.accept(value)
            })
            .disposed(by: bag)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func bindUI() {
        viewModel.shoppingList.asDriver()
            .drive(onNext: { pop in
                for i in 0..<pop!.count {
                    pop![i].priceBag.asDriver()
                        .distinctUntilChanged()
                        .drive(onNext: { [weak self] element in
                            self?.priceText.text = "Итого: " + String(self!.viewModel.price)  + ".р"
                            self?.tableView.reloadData()
                        })
                        .disposed(by: self.bag)
                }
                if pop!.count == 0 {
                    self.priceView.isHidden = true
                    self.adressView.isHidden = true
                } else {
                    self.priceView.isHidden = false
                    self.adressView.isHidden = false
                }
                self.tableView.reloadData()
            })
            .disposed(by: bag)
    }
    
    fileprivate func bindBuy() {
        buyButton.rx.tap
        .bind {
            if self.viewModel.adress.adress != "" {
                self.viewModel.buy()
            } else {
                self.showAlert(massage: "Не выбран адрес доставки", title: "Ошибка оформления заказа")
            }
        }
        .disposed(by: bag)
    
        viewModel.checkOut.asDriver()
            .distinctUntilChanged()
            .filter { $0 != "" }
            .drive(onNext: { numder in
                guard let value = self.viewModel.shoppingList.value else {
                    return
                }
          
                let title = "Заказ № " +  numder
                
                let price = String(self.viewModel.price) + "р."
                UIAlertController.present(in: self, title: title, message: value, price: price, date: self.deliveryDate.date.value, adres: self.viewModel?.adress.adress ?? "")
                    .filter { $0 != 0 }
                    .subscribe(onNext: { buttonIndex in
                        guard var newList = self.viewModel.shoppingList.value else {
                            return
                        }
                        for i in 0..<newList.count {
                            newList[i].countBag.accept(0)
                        }
                        newList.removeAll()
                        self.viewModel.shoppingList.accept(newList)
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        viewModel.error.asDriver()
            .filter { $0 != "" }
            .drive(onNext: { text in
                self.showAlert(massage: text, title: "Ошибка оформления заказа")
            })
            .disposed(by: bag)
    }
    
    fileprivate func bindTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.tintColor = .red
        self.tableView.register(UINib(nibName: "BagTableViewCell", bundle: nil), forCellReuseIdentifier: "BagTableViewCell")
    }
}

extension BagViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: BagViewModel) -> BagViewController {
        return storyboard.instantiateViewController(ofType: BagViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }
}

extension BagViewController: UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shoppingList.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(ofType: BagTableViewCell.self).then { cell in
            guard let selection = viewModel.shoppingList.value else { return }
            cell.update(with: selection[indexPath.row])
            cell.countion.delegate = self
            cell.countion.row = indexPath.row
            cell.viewModel = viewModel
        }
    }
}

