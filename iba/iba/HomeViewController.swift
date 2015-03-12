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
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "IBA Parking"
        
        setupMapView()
        setupLocationManager()
    }
    
    override func viewDidAppear(animated: Bool) {
//                delay(2, { () -> () in
//                    self.presentViewController(MovingAlertViewController(), animated: true, completion: nil)
//                })
    
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
        
        heatmapImage = LFHeatMap.heatMapWithRect(self.mapView.frame, boost: 1.0, points: points, weights: weights)
        self.currentOverlay = GMSGroundOverlay(position: self.mapView.projection.coordinateForPoint(self.mapView.center), icon: heatmapImage, zoomLevel: CGFloat(self.mapView.camera.zoom))
        self.currentOverlay.bearing = self.mapView.camera.bearing
        self.currentOverlay.map = self.mapView
        println("image generated")
        
    }
    
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var alert = UIAlertController(title: "Whoops!", message: "Couldn't get location", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .Authorized || status == .AuthorizedWhenInUse {
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

