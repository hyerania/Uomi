//
//  BalanceTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

//struct cellData{
//    let uid : String!
//    let initialsText : String!
//    let nameText : String!
//    let balanceText : String!
//
//}

class BalanceTableViewController: UITableViewController {
    @IBOutlet weak var imbalanceView: ImbalanceView!
    
    var eventId : String!
    var accountId: String!

    private var balanceList = [Balance]()
    private var selectedRow = 0
    
    
    // MARK: - View Controller Overrides
    override func viewDidLoad(){
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        self.reloadTableViewData()
    }
    
    @objc public func refresh(refreshControl: UIRefreshControl) {
        self.reloadTableViewData(refreshControl: refreshControl)
        // Code to refresh table view
    }
    
    private func reloadTableViewData(refreshControl: UIRefreshControl?) {
        EventManager.sharedInstance.loadEvent(id: eventId) { (event) in
            self.title = event?.getName()
        }
        self.reloadTableViewData()
        refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableViewData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Imbalance View
    
    func updateImbalanceView() {
        BalanceManager.sharedInstance.getOwingBalances(user: accountId, event: eventId) { (iOwe, theyOwe) in
            self.imbalanceView.iOweAmount = iOwe
            self.imbalanceView.theyOweAmount = theyOwe
        }
    }
    
    
    // MARK: - Table View Overrides
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.balanceList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("BalancesTableViewCell", owner: self, options: nil)?.first as! BalancesTableViewCell
        
        let balance = self.balanceList[indexPath.row]
        
        cell.mainName.text = balance.getName()
        cell.payerId = balance.getUid()
        
        cell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: balance.getBalance())
        
        if (balance.getBalance() == 0) {
            cell.mainBalance.textColor = UIColor.init(red: 51/255, green: 136/255, blue: 67/255, alpha : 1)
            cell.mainBalance.text = UomiFormatters.dollarFormatter.string(for: 0)
        }
        else if (balance.getBalance() > 0){
            cell.mainBalance.textColor = .orange
        }
        else{
            cell.mainBalance.textColor = .red
        }
        return cell
        
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row;
        self.performSegue(withIdentifier: "toSettle", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK: - Helper Functions
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        print("Clicked Back Button")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func reloadTableViewData(){
        AccountManager.sharedInstance.getCurrentUser(){ user in
            guard let user = user else{
                print("There is something wrong. User is supposed to be logged in.")
                return
            }
            let userId = user.getUid()
            
            guard let eventId = self.eventId else{
                return
            }

            BalanceManager.sharedInstance.loadBalanceList(userId: userId, eventId: eventId){balances in
                self.balanceList = balances
                self.tableView.reloadData()
                self.updateImbalanceView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewCtrl = segue.destination as? SettleViewController {
//            viewCtrl.userCellData = self.arrayOfCellData[self.selectedRow]
            viewCtrl.userCellData = self.balanceList[self.selectedRow]
        }
    }
    

}
