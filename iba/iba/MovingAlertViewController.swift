//
//  MovingAlertViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 3/8/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class MovingAlertViewController: UIViewController {
    
    var ignoreButton: UIButton;
    var trackButton: UIButton;
    var trackView: GMSMapView;
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        ignoreButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        trackButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        trackView = GMSMapView(frame: CGRectZero)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setUpIgnoreButton();
        self.setUpTrackButton();
        self.setUpTrackView();
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(ignoreButton);
        self.view.addSubview(trackButton);
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: set up ignore button properties
    func setUpIgnoreButton(){
        var buttonWidth = 100;
        ignoreButton.frame = CGRectMake(self.view.bounds.width/2 - CGFloat(buttonWidth)/2, 100, 100, 50)
        ignoreButton.backgroundColor = UIColor.lightGrayColor()
        ignoreButton.setTitle("Ignore", forState: UIControlState.Normal)
        ignoreButton.addTarget(self, action: "dismissMovingAlert:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //MARK: set up tracking button properties
    func setUpTrackButton(){
        var buttonWidth = 300;
        trackButton.frame = CGRectMake(self.view.bounds.width/2 - CGFloat(buttonWidth)/2, 200, CGFloat(buttonWidth), 50)
        trackButton.backgroundColor = UIColor.lightGrayColor()
        trackButton.setTitle("Track Vehicle", forState: UIControlState.Normal)
        trackButton.addTarget(self, action: "trackVehicle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //sets up trackView frame
    func setUpTrackView(){
        trackView.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
    }
    
    //MARK: ignores moving alert, returns to home map screen
    func dismissMovingAlert(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        println("ignored")
    }
    
    //MARK: adds track subview, allowing user to follow vehicle movement
    //TO DO: reset check if trackview subview already added
    func trackVehicle(sender: AnyObject) {
        trackView.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
        let subviews = self.view.subviews as NSArray
        if(!subviews.containsObject(trackView)){
            self.view.addSubview(trackView)
            println("tracking")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
