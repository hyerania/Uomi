//
//  EventTableViewCell.swift
//  Uomi
//
//  Created by Kevin J Nguyen on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var debtLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
