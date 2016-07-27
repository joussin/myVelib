//
//  AlertViewController.swift
//  MyVelib
//
//  Created by etudiant-02 on 16/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    var okHandler : (() -> ())!
    var cancelHandler : (() -> ())!
    
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var messageLabel: UILabel!
    
    @IBAction func okPressed(sender: UIButton!) {
        okHandler()
        self.close()
    }
    
    @IBAction func cancelPressed(sender: UIButton!) {
        cancelHandler()
        self.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func close (){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func setMessage(message: String){
        messageLabel.text = message
    }
}

/**
 
 How to use
 
 let pop = PopOver(vc: self,message: "mon message One btn")
 pop.affichePopOver({ print("tu as cliqué sur ok") }, cancelHandler: nil)
 
 
 let pop = PopOver(vc: self, message:"mon message Two Btn" )
 pop.affichePopOver( { print("tu as cliqué sur ok") }, cancelHandler: { print("tu as cliské sur cancel") } )
 
 
*/
class PopOver {
    
    var vc: UIViewController
    var instance : AlertViewController!
    var message: String!
    
    init (vc: UIViewController, message: String) {
        self.vc = vc
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        self.instance = (storyboard.instantiateViewControllerWithIdentifier("AlertViewController")) as! AlertViewController
        self.message = message
    }
    
    func affichePopOver(okHandler : () -> (), cancelHandler: (() -> ())?){
        
        vc.presentViewController(self.instance, animated: true, completion: { () in
            self.instance.messageLabel.text = self.message
            self.instance.okHandler = okHandler
            if cancelHandler != nil {
                self.instance.cancelHandler = cancelHandler
            }else{
                self.instance.cancelButton.hidden = true
            }
        })
    }
    
}





