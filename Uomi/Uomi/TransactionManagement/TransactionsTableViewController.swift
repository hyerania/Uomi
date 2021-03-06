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
fileprivate let settlementCellReuseIdentifier = "settlementCell"

let viewBalancesSegue = "viewBalances"

class TransactionsTableViewController: UITableViewController, ExpenseTransactionDelegate {

    var eventId: String!
    var accountId: String!
    var editingTransaction: Transaction!
    
    private var transactions: [Transaction] = []
    @IBOutlet weak var imbalanceView: ImbalanceView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        self.calculateImbalanceView()
    }
    
    @objc public func refresh(refreshControl: UIRefreshControl) {
        self.reloadTableViewData(refreshControl: refreshControl)
        // Code to refresh table view
    }
    
    private func reloadTableViewData(refreshControl: UIRefreshControl?) {
        EventManager.sharedInstance.loadEvent(id: eventId) { (event) in
            self.title = event?.getName()
        }
        self.calculateImbalanceView()
        TransactionManager.sharedInstance.loadTransactions(eventId: eventId, completion: { (transactions) in
            guard let transactions = transactions else {
                self.performSegue(withIdentifier: unwindSegue, sender: self)
                return
            }
            
            self.transactions = transactions.sorted(by: {$0.date > $1.date})
            self.tableView.reloadData()
            refreshControl?.endRefreshing()
        })
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
        
            self.transactions = transactions.sorted(by: {$0.date > $1.date})
            self.calculateImbalanceView()
            self.tableView.reloadData()
        })
    }

    func calculateImbalanceView() {
        BalanceManager.sharedInstance.getOwingBalances(user: accountId, event: self.eventId) { (iOwe, theyOwe) in
                self.imbalanceView.iOweAmount = iOwe
                self.imbalanceView.theyOweAmount = theyOwe
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hitAdd(_ sender: Any) {
        let transaction = ExpenseTransaction()
        
        transaction.payer = accountId
        self.editingTransaction = transaction
        self.performSegue(withIdentifier: editTransactionSegue, sender: transaction)
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
            let settleCell = tableView.dequeueReusableCell(withIdentifier: settlementCellReuseIdentifier, for: indexPath) as! SettlementTransactionTableViewCell
                
            settleCell.transaction = transaction
            settleCell.selectionStyle = UITableViewCellSelectionStyle.none

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
        guard let transaction = transactions[indexPath.row] as? ExpenseTransaction else {
            return
        }
        
        editingTransaction = transaction
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
                rootVc.accountId = self.accountId
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
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                // TODO Alert user of failure
            }
        }
    }
    
}
