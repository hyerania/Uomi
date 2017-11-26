//
//  PercentageSplitTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class PercentageSplitTableViewCell: UITableViewCell {
    @IBOutlet weak var participantView: ParticipantView!
    @IBOutlet weak var percentField: UITextField!
    @IBOutlet weak var percentStepper: UIStepper!
    @IBOutlet weak var totalLabel: UILabel!
    
    var contribution: PercentContribution! {
        didSet {
            percentField.text = "\(contribution.percent)"
            let subtotal = Float(contribution.transaction.total * contribution.percent) / 10000
            
            totalLabel.text = UomiFormatters.dollarFormatter.string(for: subtotal)
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
