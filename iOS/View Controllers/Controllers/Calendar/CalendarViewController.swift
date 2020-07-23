import UIKit
import RxCocoa
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    let dateRX = BehaviorRelay<Date>(value: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
 
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = +1
        dateComponents.hour = -21
        let currentCalander: Calendar = Calendar.current
        guard let dateCurrent = currentCalander.date(byAdding:dateComponents, to: date) else {
            return
        }
        dateRX.accept(dateCurrent)
        dismiss(animated: true, completion: .none)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        var dateComponents: DateComponents = DateComponents()
        dateComponents.day = +1
        let currentCalander: Calendar = Calendar.current
        guard let dateCurrent = currentCalander.date(byAdding:dateComponents, to: date) else {
            return true
        }
        let weekday = currentCalander.component(.weekday, from: dateCurrent)
        
        if weekday == 2 || weekday == 1 {
            return false
        } else {
            return true
        }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        var dateComponents:DateComponents = DateComponents()
        dateComponents.hour = 13
        dateComponents.minute = 30
        let currentCalander:Calendar = Calendar.current
        return currentCalander.date(byAdding:dateComponents, to: Date())!
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        var dateComponents:DateComponents = DateComponents()
        dateComponents.day = 13
        let currentCalander:Calendar = Calendar.current
        return currentCalander.date(byAdding:dateComponents, to: Date())!
    }
    
}
