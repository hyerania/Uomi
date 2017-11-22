//
//  TransactionTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/16/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class EventTransactionTableViewCell: UITableViewCell {
    
    static let dateFormatter = getDateFormatter()
    static let dollarFormatter = getDollarFormatter()

    static func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter
    }
    
    static func getDollarFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    
//    static let formatters = Formatters()

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var participantView: ParticipantView!
    @IBOutlet weak var totalView: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var transaction: EventTransaction! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        descriptionLabel.text = transaction.transDescription
        dateLabel.text = EventTransactionTableViewCell.dateFormatter.string(for: transaction.date)
        totalView.text = EventTransactionTableViewCell.dollarFormatter.string(for: transaction.total)
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
