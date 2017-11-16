//
//  SettleTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class SettleViewController: UIViewController {
    @IBOutlet weak var InitialsText: UILabel!
    @IBOutlet weak var NameText: UILabel!
    @IBOutlet weak var PaymentText: UILabel!
//    var userCellData : cellData?
    var userCellData : Balance?
    
    @IBAction func btnPaySettle(_ sender: Any) {
        self.createAlert(title: "Pay back time!.", message: "Please click an option.")
        return
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userCellData = userCellData else {
            return
        }
//        self.NameText.text = userCellData.nameText
//        self.InitialsText.text = userCellData.initialsText
//        self.PaymentText.text = "You owe \(userCellData.balanceText!)"
        
        self.NameText.text = userCellData.getName()
        self.InitialsText.text = userCellData.getInitials()
        self.PaymentText.text = "You owe \(userCellData.getBalance())"
        self.title = "Settle"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
    // MARK: - Helper functions
    private func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
