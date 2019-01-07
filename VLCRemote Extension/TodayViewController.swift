//
//  TodayViewController.swift
//  VLCRemote Extension
//
//  Created by Theo Caselli on 23/02/2018.
//  Copyright © 2018 Nothing. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON
import MMLanScan

class TodayViewController: UIViewController, NCWidgetProviding, MMLANScannerDelegate
{
    var lanScanner: MMLANScanner!
    var device: [String] = []
    var todayURL = ""
    
    @IBOutlet weak var volumeProgress: UIProgressView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        self.lanScanner = MMLANScanner(delegate: self)
        
        self.lanScanner.start()
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
    }
    
    @objc func refresh()
    {
        Alamofire.request(self.todayURL, headers: headers).responseJSON
            { response in
                
                let json = JSON(response.value ?? "")
                
                let soundFloat = json["volume"].float ?? self.volumeProgress.progress
                
                self.volumeProgress.setProgress(soundFloat / 512, animated: true)
                
                if (json["state"].string == "paused")
                {
                    self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                }
                else
                {
                    self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice!)
    {
        var testURL = ""
        
        self.device.append(device.ipAddress)
        
        testURL = "http://" + self.device[self.device.count - 1] + ":8080/requests/status.json"
        
        Alamofire.request(testURL, headers: headers).responseJSON(completionHandler:
        { rep in
                
            if (rep.response?.statusCode == 200)
            {
                self.todayURL = testURL
            }
        })
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus)
    {
        
    }
    
    func lanScanDidFailedToScan() {}
    
    @IBAction func backward(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "pl_previous"], headers: headers)
    }
    
    @IBAction func goBack30(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "seek", "val": "-30s"], headers: headers)
    }
    
    @IBAction func playPause(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "pl_pause"], headers: headers)
    }
    
    @IBAction func jump30(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "seek", "val": "+30s"], headers: headers)
    }
    
    @IBAction func next(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "pl_next"], headers: headers)
    }
    
    @IBAction func volumeLess(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "volume", "val": "-10"], headers: headers)
    }
    
    @IBAction func volumeMore(_ sender: Any)
    {
        Alamofire.request(self.todayURL, parameters: ["command": "volume", "val": "+10"], headers: headers)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        completionHandler(NCUpdateResult.newData)
    }
}
