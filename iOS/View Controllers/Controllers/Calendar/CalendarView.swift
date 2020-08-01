//
//  CalendarView.swift
//  VideoReact
//
//  Created by Лекс Лютер on 11/07/2020.
//  Copyright © 2020 Лекс Лютер. All rights reserved.
//

import UIKit
import RxCocoa

class CalendarView: UIView {
    
    @IBOutlet weak var DateText: UILabel!
    let date = BehaviorRelay<Date>(value: Date())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        let viewFromXib = Bundle.main.loadNibNamed("CalendarView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
    }
    
    
    
}
