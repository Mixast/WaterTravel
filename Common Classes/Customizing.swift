import UIKit

extension UIView {
    
    func designFor(textView: UITextView) {  // Кастамизирую кнопку
        textView.layer.cornerRadius = 6
        textView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.alpha = 0.85

        textView.layer.masksToBounds = false
        textView.layer.shadowRadius = 2.0
        textView.layer.shadowOpacity = 0.3
        textView.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        textView.isScrollEnabled = false
    }
    
    func designFor(textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        textField.layer.borderWidth = 0.4
        textField.layer.cornerRadius = 6
    }
    
    func designFor(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    func designFor(button: UIView) {
        button.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        button.layer.borderWidth = 0.4
        button.layer.cornerRadius = 6
        button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        button.alpha = 0.8
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}
