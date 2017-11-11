//
//  PercentageSplitTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class PercentageSplitTableViewCell: UITableViewCell {
    @IBOutlet weak var payerLabel: UIButton!
    @IBOutlet weak var percentField: UITextField!
    @IBOutlet weak var percentStepper: UIStepper!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
