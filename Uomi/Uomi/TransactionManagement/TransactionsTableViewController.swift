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

class TransactionsTableViewController: UITableViewController {

    var eventId: String?
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
        let transaction = EventTransaction()
        
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
        
        if let transaction = transactions[indexPath.row] as? EventTransaction {
        
            let eventCell = tableView.dequeueReusableCell(withIdentifier: transactionCellReuseIdentifier, for: indexPath) as! EventTransactionTableViewCell

            eventCell.transaction = transaction
            
            cell = eventCell
        }
        else if let transaction = transactions[indexPath.row] as? SettlementTransaction {
            // FIXME Add cell for settlement transaction
            let settleCell = tableView.dequeueReusableCell(withIdentifier: transactionCellReuseIdentifier, for: indexPath) as! EventTransactionTableViewCell
                
            settleCell.transaction = transaction as! EventTransaction
            
            cell = settleCell
        }
        else {
            print("Problem parsing transaction type, could not generate proper cell type")
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingTransaction = transactions[indexPath.row]
        performSegue(withIdentifier: editTransactionSegue, sender: nil)
    }
    
    
    // MARK: Table View Delegate

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventEditorViewController {
            vc.eventId = self.eventId
        }
        else if let nc = segue.destination as? UINavigationController {
            if segue.identifier == viewBalancesSegue, let rootVc = nc.topViewController as? BalanceTableViewController {
                rootVc.eventId = self.eventId
            }
            else if let vc = nc.viewControllers.first as? TransactionViewController {
                vc.transaction = editingTransaction as! EventTransaction
            }
        }
    }
    
    
    @IBAction func unwindToTransactions(segue: UIStoryboardSegue) { }
    
}
