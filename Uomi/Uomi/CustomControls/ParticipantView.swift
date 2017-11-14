//
//  ParticipantButton.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/12/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

@IBDesignable class ParticipantView: UIView {
    
    var view: UIView!

    @IBOutlet fileprivate weak var participantButton: UIButton!
    
    
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
        
        participantButton.layer.backgroundColor = UIColor(red: 0, green: 0.478, blue: 1.0, alpha: 1.0).cgColor
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ParticipantView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        participantButton.layer.cornerRadius = participantButton.bounds.width / 2
    }

}
