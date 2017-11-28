//
//  TransactionsTableViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 10/31/17.
//  Copyright © 2017 Team Uomi. All rights reserved.
//

import UIKit

fileprivate let unwindSegue = "goBackButton"
fileprivate let editTransactionSegue = "editTransaction"
fileprivate let transactionCellReuseIdentifier = "transactionCell"

let viewBalancesSegue = "viewBalances"

class TransactionsTableViewController: UITableViewController, ExpenseTransactionDelegate {

    var eventId: String!
    var editingTransaction: Transaction!
    
    private var transactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = event.getName()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let eventId = eventId else {
            return
        }
        
        EventManager.sharedInstance.loadEvent(id: eventId) { (event) in
            self.title = event?.getName()
        }
        TransactionManager.sharedInstance.loadTransactions(eventId: eventId, completion: { (transactions) in
            guard let transactions = transactions else {
                self.performSegue(withIdentifier: unwindSegue, sender: self)
                return
            }
            
            self.transactions.removeAll()
            self.transactions.append(contentsOf: transactions)
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hitAdd(_ sender: Any) {
        let transaction = ExpenseTransaction()
        AccountManager.sharedInstance.getCurrentUser(completionHandler: { (user) in
            if let user = user {
                transaction.payer = user.getUid()
                
                AccountManager.sharedInstance.getUserIds(event: self.eventId) { (userIds) in
                    let percentage = 100 / userIds.count
                    for userId in userIds {
                        let contrib = PercentContribution(transaction: transaction)
                        contrib.member = userId
                        contrib.percent = percentage
                        
                        transaction.percentContributions.append(contrib)
                    }
                    
                    self.editingTransaction = transaction
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: editTransactionSegue, sender: transaction)
                    }
                }
            }
            else {
                // They shouldn't be here! They aren't logged in!
            }
        })
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if let transaction = transactions[indexPath.row] as? ExpenseTransaction {
        
            let eventCell = tableView.dequeueReusableCell(withIdentifier: transactionCellReuseIdentifier, for: indexPath) as! ExpenseTransactionTableViewCell

            eventCell.transaction = transaction
            
            cell = eventCell
        }
        else if let transaction = transactions[indexPath.row] as? SettlementTransaction {
            // FIXME Add cell for settlement transaction
            let settleCell = tableView.dequeueReusableCell(withIdentifier: transactionCellReuseIdentifier, for: indexPath) as! ExpenseTransactionTableViewCell
                
            settleCell.transaction = transaction as! ExpenseTransaction
            
            cell = settleCell
        }
        else {
            print("Problem parsing transaction type, could not generate proper cell type")
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingTransaction = transactions[indexPath.row]
        performSegue(withIdentifier: editTransactionSegue, sender: nil)
    }

   

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventEditorViewController {
            vc.eventId = self.eventId
        }
        else if let nc = segue.destination as? UINavigationController {
            if segue.identifier == viewBalancesSegue, let rootVc = nc.topViewController as? BalanceTableViewController {
                rootVc.eventId = self.eventId
            }
            else if let vc = nc.viewControllers.first as? ExpenseTransactionViewController {
                vc.transaction = editingTransaction as! ExpenseTransaction
                vc.delegate = self
            }
        }
    }
    
    
    // MARK: - Expense Delegate
    
    func shouldCancel(expenseController controller: ExpenseTransactionViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func shouldSave(expenseController controller: ExpenseTransactionViewController, transaction: Transaction) {
        TransactionManager.sharedInstance.saveTransaction(event: eventId, transaction: transaction) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                // TODO Alert user of failure
            }
        }
    }
    
}
