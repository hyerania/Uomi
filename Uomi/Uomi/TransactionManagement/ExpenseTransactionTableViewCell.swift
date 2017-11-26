//
//  TransactionTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/16/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit


class ExpenseTransactionTableViewCell: UITableViewCell {
    
//    static let formatters = Formatters()

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var participantView: ParticipantView!
    @IBOutlet weak var totalView: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var transaction: ExpenseTransaction! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        descriptionLabel.text = transaction.transDescription
        dateLabel.text = UomiFormatters.dateFormatter.string(for: transaction.date)
        
        let displayAmount = Float(transaction.total) / 100.0
        
        totalView.text = displayAmount == round(displayAmount) ? UomiFormatters.wholeDollarFormatter.string(for: displayAmount) : UomiFormatters.dollarFormatter.string(for: displayAmount)
        
        // TODO add summary text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
