//
//  LineItemSplitTableViewCell.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class LineItemSplitTableViewCell: UITableViewCell {
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
    }
    
    func updateUI() {
        print("updating UI...")
    }

}
