//
//  ImbalanceView.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/28/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

@IBDesignable class ImbalanceView: UIView {
    var view: UIView!

    @IBOutlet weak var oweLabel: UILabel!
    @IBOutlet weak var owedLabel: UILabel!
    
    var iOweAmount: Int! {
        didSet {
            let amountString =  UomiFormatters.wholeDollarFormatter.string(for: theyOweAmount)!
            
            if theyOweAmount > 0 {
                oweLabel.text = "~ \(amountString)"
            }
            else {
                oweLabel.text = amountString
            }
        }
    }
    var theyOweAmount: Int! {
        didSet {
            let amountString =  UomiFormatters.wholeDollarFormatter.string(for: theyOweAmount)!
            
            if theyOweAmount > 0 {
                owedLabel.text = "~ \(amountString)"
            }
            else {
                owedLabel.text = amountString
            }
        }
    }
    

    /// MARK: Things for IB
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
        let nib = UINib(nibName: "ImbalanceView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
