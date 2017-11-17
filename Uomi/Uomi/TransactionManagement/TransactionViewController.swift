//
//  TransactionViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

let percentResueIdentifier = "percentageCell"
let lineItemReuseIdentifier = "lineItemCell"
let lineItemTotalReuseIdentifier = "lineItemTotalCell"

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dateFormatter = getDateFormatter()
    
    var transaction: Transaction! {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var receiptView: UIImageView!
    
    @IBOutlet weak var payerLabel: ParticipantView!
    @IBOutlet weak var totalField: UITextField!
    
    @IBOutlet weak var splitSeg: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        
        // Do any additional setup after loading the view.
        tableView.setEditing(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateUI() {
        // TODO Update all the UI elements
        guard let dateField = dateField, transaction != nil else { return }
        
        dateField.text = dateFormatter.string(from: transaction.date)
    }
    
    // MARK: - Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: percentResueIdentifier, for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: lineItemReuseIdentifier, for: indexPath)
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: lineItemTotalReuseIdentifier, for: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 2 {
            return .insert
        }
        
        return .delete
    }
    
    
    // MARK: - Table Delegate
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: Support
    
    fileprivate static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
