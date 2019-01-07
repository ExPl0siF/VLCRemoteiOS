//
//  ViewController.swift
//  VLCRemote
//
//  Created by Theo Caselli on 21/02/2018.
//  Copyright © 2018 Nothing. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MMLanScan
import KeychainSwift

var BaseIP: String = ""
var baseURL: String = ""
var headers = ["Authorization": "Basic OnZsY3JlbW90ZQ=="]
let myUserDefaults = UserDefaults.standard
let keychain = KeychainSwift()

extension String
{
    func toBase64() -> String
    {
        return Data(self.utf8).base64EncodedString()
    }
}

class ViewController: UIViewController
{
    @IBOutlet weak var soundSlider: UISlider!
    @IBOutlet weak var seekMovie: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var movieLength: UILabel!
    @IBOutlet weak var movieName: UILabel!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int)
    {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @objc func refresh()
    {
        Alamofire.request(baseURL, headers: headers).responseJSON
        { response in
            
            if (response.response?.statusCode != 200)
            {
                return
            }
            
            let json = JSON(response.value ?? "")
            
            self.soundSlider.value = json["volume"].float ?? self.soundSlider.value
            self.seekMovie.maximumValue = json["length"].float ?? self.seekMovie.maximumValue
            self.seekMovie.value = json["time"].float ?? self.seekMovie.value
            self.movieName.text = json["information"]["category"]["meta"]["filename"].string ?? self.movieName.text
            
            if (json["time"].int != nil)
            {
                let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: json["time"].int!)
                let (hl,ml,sl) = self.secondsToHoursMinutesSeconds(seconds: json["length"].int!)
                
                self.movieLength.text = "\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s)) / \(String(format: "%02d", hl)):\(String(format: "%02d", ml)):\(String(format: "%02d", sl))"
            }
            
            if (json["state"].string == "paused")
            {
                self.playButton.setImage(UIImage(named: "play"), for: .normal)
            }
            else
            {
                self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            }
        }
    }
    
    @IBAction func setFullscreen(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "fullscreen"], headers: headers)
    }
    
    @IBAction func seekMovieChanger(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "seek", "val": Int(self.seekMovie.value)], headers: headers)
    }
    
    @IBAction func playPause(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "pl_pause"], headers: headers)
    }
    
    @IBAction func jump30(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "seek", "val": "+30s"], headers: headers)
    }
    
    @IBAction func back30(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "seek", "val": "-30s"], headers: headers)
    }
    
    @IBAction func backTrack(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "pl_previous"], headers: headers)
    }
    
    @IBAction func nextTrack(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "pl_next"], headers: headers)
    }
    
    @IBAction func soundChanger(_ sender: Any)
    {
        Alamofire.request(baseURL, parameters: ["command": "volume", "val": Int(self.soundSlider.value)], headers: headers)
    }
    
    @IBAction func quitVLC(_ sender: Any)
    {
        let alert = UIAlertController(title: "Do you want to quit VLC?", message: "If you click yes VLC will quit now, if you click at the end, VLC will quit after playing all the playlist", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler:
        { act in
            Alamofire.request(baseURL, parameters: ["command": "in_play", "input": "vlc://quit"], headers: headers)
        }))
        
        alert.addAction(UIAlertAction(title: "At the end", style: .default, handler:
        { act in
            Alamofire.request(baseURL, parameters: ["command": "in_enqueue", "input": "vlc://quit"], headers: headers)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

