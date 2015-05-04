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
        self.doneButton.addTarget(self, action: "refreshViews", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(self.doneButton)
        
    }
    
    func refreshViews(sender: AnyObject) {
        
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