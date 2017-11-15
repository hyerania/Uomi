//
//  SettleTableViewController.swift
//  Uomi
//
//  Created by Yerania Yuni Hernandez on 11/15/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

class SettleViewController: UIViewController {
    var userCellData : cellData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userCellData = userCellData else {
            return
        }
        self.title = userCellData.nameText
//        self.title = "Settle"
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
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

}
