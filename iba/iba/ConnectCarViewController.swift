//
//  ConnectCarViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 4/29/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class ConnectCarViewController: UIViewController {
    
    let kXPadding: CGFloat = 20
    let kButtonHeight: CGFloat = 50
    
    let scrollView: UIScrollView
    let navigationBar: UINavigationBar

    let descriptionLabel: UILabel
    let settingsButton: IBAButton
    let doneButton: IBAButton
    let disconnectButton: IBAButton
    let carVectorImageView: UIImageView
    let carDescriptionLabel: UILabel
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.descriptionLabel = UILabel(frame: CGRectZero)
        self.navigationBar = UINavigationBar(frame: CGRectZero)
        self.settingsButton = IBAButton(frame: CGRectZero, title: "Settings", colorScheme: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0), clear: true)
        self.doneButton = IBAButton(frame: CGRectZero, title: "Connected", colorScheme:  UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1.0), clear: true)
        self.scrollView = UIScrollView(frame: CGRectZero)
        self.carVectorImageView = UIImageView(frame: CGRectZero)
        self.carDescriptionLabel = UILabel(frame: CGRectZero)
        self.disconnectButton = IBAButton(frame: CGRectZero, title: "Disconnect Car", colorScheme: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0), clear: true)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.backgroundColor = UIColor.whiteColor()
        self.scrollView.alwaysBounceVertical = true
        self.view.addSubview(self.scrollView)
        
        // Setup the navigation bar
        setupNavigationBar()
        
        // Setup the description label
        layoutSubviews()
        
    }
    
    // MARK: Setup Methods
    
    func setupNavigationBar() {
        self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        self.view.insertSubview(self.navigationBar, aboveSubview: self.scrollView)
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        let navItem = UINavigationItem(title: "Car Setup")
        navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonHit:")
        navItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationBar.pushNavigationItem(navItem, animated: false)
    }
    
    func layoutSubviews() {
        
        var originY = self.navigationBar.bounds.size.height + kXPadding
        
        if ((NSUserDefaults.standardUserDefaults().valueForKey("CarConnected")) == nil) {
            let descriptionString = "Want to connect your car? Go to settings and connect via Bluetooth!" as NSString
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
            //        self.descriptionLabel.backgroundColor = UIColor.lightGrayColor()
            self.scrollView.addSubview(self.descriptionLabel)
            
            originY += kXPadding + descriptionSize.height
            
            self.settingsButton.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
            self.settingsButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchUpInside)
            self.scrollView.addSubview(self.settingsButton)
            
            originY += kXPadding + self.settingsButton.bounds.size.height
            
            self.doneButton.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
            self.doneButton.addTarget(self, action: "connectedCar:", forControlEvents: UIControlEvents.TouchUpInside)
            self.scrollView.addSubview(self.doneButton)
            
        } else {
            
            let carVector = UIImage(named: "audi_vector.png")
            self.carVectorImageView.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), self.view.bounds.size.width - (kXPadding * 2))
            self.carVectorImageView.image = carVector
            self.carVectorImageView.layer.borderColor = UIColor.blackColor().CGColor
            self.carVectorImageView.layer.borderWidth = 2
            self.carVectorImageView.layer.cornerRadius = 6
            self.scrollView.addSubview(self.carVectorImageView)
            
            // Add the disconnect button
            self.disconnectButton.frame = CGRectMake(kXPadding, self.view.bounds.size.height - kButtonHeight - kXPadding, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
            self.scrollView.addSubview(self.disconnectButton)
            self.disconnectButton.addTarget(self, action: "disconnectCar:", forControlEvents: .TouchUpInside)
            
            originY += kXPadding + self.carVectorImageView.bounds.size.height
            
            // Add the car description label
            let descriptionString = "2015 Audi R8" as NSString
            let descriptionFont = UIFont(name: "HelveticaNeue-Light", size: 20)
            let descriptionSize = descriptionString.boundingRectWithSize(CGSizeMake(self.view.bounds.size.width - (kXPadding * 2), self.view.bounds.size.height),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: descriptionFont!],
                context: nil)
            self.carDescriptionLabel.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), descriptionSize.height)
            self.carDescriptionLabel.text = descriptionString as String
            self.carDescriptionLabel.textColor = UIColor.blackColor()
            self.carDescriptionLabel.font = descriptionFont
            self.carDescriptionLabel.numberOfLines = 4
            self.carDescriptionLabel.textAlignment = .Center
            self.scrollView.addSubview(self.carDescriptionLabel)
            
        }
    }
    
    func disconnectCar(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "CarConnected")
        refreshViews(self)
    }
    
    func connectedCar(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "CarConnected");
        refreshViews(self)
    }
    
    func refreshViews(sender: AnyObject) {
        self.carVectorImageView.removeFromSuperview()
        self.descriptionLabel.removeFromSuperview()
        self.settingsButton.removeFromSuperview()
        self.doneButton.removeFromSuperview()
        self.carDescriptionLabel.removeFromSuperview()
        self.disconnectButton.removeFromSuperview()
        layoutSubviews()
    }
    
    // MARK: Private Methods
    
    func doneButtonHit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func goToSettings(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
}