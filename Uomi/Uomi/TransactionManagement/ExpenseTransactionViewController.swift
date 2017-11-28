//
//  EventTransactionViewController.swift
//  Uomi
//
//  Created by Eric Gonzalez on 11/11/17.
//  Copyright © 2017 Eric Gonzalez. All rights reserved.
//

import UIKit

let percentResueIdentifier = "percentageCell"
let lineItemReuseIdentifier = "lineItemCell"
let lineItemTotalReuseIdentifier = "lineItemTotalCell"

let calendarIcon = "calendar"


protocol ExpenseTransactionDelegate {
    func shouldCancel(expenseController controller: ExpenseTransactionViewController)
    
    func shouldSave(expenseController controller: ExpenseTransactionViewController,  transaction: Transaction)
}

class ExpenseTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let dateFormatter = getDateFormatter()
    
    var delegate: ExpenseTransactionDelegate?
    
    var transaction: ExpenseTransaction! {
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

        let imageView: UIImageView = UIImageView(image: UIImage(named: "calendar"))
        imageView.bounds.size = CGSize(width: 20, height: 20)
        
        dateField.rightView = imageView
        dateField.rightViewMode = .always
        
        payerLabel.delegate = self
        payerLabel.viewController = self
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        label.text = "$"
        label.textColor = UIColor.gray
        label.textAlignment = .right
        
        totalField.leftView = label
        totalField.leftViewMode = .always
        
        totalField.addTarget(self, action: #selector(updateTotal), for: .editingChanged)
        
        updateUI()
        
        // Do any additional setup after loading the view.
        tableView.setEditing(true, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateUI() {
        // TODO Update all the UI elements
        guard let dateField = dateField, transaction != nil else { return }
        
        dateField.text = dateFormatter.string(from: transaction.date)
        
        payerLabel.memberId = transaction.payer
        totalField.text = "\(Float(transaction.total) / 100)"
        descriptionField.text = transaction.transDescription
        splitSeg.selectedSegmentIndex = transaction.splitMode == .percent ? 0 : 1
        
        // Extract contribution data
        tableView.reloadData()
    }
    
    
    // MARK: Image Selection
    
    @IBAction func hitCamera(_ sender: Any) {
        // TODO Display image picker with camera
        if  UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            
            imagePicker.mediaTypes = [UIImagePickerControllerMediaType]
        }
        else {
            // TODO Display warning saying image picker not available, change in settings
        }
        
        // TODO Get image from camera
    }
    
    
    // MARK: - Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transaction.splitMode == .percent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transaction.splitMode == .percent {
            return transaction.percentContributions.count
        }
        else {
            return section == 0 ? transaction.lineItemContributions.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if transaction.splitMode == .percent {
            let cell = tableView.dequeueReusableCell(withIdentifier: percentResueIdentifier, for: indexPath) as! PercentageSplitTableViewCell
            cell.contribution = transaction.percentContributions[indexPath.row]
            
            return cell
        }
        else {
            if indexPath.section == 0 {
                let cell: LineItemSplitTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineItemReuseIdentifier, for: indexPath) as! LineItemSplitTableViewCell
                cell.contribution = transaction.lineItemContributions[indexPath.row]
                cell.participantView.viewController = self
                
                return cell
            }
            else {
                let cell: LineItemTotalTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineItemTotalReuseIdentifier, for: indexPath) as! LineItemTotalTableViewCell
                
                let totalAmount: Int = transaction.lineItemContributions.reduce(0, { (sum, contrib) -> Int in
                    return sum + contrib.getContributionAmount()
                })
                cell.totalLabel.text = UomiFormatters.dollarFormatter.string(for: Float(totalAmount) / 100)
                return cell
            }
        }
    }
    
    // FIXME This can be more elegant and enable new percentage contributions when some are removed
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if transaction.splitMode == .lineItem && indexPath.section == 1 {
            return .insert
        }
        
        return .delete
    }
    
    
    // MARK: - Table Delegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        if indexPath.section == 0 {
            if transaction.splitMode == .percent {
                // Remove percent item
                transaction.percentContributions.remove(at: row)
            }
            else {
                // Remove line item
                transaction.lineItemContributions.remove(at: row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        else {
            // Create new line-item entry
            let newContribution = LineItemContribution()
            let currentCount: Int = transaction.lineItemContributions.count
            transaction.lineItemContributions.append(newContribution)
            tableView.insertRows(at: [IndexPath(row: currentCount, section: 0)], with: .automatic)
        }    
    }
    
    
    // MARK: - Text Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === dateField {
        let datePicker = UIDatePicker()
        datePicker.setDate(transaction.date, animated: false)
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        dateField.inputView = datePicker
        }
        
        return true
    }

    @objc func dateChanged(sender: Any) {
        let datePicker = dateField.inputView as! UIDatePicker
        let date = datePicker.date
        self.dateField.text = dateFormatter.string(from: date)
        transaction.date = date
    }
    
    @objc func updateTotal() {
        // Only change value when value is set
        if let totalTxt = totalField.text, !totalTxt.isEmpty, var newTotal = Float(totalTxt) {
            newTotal = newTotal * 100
            transaction.total = Int(newTotal)
        }
        else {
            transaction.total = 0
        }
        
        if transaction.splitMode == .percent {
            // Update contribution labels
            
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === descriptionField {
            transaction.transDescription = textField.text
        }
        
        return true
    }
    
    
    // MARK: Split Mode
    
    @IBAction func setSplitMode(_ sender: Any) {
        transaction.splitMode = splitSeg.selectedSegmentIndex == 0 ? .percent : .lineItem
        
        tableView.reloadData()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, String(describing: type(of: view)) == "UITableViewCellEditControl" {
            return false
        }

        return true
    }
    
    
    // MARK: Support
    
    fileprivate static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    
    // MARK: Delegate actions
    
    @IBAction func hitCancel(_ sender: Any) {
        delegate?.shouldCancel(expenseController: self)
    }
    
    @IBAction func hitSave(_ sender: Any) {
        dismissKeyboard()
        delegate?.shouldSave(expenseController: self, transaction: transaction)
    }
}

extension ExpenseTransactionViewController: ParticipantViewDelegate {
    
    func participantSelected(participantView: ParticipantView, participant: User) {
        transaction.payer = participant.getUid()
    }
    

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
