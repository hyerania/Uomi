//
//  SettleTableViewCell.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class SettleTableViewCell: UITableViewCell {
    @IBOutlet weak var mainTransactionName: UILabel!
    @IBOutlet weak var mainTransactionDate: UILabel!
    @IBOutlet weak var mainUserInitials: ParticipantView!
    @IBOutlet weak var mainTotalBalance: UILabel!
    @IBOutlet weak var mainBalance: UILabel!
    @IBOutlet weak var mainTypeTrans: UILabel!
    
    var payerId: String! {
        didSet {
            mainUserInitials.memberId = payerId
        }
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
