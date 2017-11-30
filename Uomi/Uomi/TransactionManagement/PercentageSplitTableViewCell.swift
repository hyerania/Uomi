//
//  PercentageSplitTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class PercentageSplitTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var participantView: ParticipantView!
    @IBOutlet weak var percentField: UITextField!
    @IBOutlet weak var percentStepper: UIStepper!
    @IBOutlet weak var totalLabel: UILabel!
    
    fileprivate func updateSubtotal() {
        let subtotal = Float(contribution.transaction.total * contribution.getPercent()) / 10000
        
        totalLabel.text = UomiFormatters.dollarFormatter.string(for: subtotal)
    }
    
    var contribution: PercentContribution! {
        didSet {
            participantView.memberId = contribution.member
            
            let percent = contribution.getPercent()
            percentField.text = "\(percent)"
            percentStepper.value = Double(percent)
            updateSubtotal()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 21))
        label.text = "%"
        label.textColor = UIColor.gray
        
        percentField.rightView = label
        percentField.rightViewMode = .always
        percentField.delegate = self
        
        percentField.addTarget(self, action: #selector(updatePercentage), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func hitStepper(_ sender: UIStepper) {
        contentView.endEditing(false)
        
        let stepperValue = Int(sender.value)
        PercentContributionHelper.updatePercent(contribution: contribution, amount: stepperValue, lock: true)
        percentField.text = String(stepperValue)
        updateSubtotal()
    }
    
    @objc func updatePercentage() {
        var percent: Int
        if let percText = percentField.text, let perc = Int(percText) {
            percent = perc
        }
        else {
            percent = 0
        }
        
        PercentContributionHelper.updatePercent(contribution: contribution, amount: percent, lock: true)
        percentStepper.value = Double(percent)
        updateSubtotal()
    }
    
    
    // MARK: - Text Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
}
