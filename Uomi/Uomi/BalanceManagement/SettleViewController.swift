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
    @IBOutlet weak var btnPayment: UIButton!
    
    @IBAction func btnPayLog(_ sender: UIButton) {
        if(userCellData!.getBalance()>0.00){
            self.createLogAlert(title:"Log Payment", message: "Fill out amount of payment that will be logged.")
            return
        }
        else {
            self.createPayAlert(title:"Payment", message: "Please choose an option for payment.")
        }
        
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
        self.title = "Settle"
        
        if(userCellData.getBalance() == 0.00){
            self.btnPayment.isHidden = true
        }
        else if (userCellData.getBalance() > 0.00){
            let delimiter = " "
            var token = userCellData.getName().components(separatedBy: delimiter)
            let firstName = String(token[0])
            
            self.PaymentText.text = firstName + " owes " + UomiFormatters.dollarFormatter.string(for: userCellData.getBalance())!
            self.btnPayment.setTitle("Log Payment", for: .normal)
        }
        else{
            self.PaymentText.text = "You owe " + UomiFormatters.dollarFormatter.string(for: (userCellData.getBalance() * -1))!
            self.btnPayment.setTitle("Pay Back", for: .normal)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableViewData()
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
        
        let transaction = self.settleList[indexPath.row]
        TransactionManager.sharedInstance.loadTransaction(id: (userCellData?.getEventuid())!, id: transaction.getTransactionId()){ (singleTrans, error) in
            guard let singleTrans = singleTrans else {
                print("Error getting single transaction for Settle View.")
                return
            }
            
            tableCell.mainTransactionDate.text = UomiFormatters.dateFormatter.string(for: singleTrans.date)
            tableCell.mainTotalBalance.text = UomiFormatters.dollarFormatter.string(for:(singleTrans.total/100))
            if let expenseTrans = singleTrans as? ExpenseTransaction{
                tableCell.mainTransactionName.text = expenseTrans.transDescription
            }else{
                tableCell.mainTransactionName.text = "Payment"
            }

        }
        
        if(self.settleList[indexPath.row].getBalanceOweTo() > 0.00){
            tableCell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: (self.settleList[indexPath.row].getBalanceOweTo()/100))
            tableCell.mainTypeTrans.text = "TO"
        }
        else{
            tableCell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: (self.settleList[indexPath.row].getBalanceOweMe()/100))
            tableCell.mainTypeTrans.text = "ME"
        }
        
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    
    
    // MARK: - Helper functions
    private func reloadTableViewData(){
        AccountManager.sharedInstance.getCurrentUser(){ user in
            guard let user = user else{
                print("There is something wrong. User is supposed to be logged in.")
                return
            }
            let userId = user.getUid()
            
            guard let userCellData = self.userCellData else {
                return
            }
            
            BalanceManager.sharedInstance.loadSettleList(userId: userId, eventId: userCellData.getEventuid(), otherUserId: userCellData.getUid()){settles in
                self.settleList = settles
                self.settleTableView.reloadData()
            }
        }
    }
    private func createLogAlert(title: String, message: String) {
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
                        self.userCellData?.setBalance(newBalance: self.userCellData!.getBalance() - amount.doubleValue)
                        self.PaymentText.text = "You owe " + UomiFormatters.dollarFormatter.string(for: self.userCellData?.getBalance())!

                        print(result)
                    }
                }
            }
            self.reloadTableViewData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createPayAlert(title: String, message: String) {
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
                    newSettleTrans.payer = self.userCellData!.getUid()
                    newSettleTrans.recipient = currentUser.getUid()
                    newSettleTrans.total = Int(round(amount.floatValue * 100))
                    TransactionManager.sharedInstance.saveTransaction(event: self.userCellData!.getEventuid(), transaction: newSettleTrans) { (result) in
                        self.userCellData?.setBalance(newBalance: self.userCellData!.getBalance() - amount.doubleValue)
                        self.PaymentText.text = "You owe " + UomiFormatters.dollarFormatter.string(for: self.userCellData?.getBalance())!
                        
                        print(result)
                    }
                }
            }
            self.reloadTableViewData()
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
