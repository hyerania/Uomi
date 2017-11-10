//
//  LabeledTextView.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/9/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

@IBDesignable class LabeledTextView: UIView {

    var view: UIView!
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var textField: UITextField!
    
    @IBInspectable var title: String? {
        get {
            return titleLabel.text
        }
        set (title) {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return textField.placeholder
        }
        set (placeholder) {
            textField.placeholder = placeholder
        }
    }
    
    @IBInspectable var text: String? {
        get {
            return textField.text
        }
        set (text) {
            textField.text = text
        }
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LabeledTextView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    // MARK: - Intrinsic Size
    
    override var intrinsicContentSize: CGSize {
        get {
            var minX = CGFloat.greatestFiniteMagnitude
            var maxX = CGFloat.leastNormalMagnitude
            var minY = CGFloat.greatestFiniteMagnitude
            var maxY = CGFloat.leastNormalMagnitude
            
            for subview in subviews {
                minX = min(minX, subview.center.x - (subview.bounds.width / 2))
                maxX = max(maxX, subview.center.x + (subview.bounds.width / 2))
                minY = min(minY, subview.center.y - (subview.bounds.height / 2))
                maxY = max(maxY, subview.center.y + (subview.bounds.height / 2))
            }
            
            if minX == CGFloat.greatestFiniteMagnitude { return super.intrinsicContentSize
            }
            
            return CGSize(width: maxX - minX, height: maxY - minY)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}
