//
//  NPrescriptionTableViewController.swift
//  iPrescription
//
//  Created by Marco Salafia on 08/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import UIKit

class NPrescriptionTableViewController: UITableViewController
{
    lazy var prescriptionsModel: PrescriptionList? = (UIApplication.sharedApplication().delegate as! AppDelegate).prescriptions
    
    var prescriptionDelegate: PrescriptionAddingDelegate?

    override func viewDidLoad()
    {
        addAllNecessaryObservers()
        setUserInterfaceComponents()
        
        super.viewDidLoad()
    }
    
    func addAllNecessaryObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateInterface", name: "MGSUpdateInterface", object: nil)
    }
    
    func setUserInterfaceComponents()
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func updateInterface()
    {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Metodi relativi al Controller
    
    @IBAction func addNewPrescription(sender: AnyObject)
    {
        prescriptionDelegate = PrescriptionAddingPerformer(delegator: self)
        prescriptionDelegate!.showAlertController()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return prescriptionsModel!.numberOfPrescriptions()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: PrescriptionTableViewCell? = tableView.dequeueReusableCellWithIdentifier("my Cell") as? PrescriptionTableViewCell
        let selectedPrescription = prescriptionsModel?.getPrescriptionAtIndex(indexPath.row)
        cell!.textLabel?.text = selectedPrescription?.nome        
        cell!.imageView?.image = UIImage(named: "Prescription.png")
        
        // TODO: Fare Refactoring di questa parte in un metodo di forwarding.
        var medString: String
        let drugsNumber = prescriptionsModel!.numberOfDrugsForPrescriptionAtIndex(indexPath.row)
        if drugsNumber == 1
        {
            medString = NSLocalizedString("Medicina", comment: "Sottotitolo riga della prescrizione al singolare")
        }
        else
        {
            medString = NSLocalizedString("Medicine", comment: "Sottotitolo riga della prescrizione al plurale")
        }
        
        let notificationNumber = prescriptionsModel!.numberOfNotificationsForPrescriptionAtIndex(indexPath.row)
        
        if notificationNumber == 0
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString
        }
        else if notificationNumber == 1
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString +
                String(format: NSLocalizedString(" - %d Notifica", comment: "sottotitolo prescrizione per le notifiche al singolare"), notificationNumber)
        }
        else
        {
            cell!.detailTextLabel!.text = "\(drugsNumber) " + medString + String(format: NSLocalizedString(" - %d Notifiche", comment: "sottotitolo prescrizione per le notifiche al plurale"), notificationNumber)
        }

        return cell!
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            prescriptionsModel?.deletePrescriptionAtIndex(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let editAction = getEditRowAction()
        let deleteAction = getDeleteRowAction()
        
        return [deleteAction, editAction]
    }
    
    func getEditRowAction() -> UITableViewRowAction
    {
        let editLabel = NSLocalizedString("Modifica", comment: "Azione modifica")
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: editLabel)
        {
            (action, index) in
            if let prescription = self.prescriptionsModel?.getPrescriptionAtIndex(index.row)
            {
                let editingDelegate: PrescriptionEditingDelegate = PrescriptionEditingPerformer(delegator: self, prescription: prescription)
                editingDelegate.performEditingProcedure()
            }
        }
        editAction.backgroundColor = UIColor(red: 35.0/255.0, green: 146.0/255.0, blue: 199.0/255.0, alpha: 1)
        
        return editAction
    }
    
    func getDeleteRowAction() -> UITableViewRowAction
    {
        let deleteLabel = NSLocalizedString("Elimina", comment: "Azione cancella")
        let tv: UITableView? = tableView
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: deleteLabel)
        {
            (action, index) in tv!.dataSource?.tableView!(tv!, commitEditingStyle: .Delete, forRowAtIndexPath: index)
        }
        
        return deleteAction
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toAddDrugs"
        {
            if let destinationNavigationController = segue.destinationViewController as? UINavigationController
            {
                if let formViewController = (destinationNavigationController.viewControllers[0] as? AddDrugFormController)
                {
                    if let presenter = sender as? PrescriptionAddingDelegate
                    {
                        formViewController.setCurrentPrescription(presenter.prescription!)
                        formViewController.workingOnNewPrescription()
                    }
                }
            }
        }
    }
    

}