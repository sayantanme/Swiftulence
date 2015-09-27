//
//  ViewController.swift
//  Swiftulence
//
//  Created by Sayantan Chakraborty on 21/09/15.
//  Copyright © 2015 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var locationData: NSArray?
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.mapType = .Standard
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        fetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        fetch()
    }
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, 2000, 2000)
        mapView.setRegion(region, animated: true)
        //mapView.showAnnotations([userLocation], animated: true)
    }
    
    func fetch()
    {
        var json: AnyObject? = nil
        let url = NSURL(string: "https://mywebapps.mybluemix.net/api/Mydb/GetAllDeviceInfo")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            if let data = NSData(contentsOfURL: url!){
                
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    print(json)
                    self.locationData = json as? NSArray
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if self.locationData?.count > 0{
                            for points in self.locationData! {
                                let lattitude = (points["latt"] as! NSString).doubleValue
                                let longitude = (points["lon"] as! NSString).doubleValue
                                let name = "Ambulance" + ((points["devicename"] as! NSString) as String)
                                
                                let location = CLLocationCoordinate2DMake(CLLocationDegrees(lattitude), longitude)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = location
                                annotation.title = name
                                self.mapView.addAnnotation(annotation)
                                
                                
                            }
                        }
                    }
                    
                }catch _ {
                    
                }
            }
        }
        
    }
    
    
}

