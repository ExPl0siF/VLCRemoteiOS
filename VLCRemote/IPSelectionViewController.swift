//
//  IPSelectionViewController.swift
//  VLCRemote
//
//  Created by Theo Caselli on 22/02/2018.
//  Copyright © 2018 Nothing. All rights reserved.
//

import UIKit
import MMLanScan
import Alamofire
import KeychainSwift

class IPSelectionViewController: UIViewController, MMLANScannerDelegate
{
    var lanScanner: MMLANScanner!
    var device: [[String]] = []
    
    @IBOutlet weak var IPLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var IPButton: UIButton!
    @IBOutlet weak var progressIP: UIProgressView!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        
        headers = ["Authorization": keychain.get("headers") ?? "Basic OnZsY3JlbW90ZQ=="]
        
        if let myIP = myUserDefaults.string(forKey: "IP")
        {
            BaseIP = myIP
            baseURL = "http://" + myIP + ":8080/requests/status.json"
        }
        
        if BaseIP != ""
        {
            self.IPLabel.text = "Click Next to continue with this IP:\n" + BaseIP
            self.nextButton.isEnabled = true
        }
        else
        {
            self.IPLabel.text = "Please select your IP"
            self.nextButton.isEnabled = false
        }

        self.lanScanner = MMLANScanner(delegate: self)
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int)
    {
        self.progressIP.progress = pingedHosts / Float(overallHosts)
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!)
    {
        var testURL = ""
    
        self.device.append([device.ipAddress, ""])
        
        testURL = "http://" + device.ipAddress + ":8080/requests/status.json"
        
        let testHeaders = ["Authorization": "Basic OnZsY3JlbW90ZQ=="]
        
        Alamofire.request(testURL, headers: testHeaders).responseJSON(completionHandler:
        { rep in
            
            if (rep.response?.statusCode == 200)
            {
                headers = ["Authorization": "Basic OnZsY3JlbW90ZQ=="]
                keychain.set("Basic OnZsY3JlbW90ZQ==", forKey: "headers")
                
                for x in 0..<self.device.count
                {
                    if (self.device[x][0] == device.ipAddress)
                    {
                        self.device[x][1] = " (VLC Here)"
                    }
                }
            }
            else if (rep.response?.statusCode == 401)
            {
                for x in 0..<self.device.count
                {
                    if (self.device[x][0] == device.ipAddress)
                    {
                        self.device[x][1] = " (VLC Here with password)"
                    }
                }
            }
        })
    }
    
    func launchWithPassword()
    {
        let alertController = UIAlertController(title: "Enter Password", message: "Could you please enter your password", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Go", style: .default, handler:
        {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            firstTextField.isSecureTextEntry = true
            
            firstTextField.text?.insert(":", at: (firstTextField.text?.startIndex)!)
            
            headers = ["Authorization": "Basic \(firstTextField.text?.toBase64() ?? "")"]

            Alamofire.request(baseURL, headers: headers).responseJSON(completionHandler:
            { rep in
                    
                if (rep.response?.statusCode == 200)
                {
                    keychain.set("Basic \(firstTextField.text?.toBase64() ?? "")", forKey: "headers")
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
                else
                {
                    ui.alertView(vc: self, title: "Bad Password", body: "Could you please retry")
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addTextField
        { (textField: UITextField!) -> Void in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus)
    {
        let alert = UIAlertController(title: "Select your ip adress", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        for x in 0..<self.device.count
        {
            alert.addAction(UIAlertAction(title: self.device[x][0] + self.device[x][1], style: .default, handler:
            { action in

                BaseIP = self.device[x][0]
                myUserDefaults.set(self.device[x][0], forKey: "IP")
                baseURL = "http://" + self.device[x][0] + ":8080/requests/status.json"

                if (self.device[x][1] == " (VLC Here with password)")
                {
                    self.launchWithPassword()
                }
                else
                {
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
            }))
        }

        self.present(alert, animated: true)
        self.IPButton.isEnabled = true
        self.progressIP.isHidden = true
    }
    
    func lanScanDidFailedToScan()
    {
        self.IPButton.isEnabled = true
        self.progressIP.isHidden = true
        ui.alertView(vc: self, title: "Error", body: "Error when trying to scan your network, are you connected to WiFi?")
    }
    
    @IBAction func next(_ sender: Any)
    {
        self.performSegue(withIdentifier: "goToMain", sender: self)
    }
    
    @IBAction func changeIP(_ sender: Any)
    {
        self.IPButton.isEnabled = false
        self.progressIP.isHidden = false
        self.device.removeAll()
        self.lanScanner.start()
    }
}
