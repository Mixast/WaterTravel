import UIKit
import RxSwift
import RxCocoa
//import Then

class SignUPViewController: UIViewController {
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var phoneNumber: UITextField!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: SignUpViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue()
        hadlers()
        bind()
    }
    
    fileprivate func bind() {
        viewModel.checkOut.asDriver()
            .skip(1)
            .distinctUntilChanged()
            .filter { $0 == true }
            .drive(onNext: { _ in
                self.showAlertRegister(massage: "", title: "Регистрация прошла успешно")
            })
            .disposed(by: bag)
        
        viewModel.error.asDriver()
            .skip(1)
            .filter { $0 != "" }
            .drive(onNext: { text in
                self.showAlert(massage: text, title: "Ошибка регистрации")
            })
            .disposed(by: bag)
    }
    // MARK: - Set Value
    fileprivate func setValue() {
        login.text = viewModel.user.login
        password.text = viewModel.user.password
    }
    
    // MARK: - Hadlers
    fileprivate func hadlers() {
        login.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        password.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        name.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        address.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        
    }
    
    @objc fileprivate func fromValidation() {
        phoneNumber.rx.value.asObservable()
            .bind { text in
                if text?.count == 11 {
                    guard self.login.hasText, self.password.hasText, self.name.hasText, self.address.hasText, self.phoneNumber.hasText else {
                        self.signUp.isEnabled = false
                        self.signUp.backgroundColor = #colorLiteral(red: 0.298440963, green: 0.1712138951, blue: 0.5207042098, alpha: 1)
                        return
                    }
                    self.signUp.isEnabled = true
                    self.signUp.backgroundColor = #colorLiteral(red: 0.4969757199, green: 0.286596626, blue: 0.8779702783, alpha: 1)
                } else {
                    self.signUp.isEnabled = false
                    self.signUp.backgroundColor = #colorLiteral(red: 0.298440963, green: 0.1712138951, blue: 0.5207042098, alpha: 1)
                }
        }
        .disposed(by: bag)
    }
    
    @IBAction func registration(_ sender: Any) {
        
        self.view.endEditing(true)
        viewModel.user.login = login.text ?? ""
        viewModel.user.password = password.text ?? ""
        
        let adress = Adress(name: name.text ?? "", adress: address.text ?? "", phoneNumber: phoneNumber.text ?? "")
        
        viewModel.user.address.accept([adress])
        viewModel.checkOut.accept(false)
        viewModel.auth()
    }
}

extension SignUPViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: SignUpViewModel) -> SignUPViewController {
        return storyboard.instantiateViewController(ofType: SignUPViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }

    private func showAlertRegister (massage: String, title: String) {    // Вывод ошибки если пользователь ввел неправильно данные
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        
        let adress = Adress(name: self.name.text ?? "", adress: self.address.text ?? "", phoneNumber: self.phoneNumber.text ?? "")
        
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: { _ in

            let user = UserProfile(login: self.login.text ?? "", password: self.password.text ?? "", address: [adress], userName: self.name.text ?? "", userPhone: self.phoneNumber.text ?? "")

            let mainVC = TabBarController(user: user)
            let navControler = UINavigationController(rootViewController: mainVC)
            navControler.modalPresentationStyle = .fullScreen
            navControler.setNavigationBarHidden(true, animated: false)

            self.present(navControler, animated: true, completion: nil)
        })
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}


