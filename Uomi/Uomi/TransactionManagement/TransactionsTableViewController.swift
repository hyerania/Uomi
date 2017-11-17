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
        TransactionManager.sharedInstance.createTransaction(eventId: eventId!) { (transaction, error) in
            self.editingTransaction = transaction
            
            if let transaction = transaction {
                self.performSegue(withIdentifier: editTransactionSegue, sender: transaction)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: transactionCellReuseIdentifier, for: indexPath) as! TransactionTableViewCell

        cell.transaction = transactions[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     
        editingTransaction = transactions[indexPath.row]
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
            
            if let rootVc = nc.topViewController as? BalanceTableViewController {
                rootVc.eventId = self.eventId
            }
        }
        else if let vc = segue.destination as? TransactionViewController {
            vc.transaction = editingTransaction
        }
    }
    
    
    @IBAction func unwindToTransactions(segue: UIStoryboardSegue) { }
    
}
