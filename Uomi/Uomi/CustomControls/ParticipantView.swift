//
//  ParticipantButton.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/12/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit
import McPicker

protocol ParticipantViewDelegate {
    func participantSelected(participant: User)
}

fileprivate let loadUserImageName = "loadUser"

@IBDesignable class ParticipantView: UIView {
    
    var viewController: UIViewController? {
        didSet {
            participantButton.isEnabled = true
        }
    }
    var delegate: ParticipantViewDelegate?
    
    var view: UIView!
    private var member: User? {
        didSet {
            if let member = member {
                participantButton.setTitle(initials(for: member), for: .normal)
                participantButton.setImage(nil, for: .normal)
            }
            else {
                participantButton.setTitle(nil, for: .normal)
                participantButton.setImage(UIImage(named: loadUserImageName), for: .normal)
            }
            
        }
    }
    var memberId: String? { didSet {
        if let memberId = memberId {
            AccountManager.sharedInstance.load(id: memberId) { (user) in
                self.member = user
            }
        }
        else {
            self.member = nil
        }
        }
    }
    private var participants: [User]?

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
        
//        participantButton.layer.backgroundColor = UIColor(red: 0, green: 0.478, blue: 1.0, alpha: 1.0).cgColor
        participantButton.titleLabel?.adjustsFontSizeToFitWidth = true
        participantButton.addTarget(self, action: #selector(selectMember), for: .touchUpInside)
        participantButton.isEnabled = false
        
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
        
        participantButton.layer.cornerRadius = participantButton.bounds.width / 8
    }

    fileprivate func initials(for user: User) -> String {
        let components = user.getName().split(separator: Character.init(" "))

        // Is there a better way to internationalize names? Sure. Should it try to figure out the necessary degree of uniqueness to display? Of course. Have fun!
        var initials: String
        if components.count > 1, let firstInitial = components.first?.prefix(1), let lastInitial = components.last?.prefix(1) {
            initials = "\(firstInitial)\(lastInitial)"
        }
        else {
            initials = String(components.first!.prefix(1))
        }
        
        return initials
    }
    
    
    // MARK: Member selection
    
    fileprivate func displayPicker() {
        // TODO Display user selector
        if let viewController = viewController, let participants = participants {
            let data: [[String]] = [participants.map({ (user) -> String in
                user.getName()
            })]
            McPicker.showAsPopover(data: data, fromViewController: viewController, sourceView: participantButton) { (selections: [Int : String]) -> Void in
                if let name = selections[0], let index = participants.index(where: { (user) -> Bool in
                    user.getName() == name
                }) {
                    let user: User = participants[index]
                    self.memberId = user.getUid()
                    self.delegate?.participantSelected(participant: user)
                }
            }
        }
    }
    
    @objc func selectMember() {
        if participants == nil {
            if let activeEvent = EventManager.sharedInstance.getActiveEvent() {
                AccountManager.sharedInstance.getUsers(event: activeEvent) { (users) in
                    self.participants = users
                    self.displayPicker()
                }
            }
        }
        else {
            displayPicker()
        }
    }
}
