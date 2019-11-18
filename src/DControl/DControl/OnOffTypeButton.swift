//
//  OnOffTypeButton.swift
//  DControl
//  MacOSのTypeOnOff風のボタン
//  Created by DIO on 2019/10/27.
//  Copyright © 2019 DIO. All rights reserved.
//

import UIKit

@IBDesignable
public class OnOffTypeButton: UIButton {
    
    // ONの場合の背景色
    @IBInspectable var onStateBgColor:UIColor = UIColor.systemBlue
    // OFFの場合の背景色
    @IBInspectable var offStateBgColor:UIColor = UIColor.white
    
    // ONの場合の文字色
    @IBInspectable var onStateTitleColor:UIColor = UIColor.systemBlue
    // OFFの場合の文字色
    @IBInspectable var offStateTitleColor:UIColor = UIColor.white;
    
    // ONの場合の枠線の色
    @IBInspectable var onStateBorderColor:UIColor = UIColor.cyan
    // OFFの場合の枠線の色
    @IBInspectable var offStateBorderColor:UIColor = UIColor.systemBlue
    
    // 枠線の太さ
    @IBInspectable var borderWidth:CGFloat = 1.0
    // ボタンのステータス
    @IBInspectable public private(set) var buttonState:Bool = false {
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
        // buttonStateのwillSet呼び出すために、同じ値を入れる
        let state = self.buttonState
        self.buttonState = state;
        
        self.addTarget(self, action: #selector(self.changeButtonState), for: .touchUpInside)
    }
    
    @objc private func changeButtonState() {
        self.buttonState = !self.buttonState;
    }
}
