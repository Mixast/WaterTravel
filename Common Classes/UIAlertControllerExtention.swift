import UIKit
import RxCocoa
import RxSwift

public extension UIViewController {
    
    func showAlert (massage: String, title: String) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func showDeleteAlert (massage: String, title: String, status: BehaviorRelay<Bool>)  {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let back = UIAlertAction(title: "Back", style: .default, handler: nil)
        
        let action = UIAlertAction(title: "Ok", style: .default) { (pop) in
            status.accept(true)
        }
        alert.addAction(action)
        alert.addAction(back)
        present(alert, animated: true, completion: nil)
    }
    
    func showEditAlert (massage: String, title: String, status: BehaviorRelay<[String]>, arr: [String]) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let back = UIAlertAction(title: "Back", style: .default, handler: nil)
        
        var newArr = [String]()
        
        let action = UIAlertAction(title: "Ok", style: .default) { (pop) in
            
            let name = alert.textFields![0] as UITextField
            let adres = alert.textFields![1] as UITextField
            let telephone = alert.textFields![2] as UITextField
            newArr[0] = name.text ?? ""
            newArr[1] = adres.text ?? ""
            newArr[2] = telephone.text ?? ""
            status.accept(newArr)
        }
        action.isEnabled = false
        
        alert.addTextField { textField in
            textField.placeholder = "Имя"
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .words
            textField.text = arr[0]
            newArr.append(arr[0])
            textField.delegate = self as? UITextFieldDelegate
            
            textField.rx.value.asObservable()
                .bind { text in

                    if text?.count != 0 {
                        action.isEnabled = true
                    } else {
                        action.isEnabled = false
                    }
            }
            .disposed(by: bag)
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Адрес"
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .sentences
            textField.text = arr[1]
            newArr.append(arr[1])
            textField.delegate = self as? UITextFieldDelegate
            
            textField.rx.value.asObservable()
                .bind { text in
                    if text?.count != 0 {
                        action.isEnabled = true
                    } else {
                        action.isEnabled = false
                    }
            }
            .disposed(by: bag)
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Телефон"
            textField.keyboardType = UIKeyboardType.phonePad
            textField.keyboardAppearance = .dark
            textField.text = arr[2]
            newArr.append(arr[2])
            
            textField.delegate = self as? UITextFieldDelegate
            
            textField.rx.value.asObservable()
                .bind { text in
                    if text?.count == 11 {
                        action.isEnabled = true
                    } else {
                        action.isEnabled = false
                    }
            }
            .disposed(by: bag)
        }
        
        alert.addAction(action)
        alert.addAction(back)
        present(alert, animated: true, completion: nil)
    }
}


