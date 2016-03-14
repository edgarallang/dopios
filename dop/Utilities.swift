//
//  Utilities.swift
//  dop
//
//  Created by Jose Eduardo Quintero Gutiérrez on 14/05/15.
//  Copyright (c) 2015 Edgar Allan Glez. All rights reserved.

//

import Foundation

class Utilities {
    static var filterArray: [Int] = []
    
    class var dopURL: String {
        return "http://45.55.7.118:5000/api/"
    }
    class var dopImagesURL : String {
        return "http://45.55.7.118/branches/images/"
    }
    
    class var badgeURL: String {
        return "http://45.55.7.118/badges/"
    }
    
    class var dopColor: UIColor {
        return UIColor( red: 251.0/255.0 , green: 34.0/255.0 , blue: 111.0/255.0, alpha:1.0)
    }
    
    class var dop_detail_color: UIColor {
        return UIColor( red: 33.0/255.0 , green: 150.0/255.0 , blue: 243.0/255.0, alpha:1.0)
    }
    
    class var dop_gold_color: UIColor {
        return UIColor( red: 255.0/255.0 , green: 222.0/255.0 , blue: 121.0/255.0, alpha:1.0)
    }
    
    class var dop_bronze_color: UIColor {
        return UIColor( red: 236.0/255.0 , green: 144.0/255.0 , blue: 71.0/255.0, alpha:1.0)
    }
    
    class var lightGrayColor: UIColor {
        return UIColor( red: 243.0/255.0 , green: 243.0/255.0 , blue: 243.0/255.0, alpha:1.0)
    }
    
    class var extraLightGrayColor: UIColor {
        return UIColor( red: 250.0/255.0 , green: 250.0/255.0 , blue: 250.0/255.0, alpha:1.0)
    }
    
    class var Colors:CAGradientLayer {
        let colorBottom = UIColor(red: 217.0/255.0, green: 4.0/255.0, blue: 121.0/255.0, alpha: 1.0).CGColor
        let colorTop = UIColor(red: 248.0/255.0, green: 20.0/255.0, blue: 90.0/255.0, alpha: 1.0).CGColor
        
        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        return gl
    }
    class var DarkColors:CAGradientLayer {
        let colorBottom = UIColor(red: 201.0/255.0, green: 4.0/255.0, blue: 107.0/255.0, alpha: 1.0).CGColor
        let colorTop = UIColor(red: 207.0/255.0, green: 17.0/255.0, blue: 74.0/255.0, alpha: 1.0).CGColor
        
        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0 ]
        
        return gl
    }

    
    class func roundValue(value:Double,numberOfPlaces:Double)->Double{
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(value * multiplier) / multiplier
        
        return rounded
    }
    
    class func loadDataFromURL(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(User.userToken, forHTTPHeaderField: "Authorization")

        let loadDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                    
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    class func sendDataToURL(url: NSURL, method: String,params: [String:AnyObject], completion: (data:NSData?,error:NSError?)->Void) {
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(User.userToken, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = method
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        } catch let error as NSError {
            let err = error
            request.HTTPBody = nil
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.dop", code: httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        task.resume()
    }

    class func downloadImage(urL:NSURL, completion: (data: NSData?,error: NSError?) -> Void) {
        
        NSURLSession.sharedSession().dataTaskWithURL(urL, completionHandler: { (data: NSData? , response: NSURLResponse?, error: NSError?) -> Void in
            if let responseError = error{
                completion(data: nil, error: responseError)
            }else{
                completion(data: NSData(data: data!),error: nil)
            }
        }).resume()
        
    }
    
    //FRIENDLY DATE FUNCTION
    class func friendlyDate(date:String) -> String{
        let separators = NSCharacterSet(charactersInString: "T.")
        let parts = date.componentsSeparatedByCharactersInSet(separators)
        let friendly_date = NSDate(dateString: "\(parts[0]) \(parts[1])").timeAgo
    
        return friendly_date
    }
    
    
    
    //CONSTANTS
    
    class var connectionError:String{
        return "Error de conexión de red. Comprueba tu conexión a internet."
    }
    
    //SHADOWS
    class func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.lightGrayColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 4
    }
    
    class func applyMaterialDesignShadow(button: UIButton) {
        button.layer.shadowColor = UIColor.darkGrayColor().CGColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
    }
    
    class func applySolidShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.lightGrayColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 1
    }
    
    //ANIMATIONS
    class func fadeInViewAnimation(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval){
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut,
            animations: {
                view.alpha = 1
                
            }, completion: nil)
    }
    class func fadeOutViewAnimation(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval){
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut,
            animations: {
                view.alpha = 0
                
            }, completion: nil)
    }
    
    class func fadeInFromBottomAnimation(view: UIView, delay: NSTimeInterval, duration: NSTimeInterval, yPosition: CGFloat){
        view.alpha = 0
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y += yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 1
        }), completion: nil)
    }
    
    class func fadeInFromTopAnimation(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval, yPosition:CGFloat){
        view.alpha = 0
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y -= yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 1
        }), completion:nil)
    }
    
    class func fadeOutToTopAnimation(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval, yPosition:CGFloat){
        let finalYPosition = view.frame.origin.y - yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion:{(value:Bool) in
            view.frame.origin.y += yPosition
        })
    }
    
    class func fadeOutToBottomAnimation(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval, yPosition:CGFloat){
        let finalYPosition = view.frame.origin.y + yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion:{ (value: Bool) in
            view.frame.origin.y -= yPosition
        })
    }
    class func fadeOutToBottomWithCompletion(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval, yPosition:CGFloat, completion: (value: Bool) -> Void){
        let finalYPosition = view.frame.origin.y + yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
            view.alpha = 0
        }), completion: { (value: Bool) in
            completion(value: true)
        })
    }
    
    class func permanentBounce(view:UIView, delay:NSTimeInterval, duration:NSTimeInterval){
        view.transform = CGAffineTransformMakeScale(0.9, 0.9)
        var bounce_delay:NSTimeInterval = 0
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
                view.alpha = 1
                view.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }), completion: { (value:Bool) in
            UIView.animateWithDuration(duration, delay: bounce_delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: [.CurveEaseInOut, .Repeat, .Autoreverse], animations: ({
                view.transform = CGAffineTransformMakeScale(1, 1)
                bounce_delay = 3
                //view.transform = CGAffineTransformIdentity
                
            }), completion: nil)
        })
    }
    
    class func slideFromBottomAnimation(view: UIView, delay: NSTimeInterval, duration: NSTimeInterval, yPosition: CGFloat){
        let finalYPosition = view.frame.origin.y
        view.frame.origin.y += yPosition
        
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .CurveEaseInOut, animations: ({
            view.frame.origin.y = finalYPosition
        }), completion: nil)
    }
    
    //spinner loader for buttons
    
    class func setButtonSpinner(sender: UIButton, spinner: MMMaterialDesignSpinner, spinner_size: CGFloat, spinner_width: CGFloat, spinner_color: UIColor) {
        let x = (sender.frame.width / 2) - (spinner_size / 2)
        let y = (sender.frame.height / 2) - (spinner_size / 2)
        spinner.frame = CGRectMake(x, y, spinner_size, spinner_size)
        spinner.lineWidth = spinner_width
        spinner.startAnimating()
        spinner.tintColor = spinner_color
        sender.addSubview(spinner)
    }
    
    // Material Design Button
    
    class func setMaterialDesignButton(button: UIButton, button_size: CGFloat) {
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button_size, button_size)
        button.layer.cornerRadius = button.frame.width / 2
        self.applyMaterialDesignShadow(button)
    }
}

/*
let time = NSDate(timeIntervalSince1970: timestamp).timeIntervalSinceNow
let relativeTimeString = NSDate.relativeTimeInString(time)
println(relativeTimeString)
*/
