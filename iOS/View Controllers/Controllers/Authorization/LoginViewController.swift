import UIKit
import RxSwift
import RxCocoa
//import Then

class LoginViewController: UIViewController {
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var hidePassword: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var help: UIButton!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: LoginViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        viewModel.checkOut.asDriver()
            .filter { $0.uuid != "" }
            .drive(onNext: { value in
                let mainVC = TabBarController(user: value)
                let navControler = UINavigationController(rootViewController: mainVC)
                navControler.modalPresentationStyle = .fullScreen
                navControler.setNavigationBarHidden(true, animated: false)

                self.present(navControler, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        viewModel.error.asDriver()
            .filter { $0 != "" }
            .drive(onNext: { text in
                self.showAlert(massage: text, title: "Ошибка авторизации")
            })
            .disposed(by: bag)
        
        hadlers()
        bindUI()
    }
    
    fileprivate func bindUI() {
        help.rx.tap.asDriver()
            .drive(onNext: { list in
                let user = UserProfile()
                user.login = self.login.text ?? ""
                self.navigator.show(segue: .PasswordResetViewController(user), sender: self)
            })
        .disposed(by: bag)
    }
    
    // MARK: - Hadlers
    fileprivate func hadlers() {
        login.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        password.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
    }
    
    @objc fileprivate func fromValidation() {
        guard login.hasText, password.hasText else {
            signUp.isEnabled = false
            signUp.backgroundColor = #colorLiteral(red: 0.298440963, green: 0.1712138951, blue: 0.5207042098, alpha: 1)
            return
        }
        signUp.isEnabled = true
        signUp.backgroundColor = #colorLiteral(red: 0.4969757199, green: 0.286596626, blue: 0.8779702783, alpha: 1)
    }
    
    // MARK: - Hide Password
    @IBAction func hidePassword(_ sender: Any) {
        password.isSecureTextEntry.toggle()
        if password.isSecureTextEntry == false {
            hidePassword.setTitle("Скрыть",for: .normal)
        } else {
            hidePassword.setTitle("Показать",for: .normal)
        }
    }
    
    @IBAction func logined(_ sender: Any) {
        if login.text!.isEmpty == false {
            if password.text!.isEmpty == false {
                guard let email = login.text, let password = password.text else {
                    return
                }
                viewModel.auth(login: email, password: password)
            }
        }
    }
    
    // MARK: - Sign UP
    @IBAction func signUP(_ sender: Any) {
        let user = UserProfile()
        user.login = login.text ?? ""
        user.password = password.text ?? ""
        navigator.show(segue: .SignUPViewController(user), sender: self)
    }
}

extension LoginViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: LoginViewModel) -> LoginViewController {
        
        return storyboard.instantiateViewController(ofType: LoginViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }
}
