//
//  ViewController.swift
//  shaker
//
//  Created by Scott Cambo on 1/28/15.
//  Copyright (c) 2015 Scott Cambo. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    lazy var motionManager = CMMotionManager()
    @IBOutlet weak var shakeLabel: UILabel!
    @IBOutlet weak var xLab: UILabel!
    @IBOutlet weak var yLab: UILabel!
    @IBOutlet weak var zLab: UILabel!
    var x : String?
    var y : String?
    var z : String?
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if motionManager.accelerometerAvailable{
            let queue = NSOperationQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {(data: CMAccelerometerData!, error: NSError!) in
                    
                    println("X = \(data.acceleration.x)")
                    println("Y = \(data.acceleration.y)")
                    println("Z = \(data.acceleration.z)")
                    self.x = String(format:"%f", data.acceleration.x)
                    self.y = String(format:"%f", data.acceleration.y)
                    self.z = String(format:"%f", data.acceleration.z)
                    self.xLab.text = "X : " + self.x!
                    self.yLab.text = "Y : " + self.y!
                    self.zLab.text = "Z : " + self.z!
                }
            )
        } else {
            println("Accelerometer is not available")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            self.shakeLabel.text = "Shaken, not stirred"
            
            var request = NSMutableURLRequest(URL: NSURL(string: "http://www.scottallencambo.com/swiftSend")!)
            
            var session = NSURLSession.sharedSession()
            
            request.HTTPMethod = "POST"
            
            var shaker_x:String="Shaken X"
            var shaker_y:String="Shaken Y"
            var shaker_z:String="Shaken Z"
            
            if (self.x != nil){
                shaker_x = self.x!
            }
            
            if (self.y != nil){
                shaker_y = self.y!
            }
            
            if (self.z != nil){
                shaker_z = self.z!
            }
            
            var params = ["X":shaker_x, "Y":shaker_y, "Z" : shaker_z] as Dictionary
            
            var err: NSError?
            
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            self.shakeLabel.text = "Sending Data"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                println("Response: \(response)")
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Body: \(strData)")
                
                self.shakeLabel.text = "Data : " + strData!
                var err: NSError?
                var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                        var success = parseJSON["success"] as? Int
                        println("Success: \(success)")
                        self.shakeLabel.text = parseJSON["msg"] as? String
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("Error could not parse JSON: \(jsonStr)")
                    }
                }
            })
            task.resume()
        }
    }
    

}

