import UIKit
import RxSwift
import RxCocoa

class PasswordResetViewController: UIViewController {
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var signUp: UIButton!
    
    private let bag = DisposeBag()
    fileprivate var viewModel: PasswordResetViewModel!
    fileprivate var navigator: Navigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        login.text = viewModel.user.login
        login.addTarget(self, action: #selector(fromValidation), for: .editingChanged)
        bind()
    }
    
    @objc fileprivate func fromValidation() {
        login.rx.value.asObservable()
            .bind { text in
                if text!.count > 0 {
                    guard self.login.hasText else {
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
    
    fileprivate func bind() {
        signUp.rx.tap.asDriver()
            .drive(onNext: { list in
                self.viewModel.user.login = self.login.text
                self.viewModel.refreshPasword()
            })
        .disposed(by: bag)
        
        viewModel.checkOut.asDriver()
            .skip(1)
            .distinctUntilChanged()
            .filter { $0 == true }
            .drive(onNext: { _ in
                self.viewModel.checkOut.accept(false)
                self.showAlertRefresh(massage: "Форма для сброса пароля выслана на почту", title: "Сброс пароля прошел успешно")
            })
            .disposed(by: bag)
        
        viewModel.error.asDriver()
            .skip(1)
            .filter { $0 != "" }
            .drive(onNext: { text in
                self.viewModel.error.accept("")
                self.showAlert(massage: text, title: "Ошибка регистрации")
            })
            .disposed(by: bag)
    }
}

extension PasswordResetViewController {
    static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: PasswordResetViewModel) -> PasswordResetViewController {
        return storyboard.instantiateViewController(ofType: PasswordResetViewController.self).then { vc in
            vc.navigator = navigator
            vc.viewModel = viewModel
        }
    }

    private func showAlertRefresh(massage: String, title: String) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)

        let action = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
