//
//  LineItemSplitTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class LineItemSplitTableViewCell: UITableViewCell, ParticipantViewDelegate {
    @IBOutlet weak var participantView: ParticipantView!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    var contribution: LineItemContribution? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        participantView.delegate = self
        descriptionField.addTarget(self, action: #selector(updatedDescription), for: .editingChanged)
    }
    
    @objc fileprivate func updatedDescription() {
        contribution?.description = descriptionField.text
        updateSubtotal()
    }
    
    fileprivate func updateSubtotal() {
        if let total = contribution?.getContributionAmount() {
            subtotalLabel.text = UomiFormatters.dollarFormatter.string(for: Float(total) / 100)
        }
        else {
            subtotalLabel.text = UomiFormatters.dollarFormatter.string(for: 0)
        }
    }
    
    func updateUI() {
        updateSubtotal()
        participantView.memberId = contribution?.member
        descriptionField.text = contribution?.description
    }

    
    // MARK: - Participant Delegatedelegate
    
    func participantSelected(participantView: ParticipantView, participant: User) {
        contribution?.member = participant.getUid()
    }
}
