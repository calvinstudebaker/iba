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

class HomeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
    var mapView: GMSMapView
    var waypoints: NSMutableArray
    var waypointStrings: NSMutableArray
    
    let locationManager = CLLocationManager()
    let previousLocation: CLLocationCoordinate2D
    
    var currentOverlay: GMSGroundOverlay = GMSGroundOverlay()
    var currentPolyline: GMSPolyline = GMSPolyline()
    var currentMarker: GMSMarker = GMSMarker()
    
    let reportButton: IBAButton
    let shareButton: IBAButton
    let stopGuidanceButton: IBAButton
    let searchField: UITextField
    
    let kButtonPadding: CGFloat = 10
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        self.mapView = GMSMapView(frame: CGRectZero)
        self.previousLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        self.reportButton = IBAButton(frame: CGRectZero, title: "Report", colorScheme: UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1), clear: false)
        self.shareButton = IBAButton(frame: CGRectZero, title: "Share", colorScheme: UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1), clear: false)
        self.stopGuidanceButton = IBAButton(frame: CGRectZero, title: "X", colorScheme: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0), clear: false)
        self.searchField = UITextField(frame: CGRectZero)
        
        self.waypoints = NSMutableArray()
        self.waypointStrings = NSMutableArray()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Parq"
        
        setupMapView()
        setupLocationManager()
        setupReportButton()
        setupShareButton()
        setupStopGuidanceButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        delay(1.0, { () -> () in
            //            let rvc = ReportViewController()
            //            self.navigationController?.pushViewController(rvc, animated: true)
        })
        
        triggerLocationServices()
        
        if ((UIDevice.currentDevice().model as NSString).rangeOfString("Simulator").location != NSNotFound) {
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(37.75941, longitude: -122.4260365, zoom: 16))
        }
        
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
        
        // Add the text field to the top of the map view
        self.searchField.frame = CGRectMake(kButtonPadding, kButtonPadding + navBarHeight, self.view.bounds.size.width - (kButtonPadding * 2), 45)
        self.searchField.backgroundColor = UIColor.whiteColor()
        self.searchField.placeholder = "Enter Destination"
        self.searchField.textColor = UIColor.blackColor()
        self.searchField.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        
        // Add some padding
        let paddingView =  UIView(frame: CGRectMake(0, 0, 10, 45))
        self.searchField.leftView = paddingView
        self.searchField.leftViewMode = .Always
        
        // Add borders
        self.searchField.layer.cornerRadius = 6.0
        self.searchField.layer.masksToBounds = true
        self.searchField.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.searchField.layer.borderWidth = 1.25
        self.searchField.alpha = 0.95
        self.searchField.delegate = self
        self.searchField.returnKeyType = .Done
        self.view.addSubview(self.searchField)
    }
    
    func setupReportButton() {
        self.reportButton.frame = CGRectMake(self.view.bounds.size.width - kButtonPadding - 100, self.view.bounds.size.height - kButtonPadding - 45, 100, 45)
        self.reportButton.backgroundColor = UIColor.whiteColor()
        self.reportButton.addTarget(self, action: "reportButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.reportButton)
    }
    
    func setupShareButton() {
        self.shareButton.frame = CGRectMake(kButtonPadding, self.view.bounds.size.height - kButtonPadding - 45, 80, 45)
        self.shareButton.backgroundColor = UIColor.whiteColor()
        self.shareButton.addTarget(self, action: "shareButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.shareButton)
    }
    
    func setupStopGuidanceButton() {
        self.stopGuidanceButton.frame = CGRectMake(kButtonPadding, self.searchField.frame.origin.y + self.searchField.frame.size.height + kButtonPadding, 50, 50)
        self.stopGuidanceButton.backgroundColor = UIColor.whiteColor()
        self.stopGuidanceButton.addTarget(self, action: "stopGuidance:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.stopGuidanceButton)
        self.stopGuidanceButton.hidden = true;
        self.stopGuidanceButton.alpha = 0.0;
    }
    
    // Sets up the locationManager
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10
    }
    
    // MARK: Private Methods
    
    func reportButtonPressed(sender: UIButton) {
        let rvc = ReportViewController()
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    // TODO: Implement Share Features @leigh
    func shareButtonPressed(sender: UIButton) {
        println("share")
    }
    
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
    
    // MARK: Direction Stuffs
    
    func addDirections(json: NSDictionary) {        
        let routesArray = (json.objectForKey("routes") as! NSArray)
        if routesArray.count == 0 {
            // Couldn't find route
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = "Couldn't find a route to the destination."
            hud.hide(true, afterDelay: 1.0)
            return
        }
        
        let routes: NSDictionary = (json.objectForKey("routes") as! NSArray)[0] as! NSDictionary
        let route: NSDictionary = routes.objectForKey("overview_polyline") as! NSDictionary
        let overview_route: String = route.objectForKey("points") as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: overview_route)
        self.currentPolyline = GMSPolyline(path: path)
        self.currentPolyline.strokeWidth = 3.5
        self.currentPolyline.strokeColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        self.currentPolyline.map = self.mapView
        
        var bounds = GMSCoordinateBounds(path: path)
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
        self.stopGuidanceButton.alpha = 0.0
        self.stopGuidanceButton.hidden = false
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.stopGuidanceButton.alpha = 1.0
        })
    }
    
    func stopGuidance(sender: IBAButton) {
        self.currentMarker.map = nil
        self.currentPolyline.map = nil
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.stopGuidanceButton.alpha = 0.0
        }) { (completion: Bool) -> Void in
            self.stopGuidanceButton.hidden = true
        }
    }
    
    func createRouteToDestination(destination: CLLocation) {

        // Clear the previous destination
        self.currentPolyline.map = nil
        self.currentMarker.map = nil
        
        let fromLocation: CLLocation
        
        // If we are using the simulator fake a start point
        if ((UIDevice.currentDevice().model as NSString).rangeOfString("Simulator").location == NSNotFound) {
            fromLocation = self.locationManager.location
        } else {
            fromLocation = CLLocation(latitude: 37.4203696428215, longitude: -122.170106303061)
        }
        
        self.currentMarker = GMSMarker(position: destination.coordinate)
        self.currentMarker.map = self.mapView
        self.waypoints.addObject(self.currentMarker)
        let toPositionString: String = "\(destination.coordinate.latitude), \(destination.coordinate.longitude)"
        let fromPositionString: String = "\(fromLocation.coordinate.latitude), \(fromLocation.coordinate.longitude)"
        
        self.waypointStrings.removeAllObjects()
        self.waypointStrings.addObject(toPositionString)
        self.waypointStrings.addObject(fromPositionString)
        
        if (self.waypointStrings.count > 1) {
            let sensor: String = "false"
            let parameters: NSArray = NSArray(objects: sensor, self.waypointStrings)
            let keys: NSArray = NSArray(objects: "sensor", "waypoints")
            let query: NSDictionary = NSDictionary(objects: parameters as [AnyObject], forKeys: keys as [AnyObject])
            let mds: MDDirectionService = MDDirectionService()
            mds.setDirectionsQuery(query as [NSObject : AnyObject], withSelector: "addDirections:", withDelegate: self)
            
        }

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
            
            let location: PFGeoPoint = crime["location"] as! PFGeoPoint
            let weight: NSNumber = NSNumber(double: crime["weight"] as! Double)
            let convertedPoint = self.mapView.projection.pointForCoordinate(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            points.addObject(NSValue(CGPoint: convertedPoint))
            weights.addObject(weight)
            
        }
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        heatmapImage = LFHeatMap.heatMapWithRect(self.mapView.bounds, boost: 1.0, points: points as [AnyObject], weights: weights as [AnyObject])
        self.currentOverlay = GMSGroundOverlay(position: self.mapView.projection.coordinateForPoint(CGPointMake(self.mapView.center.x, self.mapView.center.y - navBarHeight)), icon: heatmapImage, zoomLevel: CGFloat(self.mapView.camera.zoom))
        self.currentOverlay.bearing = self.mapView.camera.bearing
        self.currentOverlay.map = self.mapView
        
    }
    
    
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        //        println("Updating Current Location...")
        //
        //        let currentLocation: CLLocation = (locations as NSArray).lastObject as! CLLocation
        //        let positionString: String = "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)"
        //
        //        // Clear the waypoint strings
        //        if (self.waypointStrings.count == 1) {
        //            self.waypointStrings.removeAllObjects()
        //        }
        //
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        var alert = UIAlertController(title: "Whoops!", message: "Couldn't get location", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
            self.drawHeatMapWith(crimes: response as! NSArray?)
        })
    }
    
    // MARK: UITextfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Search query: \(self.searchField.text)")
        self.searchField.resignFirstResponder()
        
        if (self.searchField.text == "") {
            return true
        }
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Searching for " + self.searchField.text
        
        
        IBANetworking.searchForDestination(self.searchField.text, completion: { (complete, location) -> () in
            if complete {
                hud.hide(true)
                self.createRouteToDestination(location!)
            } else {
                // Show an error
                hud.mode = .Text
                hud.labelText = "Couldn't find anything for " + self.searchField.text
                hud.hide(true, afterDelay: 1.0)
            }
        })
        
        return true
    }
    
}

