//
//  SlideViewButton.swift
//  DControl
//
//  Created by DIO on 2019/06/23.
//  Copyright © 2019 DIO. All rights reserved.
//

import UIKit

public protocol DSleepSliderViewButtonDelegate: class {
    // 右端でドラッグが終了したことを通知する。
    func didRightEndDragEnd(sliderViewButton:UIView);
}

@IBDesignable
public class SliderViewButton: UIView {
    
    let SliderViewButtonNibName:String = "SliderViewButton"

    // 背景色
    public var bgColor:UIColor? = UIColor.cyan
    // スライダーの背景色
    public var bgSliderViewColor:UIColor? = UIColor.red
    // ドラッグできるView
    @IBOutlet weak var sliderView: UIView!
    
    // Viewの中央に表示するラベル
    @IBOutlet weak var message: UILabel!
    
    
    // 角丸
    public var cornerRadius:CGFloat = 10.0
    // デリゲート
    public weak var delegate:DSleepSliderViewButtonDelegate?
    
    
    /// ボタンメッセージのセッター
    ///
    /// - Parameter messageText: 設定するボタンのメッセージ
    public func setMessageText(messageText:String?) {
        message.text = messageText;
    }
    
    
    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }
    
    // xibからカスタムViewを読み込んで準備する
    private func comminInit() {
        // MyCustomView.xib からカスタムViewをロードする
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: SliderViewButtonNibName, bundle: bundle)
        let view:UIView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.backgroundColor = UIColor.clear
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                      metrics:nil,
                                                                      views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                      metrics:nil,
                                                                      views: bindings))
        
        
    }
    
    
    /// nib読み込み時に呼ばれる
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = self.bgColor
        self.sliderView.backgroundColor = self.bgSliderViewColor
        
        self.sliderView.frame = CGRect(x: self.bounds.origin.x,
                                       y: self.bounds.origin.y,
                                       width: self.bounds.size.height,
                                       height: self.bounds.size.height)
        
        self.sliderView.layer.cornerRadius = cornerRadius;
        self.layer.cornerRadius = cornerRadius;
    }
    
    
    /// bgColorのセッター
    ///
    /// - Parameter value: 設定する値
    public func setBgColor(value:UIColor) {
        self.bgColor = value;
        self.backgroundColor = value
    }
    
    
    /// bgSliderViewColorのセッター
    ///
    /// - Parameter value: 設定する値
    public func setBgSliderViewColor(value:UIColor) {
        self.bgSliderViewColor = value
        self.sliderView.backgroundColor = value
    }
    
    
    /// cornerRadiuのセッター
    ///
    /// - Parameter value: 設定する値
    public func setCornerRadius(value:CGFloat) {
        self.cornerRadius = value;
        self.sliderView.layer.cornerRadius = cornerRadius;
        self.layer.cornerRadius = cornerRadius;
    }
    
    
    /// スライダーがはみ出さないように調整する
    private func fixSliderViewPositionIfOverSuperView() {
        if self.isSliderViewRightEnd() {
            self.sliderView.frame.origin = CGPoint(x: self.frame.size.width  - self.sliderView.frame.width, y: self.sliderView.frame.origin.y);
        } else if self.sliderView.frame.origin.x <= 0 {
             self.sliderView.frame.origin = CGPoint(x: 0, y: self.sliderView.frame.origin.y);
        }
    }
    
    
    
    /// 右端まで行っていない場合は、スタートの状態に戻す。リセットした場合は、trueを返す
    ///
    /// - Returns: リセットしたかどうか
    private func resetStartStateIfNotRightEnd() -> Bool {
        if (self.isSliderViewRightEnd()) {
            return false;
        }
        
        self.resetStartState();
        return true;
    }
    
    /// スタートの状態に戻す
    public func resetStartState() {
        self.sliderView.frame.origin = CGPoint(x: 0, y: 0)
        let textCiColor:CIColor = CIColor(cgColor: self.message.textColor.cgColor)
        self.message.textColor = UIColor.init(red:textCiColor.red ,
                                              green: textCiColor.green,
                                              blue: textCiColor.blue,
                                              alpha: 1.0)
    }
    
    /// スライダーが右端にあるかどうか
    ///
    /// - Returns: YES - 右端 / NO - 右端ではない
    private func isSliderViewRightEnd() -> Bool {
        return (self.sliderView.frame.origin.x + self.sliderView.frame.size.width) >= self.frame.size.width;
    }
    
    
    
    /// スライダの移動距離でメッセージのAlpha値を変える
    private func changeMessageTextAlphaValueBySliderMoveUp() {
        let rightEndX:CGFloat = self.frame.size.width - self.sliderView.frame.size.width;
        // 進んだ割合
        let moveOnRatio:CGFloat = self.sliderView.frame.origin.x / rightEndX
        let textCiColor:CIColor = CIColor(cgColor: self.message.textColor.cgColor)
        self.message.textColor = UIColor.init(red:textCiColor.red ,
                                              green: textCiColor.green,
                                              blue: textCiColor.blue,
                                              alpha: 1.0 - moveOnRatio)
    }
  
    
    /// SliderViewをドラッグしたらよ場合に呼ばれる
    @IBAction func panGestureSliderView(_ sender: UIPanGestureRecognizer) {
        
        //移動量を取得する。
        let move:CGPoint = sender.translation(in: self)
        
        //ドラッグした部品の座標に移動量を加算する。
        sender.view!.center.x += move.x
        
        //移動量を0にする。
        sender.setTranslation(CGPoint.zero, in:self)
        
        // スライダー調整
        self.fixSliderViewPositionIfOverSuperView()
        
        
        switch sender.state {
            case UIGestureRecognizer.State.ended:
                if !self.resetStartStateIfNotRightEnd() {
                    if let delegate = self.delegate {
                        delegate.didRightEndDragEnd(sliderViewButton: self)
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
                // 終了、キャンセル、失敗以外は何もしない。
                break;
        }
       
        
        NSLog("%f", sender.view!.center.x)
        
        
        // 文字のAlpha値調整
        self.changeMessageTextAlphaValueBySliderMoveUp()
        
    }
    
}
