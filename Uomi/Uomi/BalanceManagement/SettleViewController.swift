//
//  SettleTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

let settleCellReuseIdentifier = "settleTableViewCell"
class SettleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var NameText: UILabel!
    @IBOutlet weak var PaymentText: UILabel!
    @IBOutlet weak var settleTableView: UITableView!
    @IBOutlet weak var Initials: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    //    var userCellData : cellData?
    var userCellData : Balance?
    private var settleList = [Settle]()
    private var transactionList = [Transaction]() //Transaction lists for this one event
   
    
    @IBAction func btnPayLog(_ sender: UIButton) {
        if(userCellData!.getBalance() > 0){
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
        self.title = "Settle"
        
        self.btnPayment.layer.cornerRadius = 10.00
        self.Initials.layer.cornerRadius = 10.00
        self.Initials.setTitle(userCellData.getInitials(), for:.normal)
        
        self.setLabelInformation()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func setLabelInformation() {
        guard let userCellData = self.userCellData else {
            return
        }
        if (userCellData.getBalance() > 0){
            let delimiter = " "
            var token = userCellData.getName().components(separatedBy: delimiter)
            let firstName = String(token[0])
            
            self.PaymentText.text = firstName + " owes " + UomiFormatters.dollarFormatter.string(for: userCellData.getBalance())!
            self.PaymentText.textColor = .orange
            self.btnPayment.setTitle("Log Payment", for: .normal)
        }
        else if (userCellData.getBalance() < 0){
            self.PaymentText.text = "You owe " + UomiFormatters.dollarFormatter.string(for: (userCellData.getBalance() * -1))!
            self.PaymentText.textColor = .red
            self.btnPayment.setTitle("Pay Back", for: .normal)
        }
        else{
            self.btnPayment.isHidden = true
            self.PaymentText.text = "No payments"
            self.PaymentText.textColor = UIColor.init(red: 51/255, green: 136/255, blue: 67/255, alpha : 1)
            
        }
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
        let tableCell = tableView.dequeueReusableCell(withIdentifier: settleCellReuseIdentifier) as! SettleTableViewCell
        
        
        let transaction = self.settleList[indexPath.row]
        tableCell.mainTransactionDate.text = UomiFormatters.dateFormatter.string(for: transaction.getDate())
        tableCell.mainTotalBalance.text = UomiFormatters.dollarFormatter.string(for: transaction.getTotal()/100)
        if (self.settleList[indexPath.row].getBalanceOweTo() > 0){
            tableCell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: (self.settleList[indexPath.row].getBalanceOweTo()/100))
            tableCell.mainTypeTrans.text = "IOU"
        }
        else if (self.settleList[indexPath.row].getBalanceOweMe() > 0){
            tableCell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: (self.settleList[indexPath.row].getBalanceOweMe()/100))
            tableCell.mainTypeTrans.text = "UOMi"
        }
        if (transaction.getIsSettle()) {
            tableCell.mainTransactionName.text = "Payment"
            tableCell.mainTypeTrans.text = "Paid"
            
        } else {
            tableCell.mainTransactionName.text = transaction.getDescription()
            
        }
        
        tableCell.payerId = transaction.getPayerId()
        
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
        if(userCellData!.getBalance() == 0){
            self.btnPayment.isHidden = true
        }
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
                var joinedSettlesTransaction = [Settle]()
                var count = 0
                for settlement in settles {
                    TransactionManager.sharedInstance.loadTransaction(id: (self.userCellData?.getEventuid())!, id: settlement.getTransactionId()) { (transaction, error) in
                        guard let transaction = transaction else {
                            return
                        }
                        settlement.setPayerId(payerId: transaction.payer)
                        settlement.setDate(date: transaction.date)
                        settlement.setTotal(total: transaction.total)
                        if let expenseTrans = transaction as? ExpenseTransaction{
                            settlement.setIsSettle(isSettle: false)
                            settlement.setDescription(description: expenseTrans.transDescription!)
                        }else{
                            settlement.setIsSettle(isSettle: true)
                        }
                        count += 1
                        joinedSettlesTransaction.append(settlement)
                        if (count == settles.count) {
                            self.settleList = joinedSettlesTransaction.sorted(by: {$0.getDate() > $1.getDate()})
                            self.settleTableView.reloadData()
                        }
                    }
                }
                
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
                    newSettleTrans.payer = self.userCellData!.getUid()
                    newSettleTrans.recipient = currentUser.getUid()
                    newSettleTrans.total = Int(round(amount.floatValue * 100))
                    TransactionManager.sharedInstance.saveTransaction(event: self.userCellData!.getEventuid(), transaction: newSettleTrans) { (result) in
                        self.setLabelInformation()

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
                    newSettleTrans.payer = currentUser.getUid()
                    newSettleTrans.recipient = self.userCellData!.getUid()
                    newSettleTrans.total = Int(round(amount.floatValue * 100))
                    TransactionManager.sharedInstance.saveTransaction(event: self.userCellData!.getEventuid(), transaction: newSettleTrans) { (result) in
                        self.setLabelInformation()
                        
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
            
            if (balance < 0) {
                textField.text = UomiFormatters.dollarFormatter.string(for: balance * -1)
            } else {
                textField.text = UomiFormatters.dollarFormatter.string(for: balance)
            }
        }
    }

}

//extension SettleViewController: ParticipantViewDelegate {
//
//    func participantSelected(participantView: ParticipantView, participant: User) {
//        transaction.payer = participant.getUid()
//
//        updateSaveState()
//    }
//
//}

