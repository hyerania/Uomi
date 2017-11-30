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

class ExpenseTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    let dateFormatter = getDateFormatter()
    
    var delegate: ExpenseTransactionDelegate?
    let imagePicker = UIImagePickerController()
    var imageView: UIImageView!
    var scrollImg: UIScrollView!
    
    var transaction: ExpenseTransaction! {
        didSet {
            assertInitialContributions()
            updateUI()
        }
    }
    
    private let activitiyViewController = ActivityViewController(message: "Saving...")

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var receiptView: UIImageView!
    
    @IBOutlet weak var payerLabel: ParticipantView!
    @IBOutlet weak var totalField: UITextField!
    
    @IBOutlet weak var splitSeg: UISegmentedControl!
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionField.addTarget(self, action: #selector(descriptionChanged), for: .editingChanged)
        
        imagePicker.delegate = self
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
        tableview.setEditing(true, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        receiptView.addGestureRecognizer(pictureTap)
        receiptView.isUserInteractionEnabled = true
        
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
        totalField.text = UomiFormatters.dollarNoSignFormatter.string(for: Float(transaction.total) / 100)
        descriptionField.text = transaction.transDescription
        splitSeg.selectedSegmentIndex = transaction.splitMode == .percent ? 0 : 1
        let event = EventManager.sharedInstance.getActiveEvent()
        
        guard let eventId = event, let uid = transaction.uid else {
            return
        }
        TransactionManager.sharedInstance.fetchImage(eventId: eventId, transactionId: uid) { (photo) in
            self.receiptView.contentMode = .scaleAspectFill
            self.receiptView.image = photo
        }
        // Extract contribution data
        tableview.reloadData()
        
        updateSaveState()
    }
    
    
    // MARK: - Save state
    
    func updateSaveState() {
        saveButton.isEnabled = canSave()
    }
    
    private func canSave() -> Bool {
        guard transaction.total > 0/*, transaction.imageData != nil*/ else {
            return false
        }
        guard transaction.splitMode == .lineItem else {
            return true
        }
        
        return !transaction.contributions.isEmpty &&  transaction.contributions.filter({ (contrib) -> Bool in
            return contrib.member == nil || contrib.getContributionAmount() == 0
        }).isEmpty
    }
    
    // MARK: - Image Selection
    
    @IBAction func hitCamera(_ sender: Any) {
    
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera;
            self.imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            // TODO Display alert.
        }
        // TODO Get image from camera
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        receiptView.contentMode = .scaleAspectFill
        receiptView.image = chosenImage
        transaction.imageData = chosenImage
        dismiss(animated:true, completion: nil)
        
        
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        scrollImg = UIScrollView(frame: self.view.bounds)
        scrollImg.delegate = self
        scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.view.addSubview(scrollImg)
        
        imageView = UIImageView(frame: self.view.bounds)
        imageView.image = receiptView.image
        imageView!.layer.cornerRadius = 11.0
        imageView!.clipsToBounds = false
        
        scrollImg.addSubview(imageView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        scrollImg.addGestureRecognizer(tap)
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
                cell.delegate = self
                
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
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            else {
                // Remove line item
                transaction.lineItemContributions.remove(at: row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                recalculateLineItemTotal()
                tableView.endUpdates()
                updateSaveState()
            }
        }
        else {
            // Create new line-item entry
            let newContribution = LineItemContribution()
            let currentCount: Int = transaction.lineItemContributions.count
            transaction.lineItemContributions.append(newContribution)
            let indexPath: IndexPath = IndexPath(row: currentCount, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            let cell = tableView.cellForRow(at: indexPath) as! LineItemSplitTableViewCell
            cell.participantView.selectMember()
            
            updateSaveState()
        }    
    }
    
    
    // MARK: - Date Selection
    
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
    
    
    // MARK: - Syncing Total
    
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
            
            tableview.reloadData()
        }
        
        updateSaveState()
    }
    
    
    // MARK: - Text Field Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    @objc func descriptionChanged() {
        transaction.transDescription = descriptionField.text
    }
    
    
    // MARK: Split Mode
    
    fileprivate func assertInitialContributions() {
        // Initialize an equal split
        guard transaction.splitMode == .percent && transaction.percentContributions.isEmpty else {
            return
        }
        
        let eventId = EventManager.sharedInstance.getActiveEvent()!
        AccountManager.sharedInstance.getUserIds(event: eventId) { (userIds) in
            let percentage = 100 / userIds.count
            for userId in userIds {
                let contrib = PercentContribution(transaction: self.transaction)
                contrib.member = userId
                contrib.percent = percentage
                self.transaction.percentContributions.append(contrib)
            }
            self.tableview.reloadData()
        }
    }
    
    @IBAction func setSplitMode(_ sender: Any) {
        transaction.splitMode = splitSeg.selectedSegmentIndex == 0 ? .percent : .lineItem
        
            assertInitialContributions()
        
        tableview.reloadData()
        updateSaveState()
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
        
        DispatchQueue.global(qos: .background).async {
            self.delegate?.shouldSave(expenseController: self, transaction: self.transaction)
        }
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

extension ExpenseTransactionViewController: ParticipantViewDelegate {
    
    func participantSelected(participantView: ParticipantView, participant: User) {
        transaction.payer = participant.getUid()

        updateSaveState()
    }
    
}

extension ExpenseTransactionViewController: LineItemSplitDelegate {
    fileprivate func recalculateLineItemTotal() {
        // Update the running total
        tableview.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    func contributionDidUpdate(lineItemCell: LineItemSplitTableViewCell, contribution: Contribution) {
        recalculateLineItemTotal()
        
        updateSaveState()
    }
    
    
}
