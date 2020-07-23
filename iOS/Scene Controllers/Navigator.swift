import Foundation
import UIKit
import RxSwift
import RxCocoa
import FSCalendar

class Navigator {
    // MARK: - segues list
    enum Segue {
        case TabBarController
        case LoginViewController
        case SignUPViewController(UserProfile)
        case PasswordResetViewController(UserProfile)
    }
    
    // MARK: - invoke a single segue
    func show(segue: Segue, sender: UIViewController) {
        
        switch segue {
        case .TabBarController:
            show(target: TabBarController(user: UserProfile()), sender: sender)
        case .LoginViewController:
            let vm = LoginViewModel()
            show(target: LoginViewController.createWith(navigator: self, storyboard:
                R.storyboard.loginViewController(), viewModel: vm), sender: sender)
        case .SignUPViewController(let user):
            let vm = SignUpViewModel(user: user)
            show(target: SignUPViewController.createWith(navigator: self, storyboard: R.storyboard.loginViewController(), viewModel: vm), sender: sender)
        case .PasswordResetViewController(let user):
            let vm = PasswordResetViewModel(user: user)
            show(target: PasswordResetViewController.createWith(navigator: self, storyboard: R.storyboard.loginViewController(), viewModel: vm), sender: sender)
        }
    }
    
    private func show(target: UIViewController, sender: UIViewController) {
        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        if let nav = sender.navigationController {
            //add controller to navigation stack
            nav.pushViewController(target, animated: true)
        } else {
            //present modally
            sender.present(target, animated: true, completion: nil)
        }
    }

}
