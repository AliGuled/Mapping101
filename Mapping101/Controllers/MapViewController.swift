//
//  ViewController.swift
//  Mapping101
//
//  Created by Guled Ali on 2/6/19.
//  Copyright © 2019 Guled Ali. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate  {
    
    // map and location text outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationText: UILabel!
    
    //The obejct that determines the location
    let locationManger = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    //Formatting date to short style date
    let dataFormater: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        df.timeStyle = DateFormatter.Style.short
        return df
    }()
    
//    Setting the delegates for location manager and mapview
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
        mapView.delegate = self
        
    }
//    Adding the current location marker
    @IBAction func addCurrentLocationMarker(_ sender: UIButton) {
        
        if let location = locationManger.location {
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = location.coordinate
            
            let timeStamp = dataFormater.string(from: Date())
            annotaion.title = "You were here \(timeStamp)"
            mapView.addAnnotation(annotaion)
            
            geoCoder.reverseGeocodeLocation(location) { (placeMarks : [CLPlacemark]?, error: Error?) in
                
                if error == nil {
                    if let placeMark = placeMarks?[0] {
                        
                        print("\(placeMark.name ?? "??1") \(placeMark.locality ?? "??") \(placeMark.administrativeArea ?? "??") \(placeMark.postalCode ?? "??")")
                        self.reverseGeocodeComplete(location: placeMark)
                        
                    }
                }
            }
            
        }
    }
    
    //Finding the current location string in address format
    func reverseGeocodeComplete(location: CLPlacemark) {
        
        let locationString = "\(location.name ?? "??") \(location.locality ?? "??") \(location .administrativeArea ?? "??") \(location.postalCode ?? "?? ")"
        locationText.text = locationString
        
    }
    
    //Moving the location and centering
    func moveToCurrentLocation(){
        if let location = locationManger.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
// Asking the user perimission to access their location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            moveToCurrentLocation()
        } else {
            let alert = UIAlertController(title: "Can't display location", message: "Please grant permission in settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) -> Void in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)}))
            present(alert, animated: true, completion: nil)
        }
    }
    
    //Adding custom location pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            let pinAnnotaion = MKPinAnnotationView()
            pinAnnotaion.tintColor = UIColor.purple
            pinAnnotaion.annotation = annotation
            pinAnnotaion.canShowCallout = true
            pinAnnotaion.tintColor = .purple
            return pinAnnotaion
        }
        print("custom pin method")
        
           if let location = locationManger.location {
            
            let closeAnnotation = mapView.annotations
            
                .map{(CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))}
                .filter({$0.distance(from: location) < 30})
            
            
            if closeAnnotation.count > 1 {
                print("Other locations are close. Not addidng")
               
            }
        }
    
      
        
        return nil // use default view, so user locaiton beacon isn't modified.
    }


}

