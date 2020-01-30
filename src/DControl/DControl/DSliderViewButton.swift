//
//  DSliderViewButton.swift
//  DControl
//
//  Created by DIO on 2020/01/28.
//  Copyright © 2020 DIO. All rights reserved.
//

import UIKit

@objc public protocol DSliderViewButtonDelegate: class {
    // 右端でドラッグ終了
    func didDragEndRightEnd(sliderViewButton:DSliderViewButton);
}

@IBDesignable
public class DSliderViewButton: UIView {
    
    var sliderView: UIView = UIView()

    @IBInspectable public var sliderViewBackgroundColor:UIColor? {
        set {
            sliderView.backgroundColor = newValue;
        }
        get {
            return sliderView.backgroundColor
        }
    }
    
    @IBInspectable public var widthRatio: CGFloat = 5.0 {
        didSet {
            self.adjustSliderView()
        }
    }
    
    var message: UILabel = UILabel()
    @IBInspectable public var messageText:String? {
        didSet {
            self.message.text = messageText
        }
    }
    
    @IBInspectable public var cornerRadius:CGFloat = 10.0
    
    // delegate
    @IBOutlet public weak var delegate:DSliderViewButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.message.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.message.textAlignment = .center
        self.addSubview(self.message)
        
        self.adjustSliderView()
        self.sliderView.layer.cornerRadius = cornerRadius;
        self.layer.cornerRadius = cornerRadius;
        
        let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureSliderView(_:)))
        gesture.minimumNumberOfTouches = 1
        self.sliderView.addGestureRecognizer(gesture)
    }
    
    private func adjustSliderView() {
        self.sliderView.frame = CGRect(x: 0, y: 0, width: self.bounds.width / self.widthRatio, height: self.bounds.height)
        self.sliderView.removeFromSuperview()
        self.addSubview(self.sliderView)
    }
    
    private func fixSliderViewPositionIfOverSuperView() {
        if self.isSliderViewRightEnd() {
            self.sliderView.frame.origin = CGPoint(x: self.frame.size.width  - self.sliderView.frame.width, y: self.sliderView.frame.origin.y);
        } else if self.sliderView.frame.origin.x <= 0 {
            self.sliderView.frame.origin = CGPoint(x: 0, y: self.sliderView.frame.origin.y);
        }
    }
    
    private func resetStartStateIfNotRightEnd() -> Bool {
        if (self.isSliderViewRightEnd()) {
            return false;
        }
        
        self.resetSliderViewStartPosition();
        return true;
    }
    
    public func resetSliderViewStartPosition() {
        self.sliderView.frame.origin = CGPoint(x: 0, y: 0)
        let textCiColor:CIColor = CIColor(cgColor: self.message.textColor.cgColor)
        self.message.textColor = UIColor.init(red:textCiColor.red,
                                              green: textCiColor.green,
                                              blue: textCiColor.blue,
                                              alpha: 1.0)
    }
    
    private func isSliderViewRightEnd() -> Bool {
        return (self.sliderView.frame.origin.x + self.sliderView.frame.size.width) >= self.frame.size.width;
    }
    
    private func adjustMessageAlphaValue() {
        let rightEndX:CGFloat = self.frame.size.width - self.sliderView.frame.size.width;
        // 進んだ割合
        let moveOnRatio:CGFloat = self.sliderView.frame.origin.x / rightEndX
        let textCiColor:CIColor = CIColor(cgColor: self.message.textColor.cgColor)
        self.message.textColor = UIColor.init(red:textCiColor.red ,
                                              green: textCiColor.green,
                                              blue: textCiColor.blue,
                                              alpha: 1.0 - moveOnRatio)
    }
    
    @IBAction func panGestureSliderView(_ sender: UIPanGestureRecognizer) {
        let move:CGPoint = sender.translation(in: self)
        
        sender.view!.center.x += move.x
        
        sender.setTranslation(CGPoint.zero, in:self)
        
        self.fixSliderViewPositionIfOverSuperView()
        
        
        switch sender.state {
        case UIGestureRecognizer.State.ended:
            if !self.resetStartStateIfNotRightEnd() {
                if let delegate = self.delegate {
                    delegate.didDragEndRightEnd(sliderViewButton: self)
                    return;
                }
            }
            break;
        case UIGestureRecognizer.State.failed:
            _ = self.resetStartStateIfNotRightEnd()
            break;
        case UIGestureRecognizer.State.cancelled:
            _ = self.resetStartStateIfNotRightEnd()
            break;
        default:
            break;
        }
        
        self.adjustMessageAlphaValue()
        
    }
    
}
