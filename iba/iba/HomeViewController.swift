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

/**
Where the majority of the work gets done. The starting point for the application.
*/
class HomeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
    // The main GMSMapView behind everything
    var mapView: GMSMapView
    
    // The waypoints for the current navigation
    var waypoints: NSMutableArray
    var waypointStrings: NSMutableArray
    
    // The location manager to update the user's location
    let locationManager = CLLocationManager()
    
    // The last location we have recorded for the user
    let previousLocation: CLLocationCoordinate2D
    
    // The actual heat map overlay
    var currentOverlay: GMSGroundOverlay = GMSGroundOverlay()
    
    // The route for current navigation
    var currentPolyline: GMSPolyline = GMSPolyline()

    // The marker for your car
    var carMarker: GMSMarker = GMSMarker()

    // The marker for your phone location
    var currentMarker: GMSMarker = GMSMarker()
    
    // Some buttons
    let reportButton: IBAButton
    let shareButton: IBAButton
    let stopGuidanceButton: IBAButton
    
    // Search field for directions
    let searchField: UITextField
    
    // Segmented control just below navigation bar
    let segment: UISegmentedControl
    
    var currentFilter: String = "crimes"
    
    // Some constants for view setup
    let kButtonPadding: CGFloat = 10
    let kButtonHeight: CGFloat = 45
    let kButtonWidth: CGFloat = 80
    
    // Parking meter timer views (if present)
    let parkingMeterTimerLabel: UILabel
    let parkingMeterTimerBackground: UIView
    var parkingMeterInterval: NSTimeInterval
    
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
        self.segment = UISegmentedControl(items: ["Crimes", "Tickets", "Price"])
        
        self.parkingMeterTimerLabel = UILabel(frame: CGRectZero)
        self.parkingMeterTimerBackground = UIView(frame: CGRectZero)
        self.parkingMeterInterval = 0
        
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
        setupNavIcon()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "carStatusChanged", name: CAR_STATUS_CHANGED, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        triggerLocationServices()
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(PARKED_LOCATION_LAT) != nil) {
            
            carStatusChanged()
            return
        } else {
            self.parkingMeterTimerLabel.removeFromSuperview()
            self.parkingMeterTimerBackground.removeFromSuperview()
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: PARKING_METER_END_DATE)
        }
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("LastLat") != nil) {
            
            let lastLat = NSUserDefaults.standardUserDefaults().valueForKey("LastLat") as! CLLocationDegrees
            let lastLon = NSUserDefaults.standardUserDefaults().valueForKey("LastLon") as! CLLocationDegrees
            
            let lastCoordinate = CLLocationCoordinate2D(latitude: lastLat, longitude: lastLon)
            let lastZoom = NSUserDefaults.standardUserDefaults().valueForKey("LastZoom") as! Float
            let lastBearing = NSUserDefaults.standardUserDefaults().valueForKey("LastBearing") as! CLLocationDirection
            let lastViewingAngle = NSUserDefaults.standardUserDefaults().valueForKey("LastViewingAngle") as! Double
            
            let lastCameraPosition: GMSCameraPosition = GMSCameraPosition(target: lastCoordinate, zoom: lastZoom, bearing: lastBearing, viewingAngle: lastViewingAngle)
            self.mapView.animateToCameraPosition(lastCameraPosition)
            
        } else {
            
            let model: NSString = UIDevice.currentDevice().model as NSString
            if (model.isEqualToString("iPhone Simulator")) {
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(37.75941, longitude: -122.4260365, zoom: 16))
            } else {
                if (self.locationManager.location != nil) {
                    self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(self.locationManager.location.coordinate, zoom: 16))
                } else {
                    self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(37.75941, longitude: -122.4260365, zoom: 16))
                }
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Get the current camera location and store it in NSUserDefaults
        let lastLat = self.mapView.camera.target.latitude
        let lastLon = self.mapView.camera.target.longitude
        let lastZoom = self.mapView.camera.zoom
        let lastBearing = self.mapView.camera.bearing
        let lastViewingAngle = self.mapView.camera.viewingAngle
        
        NSUserDefaults.standardUserDefaults().setValue(lastLat, forKey: "LastLat")
        NSUserDefaults.standardUserDefaults().setValue(lastLon, forKey: "LastLon")
        NSUserDefaults.standardUserDefaults().setValue(lastZoom, forKey: "LastZoom")
        NSUserDefaults.standardUserDefaults().setValue(lastBearing, forKey: "LastBearing")
        NSUserDefaults.standardUserDefaults().setValue(lastViewingAngle, forKey: "LastViewingAngle")
        
    }
    
    deinit {
        self.locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup Methods
    
    /**
    Setup the navbar icon with car image in the upper left
    */
    func setupNavIcon() {
        var carImage: UIImage? = UIImage(named: "car_nav_icon")
        carImage = carImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        var carButton = UIBarButtonItem(image: carImage, style: UIBarButtonItemStyle.Done, target: self, action: "connectCar:")
        navigationItem.leftBarButtonItem = carButton
    }
    
    
    /**
    Setup the map view including the map, search text field, and GMSMarkers
    */
    func setupMapView() {
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        mapView.frame = CGRectMake(0, navBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - navBarHeight);
        mapView.myLocationEnabled = true
        mapView.delegate = self
        self.view.addSubview(mapView);
        
        var originY = navBarHeight + kButtonPadding
        self.segment.frame = CGRectMake(kButtonPadding, originY, self.view.bounds.size.width - (kButtonPadding * 2), 30)
        let whiteView = UIView(frame: self.segment.frame)
        whiteView.backgroundColor = UIColor.whiteColor()
        whiteView.userInteractionEnabled = false
        whiteView.layer.cornerRadius = 4.0
        self.view.addSubview(whiteView)
        self.view.addSubview(self.segment)
        self.segment.selectedSegmentIndex = 0
        self.segment.addTarget(self, action: "segmentHit:", forControlEvents: UIControlEvents.ValueChanged)
        
        originY += kButtonPadding + self.segment.bounds.size.height
        
        // Add the text field to the top of the map view
        self.searchField.frame = CGRectMake(kButtonPadding, originY, self.view.bounds.size.width - (kButtonPadding * 2), 45)
        self.searchField.backgroundColor = UIColor.whiteColor()
        self.searchField.placeholder = "Enter Destination"
        self.searchField.textColor = UIColor.blackColor()
        self.searchField.font = UIFont(name: "HelveticaNeue", size: 17)
        
        // Add some padding
        let paddingView =  UIView(frame: CGRectMake(0, 0, 10, 45))
        self.searchField.leftView = paddingView
        self.searchField.leftViewMode = .Always
        
        // Add borders
        self.searchField.layer.cornerRadius = 6.0
        self.searchField.layer.masksToBounds = true
        self.searchField.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.searchField.layer.borderWidth = 1.25
        self.searchField.alpha = 0.98
        self.searchField.delegate = self
        self.searchField.returnKeyType = .Done
        self.view.addSubview(self.searchField)
        
        self.carMarker = GMSMarker(position: CLLocationCoordinate2DMake(0, 0))
        self.carMarker.rotation = 0
        self.carMarker.icon = UIImage(named: "car_icon.png")!
        self.carMarker.snippet = "your parked car"
        self.carMarker.map = nil
        
    }
    
    /**
    Setup the report button
    */
    func setupReportButton() {
        self.reportButton.frame = CGRectMake(self.view.bounds.size.width - kButtonPadding - kButtonWidth, self.view.bounds.size.height - kButtonPadding - 45, kButtonWidth, 45)
        self.reportButton.backgroundColor = UIColor.whiteColor()
        self.reportButton.addTarget(self, action: "reportButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.reportButton)
    }
    
    /**
    Setup the share button
    */
    func setupShareButton() {
        self.shareButton.frame = CGRectMake(kButtonPadding, self.view.bounds.size.height - kButtonPadding - 45, kButtonWidth, 45)
        self.shareButton.backgroundColor = UIColor.whiteColor()
        self.shareButton.addTarget(self, action: "shareButtonPressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.shareButton)
    }
    
    /**
    Setup stop guidance button
    */
    func setupStopGuidanceButton() {
        self.stopGuidanceButton.frame = CGRectMake(kButtonPadding, self.searchField.frame.origin.y + self.searchField.frame.size.height + kButtonPadding, 50, 50)
        self.stopGuidanceButton.backgroundColor = UIColor.whiteColor()
        self.stopGuidanceButton.addTarget(self, action: "stopGuidance:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.stopGuidanceButton)
        self.stopGuidanceButton.hidden = true;
        self.stopGuidanceButton.alpha = 0.0;
    }
    
    /**
    Setup stop location manager
    */
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10
    }
    
    /*
    Setup the parking timer
    */
    func setupParkingTimer() {
        
        // Add the background
        self.parkingMeterTimerBackground.frame =  CGRectMake(self.shareButton.frame.origin.x + self.shareButton.bounds.size.width + kButtonPadding, self.shareButton.frame.origin.y, self.view.bounds.size.width - (kButtonWidth * 2) - (kButtonPadding * 4), kButtonHeight)
        self.parkingMeterTimerBackground.alpha = 0.7
        self.parkingMeterTimerBackground.backgroundColor = UIColor.blackColor()
        self.parkingMeterTimerBackground.layer.cornerRadius = 6.0
        self.view.addSubview(self.parkingMeterTimerBackground)
        
        // Add the meter text label
        self.parkingMeterTimerLabel.frame = self.parkingMeterTimerBackground.frame
        self.parkingMeterTimerLabel.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        self.parkingMeterTimerLabel.text = "00:00"
        self.parkingMeterTimerLabel.textAlignment = .Center
        self.parkingMeterTimerLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(self.parkingMeterTimerLabel)
        
        self.parkingMeterTimerLabel.text = stringForTimeInterval(self.parkingMeterInterval)
        
        // Upate the timer
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
        
    }
    
    // MARK: Private Methods
    
    /**
    What to do when the car status changes
    */
    func carStatusChanged() {
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(PARKED_LOCATION_LAT) != nil) {
            
            // Set the camera to the position of the parked car
            let lat: NSNumber = NSUserDefaults.standardUserDefaults().valueForKey(PARKED_LOCATION_LAT) as! NSNumber
            let lon: NSNumber = NSUserDefaults.standardUserDefaults().valueForKey(PARKED_LOCATION_LON) as! NSNumber
            
            let cameraPosition: GMSCameraPosition = GMSCameraPosition(target: CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue), zoom: Float(DEFAULT_ZOOM), bearing: 0, viewingAngle: 0.0)
            self.mapView.animateToCameraPosition(cameraPosition)
            
            self.carMarker.map = self.mapView
            self.carMarker.position = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
            
            // The car is parked -- check if there is a timer for the parking metetr
            if (NSUserDefaults.standardUserDefaults().valueForKey(PARKING_METER_END_DATE) != nil) {
                
                let endDate = NSUserDefaults.standardUserDefaults().valueForKey(PARKING_METER_END_DATE) as! NSDate
                self.parkingMeterInterval = endDate.timeIntervalSinceNow
                
                // see if the end date has passed
                if self.parkingMeterInterval >= 0.0 {
                    
                    // the date has not passed -- add the timer
                    setupParkingTimer()
                    
                    
                } else {
                    
                    // the date has passed -- remove the end date
                    self.parkingMeterTimerLabel.removeFromSuperview()
                    self.parkingMeterTimerBackground.removeFromSuperview()
                    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: PARKING_METER_END_DATE)
                    
                    // Remove any markers on the map
                    self.carMarker.map = nil;
                    
                }
            } else {
                self.parkingMeterTimerLabel.removeFromSuperview()
                self.parkingMeterTimerBackground.removeFromSuperview()
                
            }
            
            return
        } else {
            self.parkingMeterTimerLabel.removeFromSuperview()
            self.parkingMeterTimerBackground.removeFromSuperview()
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: PARKING_METER_END_DATE)
            
            // Remove any markers on the map
            self.carMarker.map = nil;
        }
        
    }
    
    /**
    Get the string date for timer interval
    
    :param: timeInterval The time interval you would like to convert to string
    :returns: A string of the time with the format HH:mm:ss
    */
    func stringForTimeInterval(timeInterval: NSTimeInterval) -> String {
        let hours = Int(floor(timeInterval / (60 * 60)))
        let minute_divisor = timeInterval % (60 * 60);
        
        let minutes = Int(floor(minute_divisor / 60))
        
        let seconds_divisor = timeInterval % 60;
        let seconds = Int(ceil(seconds_divisor))
        
        var hoursString = String(format: "%02d", hours)
        var minutesString = String(format: "%02d", minutes)
        var secondsString = String(format: "%02d", seconds)
        
        if count(hoursString) == 1 {
            hoursString += "0"
        }
        if count(minutesString) == 1 {
            minutesString += "0"
        }
        if count(secondsString) == 1 {
            secondsString += "0"
        }
        
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
    
    
    /**
    Called every second to update the timer
    */
    func updateTimer(sender: NSTimer!) {
        
        self.parkingMeterInterval--
        if (self.parkingMeterInterval <= 0) {
            self.parkingMeterTimerLabel.text = "00:00:00"
            sender.invalidate()
        } else {
            self.parkingMeterTimerLabel.text = stringForTimeInterval(self.parkingMeterInterval)
        }
        
    }
    
    /**
    One of the segmented buttons at the top was hit
    
    :param: sender The segmented control that is being hit
    */
    func segmentHit(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            
            // Crimes
            self.currentFilter = "crimes"
            reloadHeatMap()
            
        } else if (sender.selectedSegmentIndex == 1) {
            
            // Tickets
            self.currentFilter = "tickets"
            reloadHeatMap()
            
        } else if (sender.selectedSegmentIndex == 2) {
            
            // Price
            self.currentFilter = "prices"
            reloadHeatMap()
        }
    }
    
    /**
    Called when user taps the car icon in the nav bar
    
    :param: sender The button which called the selector
    */
    func connectCar(sender: AnyObject) {
        
        // First double check to make sure push notification are enabled
        
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            let rvc = ConnectCarViewController()
            self.navigationController?.presentViewController(rvc, animated: true, completion: { () -> Void in
                
            })
        } else {
            
            let alert = UIAlertController(title: "Slow Down There...", message: "You need to enable push notifications in settings before you do anything with a car!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    /**
    Called when user taps the report button
    
    :param: sender The button which called the selector
    */
    func reportButtonPressed(sender: UIButton) {
        
        let model: NSString = UIDevice.currentDevice().model as NSString
        
        if (CLLocationManager.locationServicesEnabled() || model.isEqualToString("iPhone Simulator")) {
            
            var currentLocation = CLLocationCoordinate2DMake(0, 0)
            
            if (model.isEqualToString("iPhone Simulator")) {
                currentLocation = CLLocation(latitude: 37.4203696428215, longitude: -122.170106303061).coordinate
            } else {
                currentLocation = self.locationManager.location.coordinate
            }
            
            // Show loading hud
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = .Indeterminate
            
            // Reverse geocode the coordinate
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(currentLocation, completionHandler: { (response: GMSReverseGeocodeResponse!, error: NSError!) -> Void in
                hud.hide(true)
                let result: GMSAddress = response.firstResult()
                let streetName = result.thoroughfare!
                if (!streetName.isEmpty) {
                    let rvc = ReportViewController(type: .Regular, currentLocation: currentLocation, streetName: streetName)
                    self.navigationController?.pushViewController(rvc, animated: true)
                } else {
                    let alert = UIAlertController(title: "Whoops!", message: "We couldn't find your parking spot!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
                        
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
            })
            
        } else {
            let alert = UIAlertController(title: "Whoops!", message: "You need to enable location services to send reports! You can do so in settings!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /**
    Called when user taps the share button
    
    :param: sender The button which called the selector
    */
    func shareButtonPressed(sender: UIButton) {
        let textToShare = "Tired of stressing over where to park? Try Parq today!"
        
        if let myWebsite = NSURL(string: "http://www.parqtheapp.com?ref=" + PFInstallation.currentInstallation().objectId!)
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.completionHandler = {
                (activityType, completed) in
                if completed == false {
                    return
                }
                IBANetworking.shareHit(activityType, completion: { (completed, error) -> Void in
                    
                })
                return
            }
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    /**
    Reloads the heat hap
    */
    func reloadHeatMap() {
        IBANetworking.valuesInRegion(self.mapView.projection.visibleRegion(), values: self.currentFilter, completion: {response, error in
            self.drawHeatMapWith(crimes: response as! NSArray?)
        })
    }
    
    /**
    Request permission to update location
    */
    func triggerLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                startUpdatingLocation()
            }
        }
    }
    
    /**
    Actually updated the location
    */
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /**
    Show the following error message
    
    :param: message The message you would like to show
    */
    func displayErrorWithMessage(message: String) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.labelText = message
        hud.hide(true, afterDelay: 1.0)
        hud.userInteractionEnabled = false
    }
    
    // MARK: Direction Navigation
    
    /**
    Add the directions to the screen as a GMSPolyline
    
    :json: message The JSON dictionary of routes
    */
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
    
    /**
    Called when the user wants to end guidance
    
    :param: sender The button who called the selector
    */
    func stopGuidance(sender: IBAButton) {
        self.currentMarker.map = nil
        self.currentPolyline.map = nil
        self.stopGuidanceButton.hidden = true
        self.searchField.text = ""
    }
    
    /**
    Creates a route to the requested destination
    
    :param: destination The CLLocation destination
    */
    func createRouteToDestination(destination: CLLocation) {
        
        // Clear the previous destination
        self.currentPolyline.map = nil
        self.currentMarker.map = nil
        
        let fromLocation: CLLocation
        
        // If we are using the simulator fake a start point
        let model: NSString = UIDevice.currentDevice().model as NSString
        if (model.isEqualToString("iPhone Simulator")) {
            fromLocation = CLLocation(latitude: 37.4203696428215, longitude: -122.170106303061)
        } else {
            fromLocation = self.locationManager.location
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
    
    /**
    Takes an array of crimes objects and draws a heat map
    
    :param: crimes The crimes you would like to show in the heat map
    */
    func drawHeatMapWith(#crimes: NSArray?) {
        
        self.currentOverlay.map = nil;
        
        if (crimes == nil || crimes!.count == 0) {
            displayErrorWithMessage("No " + self.currentFilter + " in this region!")
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
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        let model: NSString = UIDevice.currentDevice().model as NSString
        if (!model.isEqualToString("iPhone Simulator")) {
            var alert = UIAlertController(title: "Whoops!", message: "Couldn't get location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
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
        reloadHeatMap()
    }
    
    // MARK: UITextfield Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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

