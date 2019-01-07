//
//  Utils.swift
//  VLCRemote
//
//  Created by Theo Caselli on 24/02/2018.
//  Copyright © 2018 Nothing. All rights reserved.
//

import Foundation
import UIKit

class ui
{
    class func alertView(vc: UIViewController, title: String, body: String, completionHandler: ((UIAlertAction) -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: completionHandler))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    class func alertViewYesNo(vc: UIViewController, title: String, body: String, yesHandler: ((UIAlertAction) -> Void)? = nil, noHandler: ((UIAlertAction) -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: yesHandler))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: noHandler))
        
        vc.present(alert, animated: true, completion: nil)
    }
}
