//
//  FilterView.swift
//  chpanPW8
//
//  Created by ZhengWu Pan on 20.03.2022.
//

import Foundation
import UIKit

class FilterView: UIStackView {
    let adultLabel = UILabel()
    let yearLabel = UILabel()
    let adultSwitch = UISwitch()
    let yearPicker = UIPickerView()
    
    var adultDelegate: AdultDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution  = .fill
        self.alignment = .center
        self.spacing = 10
        adultLabel.isUserInteractionEnabled = false
        adultSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        yearLabel.isUserInteractionEnabled = false
        adultLabel.text = "18+"
        adultSwitch.isOn = false
        yearLabel.text = "Year"
        yearPicker.setWidth(to: 200)
        yearPicker.setHeight(to: 1000)
        addArrangedSubview(adultLabel)
        addArrangedSubview(adultSwitch)
        addArrangedSubview(yearLabel)
        addArrangedSubview(yearPicker)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!)
    {
        adultDelegate!.setAdultFilter(isAdult: sender.isOn)
    }
}
