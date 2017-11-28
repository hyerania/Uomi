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
        alert.addTextField(configurationHandler: textFieldHandler)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log", style: .default, handler: { [weak alert] (_) in
            
            guard let textField = alert?.textFields?[0] else {
                return
            }
            
            var value = textField.text!
            
            let amount = UomiFormatters.dollarFormatter.number(from: value)
            
            if let amount = amount {
                let newSettleTrans = SettlementTransaction()
                AccountManager.sharedInstance.getCurrentUser() { (currentUser) in
                    guard let currentUser = currentUser else {
                        return
                    }
                    newSettleTrans.payer = currentUser.getUid()
                    newSettleTrans.recipient = self.userCellData!.getUid()
                    newSettleTrans.total = Int(round(amount.floatValue * 100))
                    TransactionManager.sharedInstance.saveTransaction(event: self.userCellData!.getEventuid(), transaction: newSettleTrans) { (result) in
                        
                        print(result)
                    }
                }
//                newSettleTrans.payer = self.userCellData.
//                newSettleTrans.recipient
//                newSettleTrans.total = Int(round(amount.floatValue * 100))
//
//                TransactionManager.sharedInstance.saveTransaction(event: self.userCellData!.getUid(), transaction: newSettleTrans) { (result) in
//
//                    print(result)
//                }
//                print(newSettleTrans.total)
            }
            
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldHandler(textField: UITextField!)
    {
        if (textField) != nil {
            
            guard let balance = userCellData?.getBalance() else {
                textField.text = UomiFormatters.dollarFormatter.string(for: 0.00)
                return
            }
            
            if (balance < 0.00) {
                textField.text = UomiFormatters.dollarFormatter.string(for: balance * -1)
            } else {
                textField.text = UomiFormatters.dollarFormatter.string(for: balance)
            }
        }
    }
    
    

}
