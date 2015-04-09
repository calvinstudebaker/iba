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
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        
        self.title = "Report"
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        var originY = navBarHeight
        
        // Configure the frames for the rateitems
        self.easeRateItem.frame = CGRectMake(kRateItemPadding, originY + kRateItemPadding, self.view.frame.size.width - (kRateItemPadding * 2), kRateItemHeight)
        self.easeRateItem.userInteractionEnabled = true
        
        // Add them as subviews
        self.view.addSubview(self.easeRateItem)
        
        // Set background color
        self.view.backgroundColor = UIColor.whiteColor()
    }
}
