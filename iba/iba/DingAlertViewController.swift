//
//  DingAlertViewController.swift
//  parq
//
//  Created by Raymond Kennedy on 5/25/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class DingAlertViewController: UIViewController {
    
    let kXPadding: CGFloat = 20
    let kButtonHeight: CGFloat = 50
    
    let scrollView: UIScrollView
    let navigationBar: UINavigationBar
    
    let dingImageView: UIImageView
    let falseAlarmButton: UIButton
    let reportDingButton: UIButton
    let dingDescriptionLabel: UILabel

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.dingImageView = UIImageView(image: UIImage(named: "audi_vector_dinged.png"))
        self.navigationBar = UINavigationBar(frame: CGRectZero)
        self.dingDescriptionLabel = UILabel(frame: CGRectZero)
        self.falseAlarmButton = IBAButton(frame: CGRectZero, title: "False Alarm", colorScheme: UIColor(red:0.5, green:0.55, blue:0.55, alpha:1), clear: true)
        self.reportDingButton = IBAButton(frame: CGRectZero, title: "Report Ding", colorScheme: UIColor(red:0.81, green:0.03, blue:0.07, alpha:1), clear: true)
        self.scrollView = UIScrollView(frame: CGRectZero)

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
        self.title = "Ding Alert"
        
        // Do any additional setup after loading the view.
        layoutSubviews();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup Methods
    
    func layoutSubviews() {
        
        var originY = self.navigationBar.bounds.size.height + kXPadding
        
        // Setup the description label
        let descriptionString = "We've detected a ding on your car in the highlighted area." as NSString
        let descriptionFont = UIFont(name: "HelveticaNeue-Light", size: 20)
        let descriptionSize = descriptionString.boundingRectWithSize(CGSizeMake(self.view.bounds.size.width - (kXPadding * 2), self.view.bounds.size.height),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: descriptionFont!],
            context: nil)
        
        self.dingDescriptionLabel.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), descriptionSize.height)
        self.dingDescriptionLabel.text = descriptionString as String
        self.dingDescriptionLabel.textColor = UIColor.blackColor()
        self.dingDescriptionLabel.font = descriptionFont
        self.dingDescriptionLabel.numberOfLines = 4
        self.dingDescriptionLabel.textAlignment = NSTextAlignment.Center
        self.scrollView.addSubview(self.dingDescriptionLabel)
        
        originY += kXPadding + descriptionSize.height
        
        self.dingImageView.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), self.view.bounds.size.width - (kXPadding * 2))
        self.dingImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.dingImageView.layer.borderWidth = 2
        self.dingImageView.layer.cornerRadius = 6
        self.scrollView.addSubview(self.dingImageView)
        
        originY += kXPadding + self.dingImageView.bounds.size.height
        
        self.reportDingButton.frame = CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
        self.reportDingButton.addTarget(self, action: "submitReport:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.reportDingButton)
        
        originY += kXPadding + self.reportDingButton.bounds.size.height
        
        self.falseAlarmButton.frame =  CGRectMake(kXPadding, originY, self.view.bounds.size.width - (kXPadding * 2), kButtonHeight)
        self.falseAlarmButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(self.falseAlarmButton)
        
    }
    
    // MARK: Private Methods
    
    func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
    func submitReport(sender: AnyObject) {
        
        // Show loading hud
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate

        let query = PFQuery(className: "Car")
        query.whereKey("objectId", equalTo: "CVBPW2AfQx")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            
            let array = result as NSArray?
            let dict = array!.objectAtIndex(0) as! PFObject
            let location = dict["location"] as! PFGeoPoint
            
            let location2d = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(location2d, completionHandler: { (response: GMSReverseGeocodeResponse!, error: NSError!) -> Void in
                hud.hide(true)
                let result: GMSAddress = response.firstResult()
                let streetName = result.thoroughfare!
                if (!streetName.isEmpty) {
                    let rvc = ReportViewController(type: .Ding, currentLocation: location2d, streetName: streetName)
                    self.navigationController!.pushViewController(rvc, animated: true)
                } else {
                    let alert = UIAlertController(title: "Whoops!", message: "We couldn't find your car location!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
                        
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
            })

            
            return
            
        }
        
        
    }
    
    

}
