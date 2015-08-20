//
//  DrugDetailController.swift
//  iPrescription
//
//  Created by Marco Salafia on 17/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class DrugDetailController: UITableViewController, UITextFieldDelegate, UITextViewDelegate
{
    lazy var prescriptionsModel: PrescriptionList = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptions
    
    // TODO: Verificare che questo campo serva solo all'inizializzazione del controller
    //in quanto se modificati i campi del controller tale proprietà è inconsistente.
    var currentDrug: Drug?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastAssumptionLabel: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var doctorTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var gestioneDataButton: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateFieldsFromCurrentDrug()
        setUserInterfaceComponents()
    }
    
    func updateFieldsFromCurrentDrug()
    {
        nameTextField.text = currentDrug?.nome
        
        if let date = currentDrug?.data_ultima_assunzione
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE dd MMMM hh:mm a"
            lastAssumptionLabel.text = dateFormatter.stringFromDate(date)
        }
        else
        {
            lastAssumptionLabel.text = ""
        }
        
        formTextField.text = currentDrug!.forma
        dosageTextField.text = currentDrug!.dosaggio
        periodTextField.text = currentDrug!.durata
        doctorTextField.text = currentDrug!.dottore
        noteTextView.text = currentDrug!.note
    }
    
    func setUserInterfaceComponents()
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        noteTextView.inputAccessoryView = getDoneToolbar()
    }
    
    func getDoneToolbar() -> UIToolbar
    {
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Fine", comment: "Done della Barbutton Detail"),
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "dismissKeyboard")
        
        doneButton.tintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
        let arrayItem = [doneButton]
        doneToolbar.items = arrayItem
        
        return doneToolbar
    }
    
    func setCurrentDrug(drug: Drug)
    {
        self.currentDrug = drug
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        
        if editing == true
        {
            enableEditingUI()
        }
        else
        {
            if nameTextField.text!.isEmpty
            {
                showEmptyDrugAlert()
                self.editing = true
            }
            else
            {
                disableEditingUI()
                updateCurrentDrugFromUI()
            }
        }
    }
    
    func enableEditingUI()
    {
        gestioneDataButton.enabled = false
        
        nameTextField.userInteractionEnabled = true
        nameTextField.borderStyle = UITextBorderStyle.RoundedRect
        formTextField.userInteractionEnabled = true
        formTextField.borderStyle = UITextBorderStyle.RoundedRect
        dosageTextField.userInteractionEnabled = true
        dosageTextField.borderStyle = UITextBorderStyle.RoundedRect
        periodTextField.userInteractionEnabled = true
        periodTextField.borderStyle = UITextBorderStyle.RoundedRect
        noteTextView.editable = true
        doctorTextField.userInteractionEnabled = true
        doctorTextField.borderStyle = UITextBorderStyle.RoundedRect
    }
    
    func disableEditingUI()
    {
        gestioneDataButton.enabled = true
        
        nameTextField.userInteractionEnabled = false
        nameTextField.borderStyle = UITextBorderStyle.None
        formTextField.userInteractionEnabled = false
        formTextField.borderStyle = UITextBorderStyle.None
        dosageTextField.userInteractionEnabled = false
        dosageTextField.borderStyle = UITextBorderStyle.None
        periodTextField.userInteractionEnabled = false
        periodTextField.borderStyle = UITextBorderStyle.None
        noteTextView.editable = false
        doctorTextField.userInteractionEnabled = false
        doctorTextField.borderStyle = UITextBorderStyle.None
    }
    
    func showEmptyDrugAlert()
    {
        let alert = UIAlertController(title: NSLocalizedString("Attenzione!", comment: "Titolo popup medicina vuota editing detail"),
                                      message: NSLocalizedString("Non è stato inserito alcun nome per la medicina",
                                      comment: "Messaggio popup medicina vuota editing detail"), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok comando popup medicina vuota editing detail"),
                                      style: UIAlertActionStyle.Default,
                                      handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateCurrentDrugFromUI()
    {
        let lastDrug = Drug(name: nameTextField.text!,
                            dosage: dosageTextField.text!,
                            doc: doctorTextField.text!,
                            period: periodTextField.text!,
                            form: formTextField.text!,
                            note: noteTextView.text,
                            id: currentDrug!.id,
                            date_last_assumption: currentDrug!.data_ultima_assunzione)
        
        prescriptionsModel.updateDrug(lastDrug)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.None
    }
    
    // MARK: - Delegato di testo
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard()
    {
        if noteTextView.isFirstResponder()
        {
            noteTextView.resignFirstResponder()
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
