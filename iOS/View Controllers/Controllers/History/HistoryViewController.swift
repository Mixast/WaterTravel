import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class HistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: HistoryViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        bindUI()
    }
    
    fileprivate func bindUI() {
        viewModel.list.asDriver()
            .drive(onNext: { list in
                self.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.list.asDriver()
            .map { $0 != nil }
            .drive(messageView.rx.isHidden)
            .disposed(by: bag)
    }
        
    fileprivate func bindTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.tintColor = .red
        self.tableView.register(UINib(nibName: "HistoryTableViewHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "HistoryTableViewHeader")
        self.tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
    }
}

extension HistoryViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: HistoryViewModel) -> HistoryViewController {
        return storyboard.instantiateViewController(ofType: HistoryViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.list.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let text = viewModel.list.value?[section].price else {
            return 0
        }
        
        return text.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueHeader(ofType: HistoryTableViewHeader.self).then { cell in
            cell.viewModel = self.viewModel
            guard let selection = viewModel.list.value?[section] else { return }
            cell.update(with: selection, nameOrder: selection.name)
            
            cell.delete.rx.tap
                .bind { _ in
                    self.showDeleteAlert(massage: "Выбраный заказ будет удален", title: "Удалить заказ?", status: cell.deleteStatus)
            }
            .disposed(by: bag)
            
            cell.error.asDriver()
                .distinctUntilChanged()
                .filter { $0 != "" }
                .drive(onNext: { text in
                    cell.error.accept("")
                    self.showAlert(massage: text, title: "Ошибка удаления заказа")
                })
                .disposed(by: bag)
            
            cell.checkOut.asDriver()
                .distinctUntilChanged()
                .filter { $0 != "" }
                .drive(onNext: { text in
                    cell.checkOut.accept("")
                    self.showAlert(massage:  "Заказ №: " + text + " удален", title: "Удаление заказа прошло успешно")
                })
                .disposed(by: bag)
            
            
            cell.shere.rx.tap.asDriver()
            .drive(onNext: { _ in
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "dd MMMM (EEEE)"
                guard let date = dateFormatter.date(from:selection.deliveryDate.value) else {
                    return
                }
                
                let title = "Заказ № " +  selection.name
                
                var price = 0
                for i in 0..<selection.price.count {
                    let onePrice = selection.price[i].price * selection.price[i].countBag.value!
 
                    price += onePrice
                }
            
                UIAlertController.present(in: self, title: title, message: selection.price, price: String(price) + "р.", date: date, adres: selection.adress.value)
                    .filter { $0 != 0 }
                    .subscribe(onNext: { buttonIndex in
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
            
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(ofType: HistoryTableViewCell.self).then { cell in
            guard let selection = viewModel.list.value?[indexPath.section].price else { return }
            cell.update(with: selection[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        guard let text = viewModel.list.value?[section].price else {
            return nil
        }
        var price = 0
        for i in 0..<text.count {
            guard let count = text[i].countBag.value else {
                return label
            }
            price += text[i].price * count
        }
        
        label.text = "Итого: \(price)р."
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Light", size: 20)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
}
