//
//  DOnOffTypeButton.swift
//  DControl
//  MacOSのTypeOnOff風のボタン
//  Created by DIO on 2019/10/27.
//  Copyright © 2019 DIO. All rights reserved.
//

import UIKit

@IBDesignable
public class DOnOffTypeButton: UIButton {
    
    // ONの場合の背景色
    @IBInspectable var onStateBgColor: UIColor = UIColor.systemBlue
    // OFFの場合の背景色
    @IBInspectable var offStateBgColor: UIColor = UIColor.white
    
    // ONの場合の文字色
    @IBInspectable var onStateTitleColor: UIColor = UIColor.systemBlue
    // OFFの場合の文字色
    @IBInspectable var offStateTitleColor: UIColor = UIColor.white;
    
    // ONの場合の枠線の色
    @IBInspectable var onStateBorderColor: UIColor = UIColor.cyan
    // OFFの場合の枠線の色
    @IBInspectable var offStateBorderColor: UIColor = UIColor.systemBlue
    
    // 枠線の太さ
    @IBInspectable var borderWidth: CGFloat = 1.0
    // ボタンのステータス
    override public var isSelected: Bool {
        willSet {
            if newValue {
                self.backgroundColor = self.onStateBgColor
                self.setTitleColor(self.onStateTitleColor, for: .normal)
                self.layer.borderColor = self.onStateBorderColor.cgColor
            } else {
                self.backgroundColor = self.offStateBgColor
                self.setTitleColor(self.offStateTitleColor, for: .normal)
                self.layer.borderColor = self.offStateBorderColor.cgColor
            }
        }
    }
    
    // 角丸
    @IBInspectable var cornerRadius:CGFloat = 0
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = true
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = self.offStateBorderColor.cgColor
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = event?.touches(for: self)?.first else { return }
        let point = touch.location(in: self)
        if self.bounds.contains(point) {
            self.isSelected = !self.isSelected
            self.sendActions(for: UIControl.Event.touchUpInside)
        }
    }
    
}
