//
//  BalanceTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/14/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

struct cellData{
    let uid : String!
    let initialsText : String!
    let nameText : String!
    let balanceText : String!
    
}

class BalanceTableViewController: UITableViewController {
    var arrayOfCellData = [cellData]()
    var selectedRow = 0
    var eventId : String?
    
    override func viewDidLoad(){
        arrayOfCellData = [cellData(uid : "123", initialsText : "KJ", nameText: "Kevin J Nguyen", balanceText : "$" + "3.30"),
                           cellData(uid : "123", initialsText : "YH", nameText: "Yerania Hernandez", balanceText : "$" + "5.50"),
                           cellData(uid : "123", initialsText : "EG", nameText: "Eric Gonzalez", balanceText : "$" + "2.30")
                           ]
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        print("Clicked Back Button")
        self.performSegue(withIdentifier: "backBalancesSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCellData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("BalancesTableViewCell", owner: self, options: nil)?.first as! BalancesTableViewCell
        
        cell.mainInitials.text = arrayOfCellData[indexPath.row].initialsText
        cell.mainName.text = arrayOfCellData[indexPath.row].nameText
        cell.mainBalance.text = arrayOfCellData[indexPath.row].balanceText
        
        return cell
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row;
        self.performSegue(withIdentifier: "toSettle", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewCtrl = segue.destination as? SettleViewController {
            viewCtrl.userCellData = self.arrayOfCellData[self.selectedRow]
        }
    }
    

}
