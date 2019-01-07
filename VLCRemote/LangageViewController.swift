//
//  LangageViewController.swift
//  VLCRemote
//
//  Created by Theo Caselli on 21/02/2018.
//  Copyright © 2018 Nothing. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LangageViewController: UIViewController
{
    func showChange(type: String, array: Dictionary<String, JSON>)
    {
        var desc = ""
        
        if type == "audio"
        {
            let alert = UIAlertController(title: "Wich audio language do you want?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            for (stream, streamDict) in array
            {
                desc = streamDict["Description"].string ?? ""
                
                alert.addAction(UIAlertAction(title: streamDict["Language"].string ?? "Track" + " \(desc)", style: .default, handler:
                { action in
                    
                    Alamofire.request(baseURL, parameters: ["command": "audio_track", "val": Int(stream.split(separator: " ")[1]) ?? 1], headers: headers)
                    
                }))
            }
            
            self.present(alert, animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "Wich subtitle language do you want?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            for (stream, streamDict) in array
            {
                desc = streamDict["Description"].string ?? ""
                
                alert.addAction(UIAlertAction(title: streamDict["Language"].string ?? "Track" + " \(desc)", style: .default, handler:
                    { action in
                        
                        Alamofire.request(baseURL, parameters: ["command": "subtitle_track", "val": Int(stream.split(separator: " ")[1]) ?? 1], headers: headers)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Disable", style: .default, handler:
                { action in
                    
                    Alamofire.request(baseURL, parameters: ["command": "subtitle_track", "val": -1], headers: headers)
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func changeAudio(_ sender: Any)
    {
        Alamofire.request(baseURL, headers: headers).responseJSON
        { response in
                
            let json = JSON(response.value ?? "")
                
            let allStreams = json["information"]["category"].dictionaryValue
            
            var audioStreams: Dictionary<String, JSON> = [:]
            
            for (stream, streamDict) in allStreams
            {
                if streamDict["Type"].string == "Audio"
                {
                    audioStreams[stream] = streamDict
                }
            }
            
            self.showChange(type: "audio", array: audioStreams)
        }
    }
    
    @IBAction func changeSubtitle(_ sender: Any)
    {
        Alamofire.request(baseURL, headers: headers).responseJSON
            { response in
                
                let json = JSON(response.value ?? "")
                
                let allStreams = json["information"]["category"].dictionaryValue
                
                var subStreams: Dictionary<String, JSON> = [:]
                
                for (stream, streamDict) in allStreams
                {
                    if streamDict["Type"].string == "Subtitle"
                    {
                        subStreams[stream] = streamDict
                    }
                }
                
                self.showChange(type: "sub", array: subStreams)
        }
    }
}
