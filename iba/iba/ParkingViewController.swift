//
//  ParkingViewController.swift
//  parq
//
//  Created by Raymond kennedy on 6/3/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

/**
A UIViewController presented when the device receives the isParked message.
Features a UILabel with the parking meter timer (if the user would like to set a 
location push notification for when the parking meter timer runs out).
*/
class ParkingViewController: UIViewController {

    let kXPadding: CGFloat = 20
    let kButtonHeight: CGFloat = 50
    
    let scrollView: UIScrollView
    let descriptionLabel: UILabel
    let noThanksButton: IBAButton
    let setTimeButton: IBAButton
    let incrementButton: IBAButton
    let decrementButton: IBAButton
    
    let timeLabel: UILabel
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.scrollView = UIScrollView(frame: CGRectZero)
        self.descriptionLabel = UILabel(frame: CGRectZero)
        
        self.noThanksButton = IBAButton(frame: CGRectZero, title: "No Thanks", colorScheme: UIColor(red:0.5, green:0.55, blue:0.55, alpha:1), clear: true)
        self.setTimeButton = IBAButton(frame: CGRectZero, title: "Set Time", colorScheme: UIColor(red:0.18, green:0.8, blue:0.44, alpha:1), clear: true)
        self.incrementButton = IBAButton(frame: CGRectZero, title: "+", colorScheme: UIColor(red:0.2, green:0.6, blue:0.86, alpha:1), clear: true)
        self.decrementButton = IBAButton(frame: CGRectZero, title: "-", colorScheme: UIColor(red:0.91, green:0.3, blue:0.24, alpha:1), clear: true)
        self.timeLabel = UILabel(frame: CGRectZero)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.alwaysBounceVertical = true
        self.view.addSubview(self.scrollView)
        
        // Setup the navigation bar
        self.title = "Parking"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        layoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func layoutSubviews() {
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        var originY = kXPadding
        
        // Setup the description label
        let descriptionString = "We've detected you parked your car. Would you like to add time to the meter? We'll notify you when time is running out." as NSString
        let descriptionFont = UIFont(name: "HelveticaNeue-Light", size: 20)
        let descriptionSize = descriptionString.boundingRectWithSize(CGSizeMake(self.view.bounds.size.width - (kXPadding * 2), self.view.bounds.size.height),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: descriptionFont!],
            context: nil)
        
        self.descriptionLabel.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), descriptionSize.height)
        self.descriptionLabel.text = descriptionString as String
        self.descriptionLabel.textColor = UIColor.blackColor()
        self.descriptionLabel.font = descriptionFont
        self.descriptionLabel.numberOfLines = 4
        self.descriptionLabel.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(self.descriptionLabel)
        
        originY += kXPadding + self.descriptionLabel.bounds.size.height
        
        self.timeLabel.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), 80)
        self.timeLabel.font = UIFont(name: "HelveticaNeue-Light", size: 80)
        self.timeLabel.text = "00:00"
        self.timeLabel.textColor = UIColor.darkGrayColor()
        self.timeLabel.numberOfLines = 1
        self.timeLabel.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(self.timeLabel)
        
        originY += kXPadding + self.timeLabel.bounds.size.height
        
        self.decrementButton.frame = CGRectMake(kXPadding, originY, kButtonHeight, kButtonHeight)
        self.decrementButton.addTarget(self, action: "decrementTime:", forControlEvents: .TouchUpInside)
        self.incrementButton.frame = CGRectMake(self.view.bounds.size.width - kXPadding - kButtonHeight, originY, kButtonHeight, kButtonHeight)
        self.incrementButton.addTarget(self, action: "incrementTime:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.decrementButton)
        self.scrollView.addSubview(self.incrementButton)
        
        self.setTimeButton.frame = CGRectMake(kXPadding, self.view.bounds.size.height - navBarHeight - (kXPadding * 2) - (kButtonHeight * 2), self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
        self.setTimeButton.addTarget(self, action: "setTime:", forControlEvents: .TouchUpInside)
        self.noThanksButton.frame = CGRectMake(kXPadding, self.view.bounds.size.height - navBarHeight - kXPadding - kButtonHeight, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
        self.noThanksButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.setTimeButton)
        self.scrollView.addSubview(self.noThanksButton)
        
    }
    
    func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    /**
    Once the user has adjusted the timer to the correct time, they hit the "set time" button and this function is called.
    
    :param: sender The button who calls the selector
    */
    func setTime(sender: AnyObject) {
        let currentTime = self.timeLabel.text!
        var hours = currentTime[0...1].toInt()!
        var minutes = currentTime[3...4].toInt()!
        
        var totalMinutes = minutes + (hours * 60)
        
        if totalMinutes == 0 {
            let alert = UIAlertController(title: "Whoops!", message: "The set time is 00:00 -- you're going to get a ticket", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it.", style: UIAlertActionStyle.Cancel, handler: nil))
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        println("Setting meter to \(totalMinutes) minutes.")
        
        let pushTimeInterval: NSTimeInterval = NSTimeInterval((totalMinutes - 5) * 60)
        let timeInterval: NSTimeInterval = NSTimeInterval(totalMinutes * 60)
        
        let endDate = NSDate().dateByAddingTimeInterval(timeInterval)
        let pushDate = NSDate().dateByAddingTimeInterval(pushTimeInterval)
        
        NSUserDefaults.standardUserDefaults().setValue(endDate, forKey: PARKING_METER_END_DATE)
        
        var notification = UILocalNotification() // create a new reminder notification
        notification.alertBody = "Reminder: your meter runs out in 5 minutes." // text that will be displayed in the notification
        notification.fireDate = pushDate // 30 minutes from current time
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["custom": "PARKING_REMINDER"] // assign a unique identifier to the notification that we can use to retrieve it later
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        dismiss(self)
        
    }
    
    /**
    Decrements the timer by 15 minutes
    
    :param: sender The button who calls the selector
    */
    func decrementTime(sender: AnyObject) {
        
        let currentTime = self.timeLabel.text!
        
        var hours = currentTime[0...1].toInt()!
        var minutes = currentTime[3...4].toInt()!
        
        if (minutes == 0) {
            if (hours != 0) {
                hours--
                minutes = 45
            }
        } else {
            minutes -= 15
        }
        
        var hoursString = String(format: "%02d", hours)
        var minutesString = String(format: "%02d", minutes)
        
        if count(hoursString) == 1 {
            hoursString += "0"
        }
        
        if count(minutesString) == 1 {
            minutesString += "0"
        }
        
        let newTime = "\(hoursString):\(minutesString)"
        self.timeLabel.text = newTime
        
    }
    
    /**
    Increments the timer by 15 minutes
    
    :param: sender The button who calls the selector
    */
    func incrementTime(sender: AnyObject) {
        let currentTime = self.timeLabel.text!
        
        var hours = currentTime[0...1].toInt()!
        var minutes = currentTime[3...4].toInt()!
        
        minutes += 15
        
        if (minutes >= 60) {
            minutes = 0
            hours++
        }
        
        var hoursString = String(format: "%02d", hours)
        var minutesString = String(format: "%02d", minutes)
        
        if count(hoursString) == 1 {
            hoursString += "0"
        }
        
        if count(minutesString) == 1 {
            minutesString += "0"
        }

        let newTime = "\(hoursString):\(minutesString)"
        self.timeLabel.text = newTime
        
    }

}
