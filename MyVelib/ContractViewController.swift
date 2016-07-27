//
//  ContractViewController.swift
//  MyVelib
//
//  Created by etudiant-02 on 16/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK

class ContractViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    
    @IBOutlet var myPickerView : UIPickerView!
    
    
    var pickerData = [String]()
    

    override func viewDidAppear(animated: Bool) {
 
        //pour tester seulement
      /*
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "favContract"  )
        defaults.synchronize()
         */
        
        
        super.viewDidAppear(animated)
        
        if Utils.getChoosenContract() == nil {
            
            myPickerView.dataSource = self
            myPickerView.delegate = self
            
            let api = Api()
            api.getContracts { (contracts) in
                for (key,_) in contracts {
                    self.pickerData.append(key)
                }
                Config.contract = self.pickerData[0]
                Utils.persistChoosenContract(self.pickerData[0])
                self.myPickerView.reloadAllComponents()
            }
        }
        else {
          // perform segue toPager
            
            let flurryParams = ["type": Utils.getChoosenContract()!]
            Flurry.logEvent("Contract_choosen", withParameters: flurryParams)

            Config.contract = Utils.getChoosenContract()
            performSegueWithIdentifier("toPager", sender: self)
        }
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Config.contract = pickerData[row]
        Utils.persistChoosenContract(pickerData[row])
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
