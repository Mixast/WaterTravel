import UIKit
import RxSwift
import RxCocoa
import Firebase
import RxFirebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: ProfileViewModel!
    fileprivate var navigator: Navigator!
    fileprivate var newAdress = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.designFor(button: addButton)
        bindTableView()
        bindButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    fileprivate func bindButton() {
        addButton.rx.tap
            .bind {
                self.showEditAlert(massage: "Введите данные о новом пользователе", title: "Добавление нового пользователя", status: self.newAdress, arr: ["", "", ""])
                
                self.showAlert(massage: "tap", title: "tap")
        }
        .disposed(by: bag)
        
        newAdress.asObservable()
            .filter{ $0 != [] }
            .bind { value in
                guard let uid = self.viewModel!.userInfo.uuid else {
                    return
                }
                
                let adresValue = self.viewModel!.userInfo.address.value
                
                var address = [[String: String]]()
                for i in 0..<adresValue.count {
                    address.append([
                        "name" : adresValue[i].name ?? "",
                        "phoneNumber" : adresValue[i].phoneNumber ?? "",
                        "adress" : adresValue[i].adress ?? ""
                    ])
                }
                
                address.append([
                    "name" : value[0],
                    "phoneNumber" : value[2],
                    "adress" : value[1]
                ])
                
                let ditionaryValue = ["Login": self.viewModel!.userInfo.login ?? "", "UserName": self.viewModel!.userInfo.userName ?? "", "UserPhone": self.viewModel!.userInfo.userPhone ?? "", "Adress" : address] as [String : Any]
                let value = [ uid: ditionaryValue ] as [String : Any]
                
                Firestore.firestore().collection("Users")
                    .document(uid)
                    .rx
                    .setData(value).subscribe(onNext: { _ in
                    }, onError: { error in
                        print(error.localizedDescription)
                    }).disposed(by: self.bag)
        }
        .disposed(by: bag)
        
    }
    
    fileprivate func bindTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
    }
    
    @objc fileprivate func handleLogOut() {
        do {
            try Auth.auth().signOut()
            guard let window = self.view.window else { return }
            if window.rootViewController is TabBarController {
                let start = LoginViewController.createWith(navigator: navigator, storyboard:
                    R.storyboard.loginViewController(), viewModel: LoginViewModel())
                window.rootViewController = start
            } else {
                dismiss(animated: true)
            }
        } catch { }
    }
    
}

extension ProfileViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: ProfileViewModel) -> ProfileViewController {
        return storyboard.instantiateViewController(ofType: ProfileViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = viewModel.userInfo.address.value
        return value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueCell(ofType: ProfileTableViewCell.self).then { cell in
            let selection = viewModel.userInfo.address.value
            cell.viewModel = self.viewModel
            cell.update(with: selection[indexPath.row], index: indexPath.row)
            
            var arr = [String]()
            arr.append(cell.name.text ?? "")
            arr.append(cell.adress.text ?? "")
            arr.append(cell.phone.text ?? "")
            
            cell.edit.rx.tap
                .bind { _ in
                    self.showEditAlert(massage: "Выбраный адрес будет изменен", title: "Изменить выбранный адресс?", status: cell.editStatus, arr: arr)
            }
            .disposed(by: bag)
            
            cell.delete.rx.tap
                .bind { _ in
                    self.showDeleteAlert(massage: "Выбраный адрес будет удален", title: "Удалить данные?", status: cell.deleteStatus)
            }
            .disposed(by: bag)
            
            cell.error.asDriver()
                .filter { $0 != "" }
                .drive(onNext: { text in
                    self.showAlert(massage: text, title: "Ошибка изменения данных")
                })
                .disposed(by: bag)
            
        }
    }
}
