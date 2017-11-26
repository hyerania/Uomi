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

class ExpenseTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
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
        
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "$"
        label.textColor = UIColor.gray
        label.textAlignment = .right
        
        totalField.leftView = label
        label.widthAnchor.constraint(equalToConstant: 20).isActive = true
        label.heightAnchor.constraint(equalToConstant: totalField.bounds.height).isActive = true
        totalField.leftViewMode = .always
        
        updateUI()
        
        // Do any additional setup after loading the view.
        tableView.setEditing(true, animated: false)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
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
            return cell
        }
        else {
            if indexPath.section == 0 {
                let cell: LineItemSplitTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineItemReuseIdentifier, for: indexPath) as! LineItemSplitTableViewCell
                return cell
            }
            else {
                let cell: LineItemTotalTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineItemTotalReuseIdentifier, for: indexPath) as! LineItemTotalTableViewCell
                return cell
            }
        }
    }
    
    // FIXME This can be more elegant and enable new percentage contributions when some are removed
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if transaction.splitMode == .lineItem && indexPath.row == transaction.lineItemContributions.count - 1 {
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
    
    
    // MARK: Text Delegate
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField === totalField {
            // Only change value when value is set
            if let totalTxt = totalField.text, !totalTxt.isEmpty, var newTotal = Float(totalTxt) {
                newTotal = newTotal * 100
                transaction.total = Int(newTotal)
            }
        }
        else if textField === descriptionField {
            transaction.transDescription = textField.text
        }
    }
    
    
    // MARK: Split Mode
    
    @IBAction func setSplitMode(_ sender: Any) {
        transaction.splitMode = splitSeg.selectedSegmentIndex == 0 ? .percent : .lineItem
        
        // TODO Update applicable contributions
        // Perhaps maintain two sets of contributions, one per type, and purge usused one leaving.
        // Otherwise, convert one to the other... somehow
        // HEY THIS COULD BE SOMETHING WORTH LOOKING INTO. Does changing split mode happen mainly by accident? Desire to convert from one to the other? Or start fresh? How would user navigate auto population?
        // Probably just infer what they should be as best as possible
        
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
