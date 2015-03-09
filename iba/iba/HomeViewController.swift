//
//  ViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 3/7/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var mapView: GMSMapView
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        mapView = GMSMapView(frame: CGRectZero)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        self.view.addSubview(mapView);
    }
    
    override func viewDidAppear(animated: Bool) {
    
        delay(5, { () -> () in
            self.presentViewController(MovingAlertViewController(), animated: true, completion: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

