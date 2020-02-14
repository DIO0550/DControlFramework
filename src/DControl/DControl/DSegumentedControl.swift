//
//  DSegumentedControl.swift
//  DControl
//
//  Created by DIO on 2019/11/26.
//  Copyright © 2019 DIO. All rights reserved.
//

import UIKit

fileprivate let DSegumentedControlCornerRadius: CGFloat = 5.0

fileprivate enum SegmentedPosition: Int {
    case First
    case Last
    case FirstAndLast
    case Other
}

@objc public protocol DSegumentedControlDelegate: class {
    func didChangeSelectSegmented(index: Int, title: String?);
}

@IBDesignable
public class DSegumentedControl: UIView {
    
    @IBOutlet public weak var delegate: DSegumentedControlDelegate? = nil
    
    /// segmentの数
    @IBInspectable public var numberOfSegment: Int {
        get {
            return self.innerViews.count
        }
        set {
            if self.innerViews.count == newValue { return }
            let diff = newValue - self.innerViews.count
            for _ in 0...abs(diff) {
                if diff < 0 {
                    self.removeSegment(at: self.innerViews.count, animated: true)
                } else {
                    self.insertSegment(withTitle: nil, at: self.innerViews.count, animated: true)
                }
            }
        }
    }
    
    /// 選択中のindex
    @IBInspectable public var selectedSegmentIndex: Int {
        get {
            if self.innerViews.count == 0 { return -1 }
            var selectIndex = -1
            for (index, innerView) in self.innerViews.enumerated() {
                if !innerView.isSelected {
                    continue
                }
                selectIndex = index
            }
            return selectIndex
        }
        set {
            if newValue < 0 || self.innerViews.count <= newValue { return }
            self.deselectAll()
            let innerView = self.innerViews[newValue]
            innerView.isSelected = true
        }
    }
    
    public enum SegmentedDirection : Int {
        case Horizontal
        case Vertical
    }
    var segmentDirection: SegmentedDirection = .Horizontal
    @IBInspectable var direction: Int {
        get {
            return self.segmentDirection.rawValue
        }
        set {
            self.segmentDirection = SegmentedDirection(rawValue: newValue) ?? .Horizontal
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }
    
    /// 内部ビューの色
    @IBInspectable var innerBgColor: UIColor? = nil
    @IBInspectable var innerTextColor: UIColor? = nil
    @IBInspectable var innerSelectBgColor: UIColor? = nil
    @IBInspectable var innerSelectTextColor: UIColor? = nil
    @IBInspectable var innerBorderColor: UIColor? = nil
    @IBInspectable var innerSelectBorderColor: UIColor? = nil
    
    /// 中のView
    private var innerViews: Array<DSegumentedControlInnerView> = []

    /// 指定位置のsegmentを削除する
    /// - Parameters:
    ///   - segment: 位置
    ///   - animated: アニメーションの有無
    public func removeSegment(at segment: Int, animated: Bool) {
        if segment < 0 || self.numberOfSegment <= segment { return }
        let innerView = self.innerViews[segment]
        innerView.removeFromSuperview()
        self.innerViews.remove(at: segment)
        self.readjustmentInnerFrame()
        self.setNeedsDisplayInnerViews()
    }
    
    /// 指定位置にsegmentを追加する
    /// - Parameters:
    ///   - image: 画像
    ///   - segment: 位置
    ///   - animated: アニメーションの有無
    public func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) {
        // 範囲外
        if segment < 0 || self.numberOfSegment < segment {
            return
        }
        
        let frame = self.segmentRect(at: segment)
        let innerView = DSegumentedControlInnerView.init(with: image, frame: frame)
        innerView.delegate = self
        innerView.dataSource = self
        self.innerViews.insert(innerView, at: segment)
        self.addSubview(innerView)
        
        self.readjustmentInnerFrame()
        self.setNeedsDisplayInnerViews()
    }
    
    
    /// 指定位置にsegmentを追加する
    /// - Parameters:
    ///   - title: タイトル
    ///   - segment: 位置
    ///   - animated: アニメーションの有無
    public func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        // 範囲外
        if segment < 0 || self.numberOfSegment < segment {
            return
        }
        
        let frame = self.segmentRect(at: segment)
        
        let innerView = DSegumentedControlInnerView.init(with: title, frame: frame)
        innerView.delegate = self
        innerView.dataSource = self
        self.innerViews.insert(innerView, at: segment)
        self.addSubview(innerView)
        
        self.readjustmentInnerFrame()
        self.setNeedsDisplayInnerViews()
    }
    
    public func setText(withTitle title: String?, at segment: Int) {
        if segment < 0 || self.numberOfSegment <= segment {
            return
        }
        let innerView = self.innerViews[segment]
        innerView.title = title
    }
    
    private func segmentRect(at segment: Int) -> CGRect {
        let isHorizontal = self.segmentDirection == .Horizontal
        let divNumber = (self.numberOfSegment == 0) ? 1.0 : CGFloat(self.numberOfSegment)
        
        let width = isHorizontal ? self.bounds.size.width / divNumber : self.bounds.size.width
        let height = isHorizontal ? self.bounds.size.height : self.bounds.size.height / divNumber
        let posX = isHorizontal ? width * CGFloat(segment) : 0
        let posY = isHorizontal ? 0 : height * CGFloat(segment)
        
        return CGRect(x: posX, y: posY, width: width, height: height)
    }
    
    private func readjustmentInnerFrame() {
        for (index, subview) in self.subviews.enumerated() {
            let rect = self.segmentRect(at: index)
            subview.frame = rect
        }
    }
    
    private func setNeedsDisplayInnerViews() {
        for innerView in self.innerViews {
            innerView.setNeedsDisplay()
        }
    }
}

fileprivate protocol DSegumentedControlInnerViewDelegate: class {
    func didSelectDSegumentedControlInnerView(dsegumentedControlInnerView :DSegumentedControlInnerView)
}

fileprivate protocol DSegumentedControlInnerViewDataSource: class {
    func dsegmentedControlInnerViewBgColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewSelectBgColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewTextColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewSelectTextColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewBorderColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewSelectBorderColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor?
    func dsegmentedControlInnerViewPosition(dsegmentedControlInnerView: DSegumentedControlInnerView) -> SegmentedPosition
    func dsegmentedControlInnerViewMaxLength(dsegmentedControlInnerView: DSegumentedControlInnerView) -> Int
}

fileprivate class DSegumentedControlInnerView: UIView {
    
    
    /// 選択状態
    var isSelected:Bool = false
    /// イメージ
    var image: UIImage? = nil
    /// タイトル
    var title: String? = nil
    /// 選択中か
    var isSelect: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    weak var delegate: DSegumentedControlInnerViewDelegate? = nil
    weak var dataSource: DSegumentedControlInnerViewDataSource? = nil
    
    // 内部ビュー
    fileprivate var innerBgColor:UIColor? = nil;
    fileprivate var innerTextColor:UIColor? = nil;
    fileprivate var innerSelectBgColor:UIColor? = nil;
    fileprivate var innerSelectTextColor:UIColor? = nil;
    
    /**
     initializer
     
     @param image 描画するイメージ
     */
    init(with image: UIImage?, frame: CGRect) {
        super.init(frame: frame)
        self.image = image
        // clearにしないと、背景が黒くなる
        self.backgroundColor = .clear
    }
    /**
     initializer
     
     @param title 描画するタイトル
     */
    init(with title: String?, frame: CGRect) {
        super.init(frame: frame)
        self.title = title
        // clearにしないと、背景が黒くなる
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        self.drawBackground(rect)
        self.drawBorder(rect)
        self.drawImage(rect)
        self.drawTitle(rect)
    }
    
    private func drawBackground(_ rect: CGRect) {
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.saveGState()
        var byRoundingCorners: UIRectCorner = []
        let position = self.dataSource?.dsegmentedControlInnerViewPosition(dsegmentedControlInnerView: self) ?? .Other
        
        switch position {
        case .First:
            byRoundingCorners = [.topLeft, .bottomLeft]
        case .Last:
            byRoundingCorners = [.topRight, .bottomRight]
        case .FirstAndLast:
            byRoundingCorners = [.allCorners]
        case .Other:
            break
        }
        
        let bezierPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: DSegumentedControlCornerRadius, height: DSegumentedControlCornerRadius))
        
        var bgColor = self.dataSource?.dsegmentedControlInnerViewBgColor(dsegmentedControlInnerView: self) ?? UIColor.black
        if self.isSelected {
            bgColor = self.dataSource?.dsegmentedControlInnerViewSelectBgColor(dsegmentedControlInnerView: self) ?? UIColor.black
        }
        bgColor.setFill()
        bezierPath.fill()
        context?.restoreGState()
    }
    
    private func drawBorder(_ rect: CGRect) {
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.saveGState()
        var byRoundingCorners: UIRectCorner = []
        let position = self.dataSource?.dsegmentedControlInnerViewPosition(dsegmentedControlInnerView: self) ?? .Other
        
        switch position {
        case .First:
            byRoundingCorners = [.topLeft, .bottomLeft]
        case .Last:
            byRoundingCorners = [.topRight, .bottomRight]
        case .FirstAndLast:
            byRoundingCorners = [.allCorners]
        case .Other:
            break
        }
        
        let bezierPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: DSegumentedControlCornerRadius, height: DSegumentedControlCornerRadius))
        
        var borderColor = self.dataSource?.dsegmentedControlInnerViewBorderColor(dsegmentedControlInnerView: self) ?? UIColor.black
        if self.isSelected {
            borderColor = self.dataSource?.dsegmentedControlInnerViewSelectBorderColor(dsegmentedControlInnerView: self) ?? UIColor.black
        }
        borderColor.setStroke()
        bezierPath.stroke()
        context?.restoreGState()
    }
    
    private func drawTitle(_ rect: CGRect) {
        if self.title == nil || self.title?.count == 0 {
            return
        }
        
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let drawText = self.title! as NSString
        let titleLength: Int = self.title!.count
        let length: Int = self.dataSource?.dsegmentedControlInnerViewMaxLength(dsegmentedControlInnerView: self) ?? titleLength
        
        
        let fontSize: CGFloat = (length == 0) ? rect.size.width : rect.size.width / CGFloat(length)
        
        var textColor = self.dataSource?.dsegmentedControlInnerViewTextColor(dsegmentedControlInnerView: self) ?? UIColor.systemBlue
        if self.isSelected {
            textColor = self.dataSource?.dsegmentedControlInnerViewSelectTextColor(dsegmentedControlInnerView: self) ?? UIColor.white
        }
        // フォント属性
        let fontAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                        NSAttributedString.Key.foregroundColor: textColor]
        // サイズ取得
        let size = drawText.size(withAttributes: fontAttr)
        
        let x_pos = (rect.size.width - size.width) / 2
        let y_pos = (rect.size.height - size.height) / 2
        // テキスト描画
        drawText.draw(at: CGPoint(x: rect.origin.x + x_pos, y: rect.origin.y + y_pos), withAttributes: fontAttr)
        context?.restoreGState()
    }
    
    private func drawImage(_ rect: CGRect) {
        // TODO: draw image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.didSelectDSegumentedControlInnerView(dsegumentedControlInnerView: self)
    }
}

extension DSegumentedControl: DSegumentedControlInnerViewDataSource {
    fileprivate func dsegmentedControlInnerViewBgColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerBgColor
    }
    
    fileprivate func dsegmentedControlInnerViewSelectBgColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerSelectBgColor
    }
    
    fileprivate func dsegmentedControlInnerViewTextColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerTextColor
    }
    
    fileprivate func dsegmentedControlInnerViewSelectTextColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerSelectTextColor
    }
    
    fileprivate func dsegmentedControlInnerViewBorderColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerBorderColor
    }
    
    fileprivate func dsegmentedControlInnerViewSelectBorderColor(dsegmentedControlInnerView: DSegumentedControlInnerView) -> UIColor? {
        return self.innerSelectBorderColor
    }
    
    fileprivate func dsegmentedControlInnerViewPosition(dsegmentedControlInnerView: DSegumentedControlInnerView) -> SegmentedPosition {
        let isFirst = self.innerViews.first == dsegmentedControlInnerView
        let isLast = self.innerViews.last == dsegmentedControlInnerView
        if isFirst && isLast {
            return .FirstAndLast
        } else if isFirst {
            return .First
        } else if isLast {
            return .Last
        } else {
            return .Other
        }
    }
    
    fileprivate func dsegmentedControlInnerViewMaxLength(dsegmentedControlInnerView: DSegumentedControlInnerView) -> Int {
        var maxLength = 0
        for innerView in self.innerViews {
            if innerView.title == nil {
                continue
            }
            if maxLength >= innerView.title!.count {
                continue
            }
            maxLength = innerView.title!.count
        }
        
        return maxLength
    }
}

extension DSegumentedControl: DSegumentedControlInnerViewDelegate {
    fileprivate func didSelectDSegumentedControlInnerView(dsegumentedControlInnerView: DSegumentedControlInnerView) {
        self.deselectAll()
        for innerView in self.innerViews {
            if innerView != dsegumentedControlInnerView {
                continue
            }
            innerView.isSelected = true
            break
        }
        self.setNeedsDisplayInnerViews()
        let title = dsegumentedControlInnerView.title
        self.delegate?.didChangeSelectSegmented(index: self.selectedSegmentIndex, title: title)
    }
    
    fileprivate func deselectAll() {
        for innerView in self.innerViews {
            innerView.isSelected = false
        }
    }
    
}

