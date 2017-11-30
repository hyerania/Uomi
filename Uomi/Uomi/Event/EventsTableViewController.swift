//
//  EventsTableViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 10/31/17.
//  Copyright © 2017 Team Uomi. All rights reserved.
//

import UIKit

fileprivate let newEventSegue = "newEvent"

class EventsTableViewController: UITableViewController {

    var accountId: String!
    private var eventsList = [Event]()
    private var selectedRow = 0

    // MARK: - View Controller Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc public func refresh(refreshControl: UIRefreshControl) {
        print("refresh")
        self.reloadTableViewData(refreshControl: refreshControl)
        // Code to refresh table view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableViewData(refreshControl: nil)
        
        EventManager.sharedInstance.setActiveEvent(eventId: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.eventsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        cell.nameLabel.text = self.eventsList[indexPath.row].getName()
        cell.timeLabel.text = UomiFormatters.dateFormatter.string(from: self.eventsList[indexPath.row].getDate())
        cell.descriptionLabel.text = self.eventsList[indexPath.row].getDescription()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "toTransactions", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    // MARK: - Helper Functions
    private func reloadTableViewData(refreshControl: UIRefreshControl?) {
        guard let accountId = accountId else {
            return
        }
        EventManager.sharedInstance.loadEvents(userId: accountId) { events in
            guard events.count > 0 else {
                return
            }
            self.eventsList = events.sorted( by: {$0.getDate() > $1.getDate() })
            //                images.sorted({ $0.fileID > $1.fileID })
            //                self.eventsList = events.sorted( {$0.})
            self.tableView.reloadData()
            
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == newEventSegue {
            // TODO Predefine owner and initial participant
        }
        else if let vc = segue.destination as? TransactionsTableViewController {
            let eventId: String = self.eventsList[self.selectedRow].getUid()
            vc.eventId = eventId
            vc.accountId = accountId
            EventManager.sharedInstance.setActiveEvent(eventId: eventId)
        }
    }
    
    @IBAction func signout(_ sender: UIBarButtonItem) {
        AccountManager.sharedInstance.logout() { (result) in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToEventsFromCancel(segue: UIStoryboardSegue) { }
    
    @IBAction func unwindToEventsFromCreate(segue: UIStoryboardSegue) {
        // TODO: Save new event
        
        // TODO: Add event row
        
        // TODO: Segue to the new event's transactions
    }
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
    }
}
