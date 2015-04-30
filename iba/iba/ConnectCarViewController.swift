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
    let kXPadding: CGFloat = 10
    let navigationBar: UINavigationBar
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.descriptionLabel = UILabel(frame: CGRectZero)
        self.navigationBar = UINavigationBar(frame: CGRectZero)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        
        // Setup the navigation bar
        setupNavigationBar()
        
        // Setup the description label
        setupDescriptionLabel()
    }
    
    func setupNavigationBar() {
        self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        self.view.addSubview(self.navigationBar)
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
    
    func setupDescriptionLabel() {
        
        var originY = self.navigationBar.bounds.size.height
        
        self.descriptionLabel.frame = CGRectMake(kXPadding, originY + kXPadding, self.view.bounds.size.width - (kXPadding * 2), 100)
        self.descriptionLabel.text = "Want to connect your car? Go to settings and connect via Bluetooth!"
        self.descriptionLabel.textColor = UIColor.blackColor()
        self.descriptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        self.descriptionLabel.numberOfLines = 4
        self.descriptionLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.descriptionLabel)
        
        
    }
    
}