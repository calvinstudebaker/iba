//
//  ReportViewController.swift
//  iba
//
//  Created by Raymond kennedy on 4/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    let kRateItemHeight: CGFloat = 90
    let kRateItemPadding: CGFloat = 20
    
    let easeRateItem: IBARateItemView
    let damageRateItem: IBARateItemView
    let spotPriceRateItem: IBARateItemView
    let ticketPriceRateItem: IBARateItemView
    
    let scrollView: UIScrollView
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        // Setup the rate items
        self.easeRateItem = IBARateItemView(title: "Ease of parking", lowText: "easy", highText: "hard")
        self.damageRateItem = IBARateItemView(title: "Damage to vehicle", lowText: "none", highText: "lots")
        self.spotPriceRateItem = IBARateItemView(title: "Price of spot", lowText: "free", highText: "expensive")
        self.ticketPriceRateItem = IBARateItemView(title: "Price of ticket", lowText: "free", highText: "$100+")
        
        self.scrollView = UIScrollView(frame: CGRectZero)
        self.scrollView.alwaysBounceVertical = true
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        
        self.title = "Report"
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        var originY = 0 as CGFloat
        
        
        // Configure the frames for the rateitems
        self.easeRateItem.frame = CGRectMake(kRateItemPadding, originY + kRateItemPadding, self.view.frame.size.width - (kRateItemPadding * 2), kRateItemHeight)
        self.easeRateItem.userInteractionEnabled = true

        originY += kRateItemPadding + kRateItemHeight
        
        self.damageRateItem.frame = CGRectMake(kRateItemPadding, originY + kRateItemPadding, self.view.frame.size.width - (kRateItemPadding * 2), kRateItemHeight)
        self.damageRateItem.userInteractionEnabled = true
        
        originY += kRateItemPadding + kRateItemHeight
        
        self.spotPriceRateItem.frame = CGRectMake(kRateItemPadding, originY + kRateItemPadding, self.view.frame.size.width - (kRateItemPadding * 2), kRateItemHeight)
        self.spotPriceRateItem.userInteractionEnabled = true
        
        originY += kRateItemPadding + kRateItemHeight
        
        self.ticketPriceRateItem.frame = CGRectMake(kRateItemPadding, originY + kRateItemPadding, self.view.frame.size.width - (kRateItemPadding * 2), kRateItemHeight)
        self.ticketPriceRateItem.userInteractionEnabled = true

        self.scrollView.frame = self.view.frame
        
        // Add them as subviews
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.easeRateItem)
        self.scrollView.addSubview(self.damageRateItem)
        self.scrollView.addSubview(self.spotPriceRateItem)
        self.scrollView.addSubview(self.ticketPriceRateItem)
        
        // Turn off back gestures
        self.navigationController?.interactivePopGestureRecognizer.enabled = false

        
        // Set background color
        self.view.backgroundColor = UIColor.whiteColor()
    }
}
