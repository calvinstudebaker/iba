//
//  ConnectCarViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 4/29/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class ConnectCarViewController: UIViewController {
    
    let descriptionLabel: UILabel
    let kXPadding: CGFloat = 20
    let navigationBar: UINavigationBar
    let settingsButton: IBAButton
    let scrollView: UIScrollView
    
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
        self.scrollView = UIScrollView(frame: CGRectZero)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
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
    
    func setupNavigationBar() {
        self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        self.view.insertSubview(self.navigationBar, aboveSubview: self.scrollView)
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        let navItem = UINavigationItem(title: "Car Setup")
        navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonHit:")
        navItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        self.navigationBar.pushNavigationItem(navItem, animated: false)
    }
    
    func doneButtonHit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func goToSettings(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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
        
        self.settingsButton.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), 50)
        self.settingsButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(self.settingsButton)
        
        
        
    }
    
}