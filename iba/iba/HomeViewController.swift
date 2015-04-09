//
//  ViewController.swift
//  iba
//
//  Created by Raymond Kennedy on 3/7/15.
//  Copyright (c) 2015 Raymond Kennedy. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class HomeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var mapView: GMSMapView
    let locationManager = CLLocationManager()
    let previousLocation: CLLocationCoordinate2D
    var currentOverlay: GMSGroundOverlay = GMSGroundOverlay()
    let reportButton: IBAButton
    
    let kButtonPadding: CGFloat = 10
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.mapView = GMSMapView(frame: CGRectZero)
        self.previousLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        self.reportButton = IBAButton(frame: CGRectZero, title: "Report", colorScheme: UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1), clear: false)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Parq"
        
        setupMapView()
        setupLocationManager()
        setupReportButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        delay(1.0, { () -> () in
//            let rvc = ReportViewController()
//            self.navigationController?.pushViewController(rvc, animated: true)
        })
        
        triggerLocationServices()
        
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(37.75941, longitude: -122.4260365, zoom: 16))
        
    }
    
    deinit {
        self.locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup Methods
    
    func setupMapView() {
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        mapView.frame = CGRectMake(0, navBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - navBarHeight);
        mapView.myLocationEnabled = true
        mapView.delegate = self
        self.view.addSubview(mapView);
    }
    
    func setupReportButton() {
        self.reportButton.frame = CGRectMake(self.view.bounds.size.width - kButtonPadding - 150, self.view.bounds.size.height - kButtonPadding - 45, 150, 45)
        self.reportButton.backgroundColor = UIColor.whiteColor()
        self.reportButton.addTarget(self, action: "reportButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.reportButton)
    }
    
    func reportButtonPressed(sender: UIButton) {
        let rvc = ReportViewController()
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    // Sets up the locationManager
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: Private Methods
    
    func triggerLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                startUpdatingLocation()
            }
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func displayErrorWithMessage(message: String) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.labelText = message
        hud.hide(true, afterDelay: 1.0)
        hud.userInteractionEnabled = false
    }
    
    // MARK: HeatMap Drawing
    
    func drawHeatMapWith(#crimes: NSArray?) {
        
        self.currentOverlay.map = nil;
        
        if (crimes == nil || crimes!.count == 0) {
            displayErrorWithMessage("No Crimes in this region!")
            return
        }
        
        var heatmapImage: UIImage
        var points: NSMutableArray = NSMutableArray()
        var weights: NSMutableArray = NSMutableArray()
        
        for crime in crimes! {
            
            let location: PFGeoPoint = crime["location"] as PFGeoPoint
            let weight: NSNumber = NSNumber(double: crime["weight"] as Double)
            let convertedPoint = self.mapView.projection.pointForCoordinate(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            points.addObject(NSValue(CGPoint: convertedPoint))
            weights.addObject(weight)
            
        }
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        heatmapImage = LFHeatMap.heatMapWithRect(self.mapView.bounds, boost: 1.0, points: points, weights: weights)
        self.currentOverlay = GMSGroundOverlay(position: self.mapView.projection.coordinateForPoint(CGPointMake(self.mapView.center.x, self.mapView.center.y - navBarHeight)), icon: heatmapImage, zoomLevel: CGFloat(self.mapView.camera.zoom))
        self.currentOverlay.bearing = self.mapView.camera.bearing
        self.currentOverlay.map = self.mapView
        
    }
    
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
//        var alert = UIAlertController(title: "Whoops!", message: "Couldn't get location", preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    // MARK: GMSMapViewDelegate Methods
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        IBANetworking.crimesInRegion(self.mapView.projection.visibleRegion(), completion: {response, error in
            println("\(response)")
            self.drawHeatMapWith(crimes: response as NSArray?)
        })
    }
    
}

