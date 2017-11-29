//
//  BalancesTableViewCell.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class BalancesTableViewCell: UITableViewCell {
    @IBOutlet weak var mainInitials: UILabel!
    @IBOutlet weak var mainName: UILabel!
    @IBOutlet weak var mainBalance: UILabel!
    @IBOutlet weak var userInitials: ParticipantView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
