import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Firebase
import RxFirebase
import Then

class PriceViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: PriceViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        bindTableView()        
    }
    
    fileprivate func bindTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(UINib(nibName: "PriceTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceTableViewCell")
    }
    
    fileprivate func bindUI() {
        
        viewModel.list.asDriver()
            .drive(onNext: { list in
                guard let listValue = list else {
                    return
                }
                for i in 0..<listValue.count {
                    listValue[i].countBag.asDriver()
                        .drive(onNext: { _ in
                            self.tableView.reloadData()
                        })
                        .disposed(by: self.bag)
                    
                }
                self.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.list.asDriver()
            .map { $0 != nil }
            .drive(messageView.rx.isHidden)
            .disposed(by: bag)
    }   
}

extension PriceViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: PriceViewModel) -> PriceViewController {
        return storyboard.instantiateViewController(ofType: PriceViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }
}

extension PriceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(ofType: PriceTableViewCell.self).then { cell in
            guard let selection = viewModel.list.value else { return }
            cell.update(with: selection[indexPath.row])
            cell.stepper.row = indexPath.row
            cell.viewModel = viewModel
        }
    }
}

extension PriceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)  
        var arr = viewModel.basket.value!
        
        // MARK: - Новые данные с Stepper
        viewModel.list.asObservable()
            .distinctUntilChanged()
            .filter({ list in
                if list![indexPath.row].countBag.value == 0 {
                    return false
                }
                for i in 0..<arr.count {
                    if arr[i].name == list![indexPath.row].name {
                        return false
                    }
                }

                return true
            })
            .map { list in

                let element = list![indexPath.row]
                let value = list![indexPath.row].countBag.value
                element.countBag.accept(value)

                arr.append(element)

                return arr
        }
        .bind(to: viewModel.basket)
        .disposed(by: bag)
        
        // MARK: - Новые данные с сервера
        viewModel.list.asObservable()
            .distinctUntilChanged()
            .filter({ list in
                for i in 0..<arr.count {
                    if arr[i].name == list![indexPath.row].name {
                        return true
                    }
                }
                return false
            })
            .map { list in
                for m in 0..<arr.count {
                    for i in 0..<list!.count {
                        if arr[m].name == list![i].name {
                            arr[m].price = list![i].price
                            arr[m].imageUrl = list![i].imageUrl
                            
                            let valueCountBag = arr[m].countBag.value
                            arr[m].countBag = list![i].countBag
                            arr[m].countBag.accept(valueCountBag)
                            
                            let valuePriceBag = arr[m].priceBag.value
                            arr[m].priceBag = list![i].priceBag
                            arr[m].priceBag.accept(valuePriceBag)
                        }
                    }
                }
                return arr
        }
        .bind(to: viewModel.basket)
        .disposed(by: bag)
        
    }
}

