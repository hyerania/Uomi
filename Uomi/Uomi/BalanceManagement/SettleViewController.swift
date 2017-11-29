//
//  SettleTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class SettleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var InitialsText: UILabel!
    @IBOutlet weak var NameText: UILabel!
    @IBOutlet weak var PaymentText: UILabel!
    @IBOutlet weak var settleTableView: UITableView!
    //    var userCellData : cellData?
    var userCellData : Balance?
    private var settleList = [Settle]()
    private var transactionList = [Transaction]() //Transaction lists for this one event
    
    @IBAction func btnPaySettle(_ sender: Any) {
        self.createAlert(title: "Pay back time!.", message: "Please click an option.")
        return
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settleTableView.dataSource = self
        self.settleTableView.delegate = self
        
        guard let userCellData = userCellData else {
            return
        }
        
        self.NameText.text = userCellData.getName()
        self.InitialsText.text = userCellData.getInitials()
        self.PaymentText.text = "You owe " + UomiFormatters.dollarFormatter.string(for: userCellData.getBalance())!
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = Bundle.main.loadNibNamed("SettleTableViewCell", owner: self, options: nil)?.first as! SettleTableViewCell
        
        tableCell.mainTransactionName.text = self.settleList[indexPath.row].getTransactionName()
        tableCell.mainTransactionDate.text = UomiFormatters.dateFormatter.string(for: self.settleList[indexPath.row].getTransactionDate())
        tableCell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: self.settleList[indexPath.row].getTransactionTotal())
        tableCell.mainTypeTrans.text = "FIX :)"
        
        return tableCell
    }
    
    
    
    
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
