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
    
    
    let dataFormater: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.short
        df.timeStyle = DateFormatter.Style.short
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManger.delegate = self
        locationManger.requestWhenInUseAuthorization()
        mapView.delegate = self
    }
    
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
                        
                        print("\(placeMark.name!) \(placeMark.locality!) \(placeMark.administrativeArea!) \(placeMark.postalCode!)")
                        self.reverseGeocodeComplete(location: placeMark)
                        
                    }
                }
            }
            
        }
    }
    
    func reverseGeocodeComplete(location: CLPlacemark) {
        
        let locationString = "\(location.name!) \(location.locality!) \(location .administrativeArea!) \(location.postalCode!)"
        locationText.text = locationString
        
    }
    
    
    func moveToCurrentLocation(){
        if let location = locationManger.location {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let location = locationManger.location {
            
            let closeAnnotation = mapView.annotations
            
                .map{(CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude))}
                .filter({$0.distance(from: location) < 30})
            
            
            if closeAnnotation.count > 1 {
                print("Other locations are close. Not addidng")
               
            }
        }
    
        if annotation is MKPinAnnotationView {
            let pinAnnotaion = MKPinAnnotationView()
            pinAnnotaion.tintColor = UIColor.purple
            pinAnnotaion.annotation = annotation
            pinAnnotaion.tintColor = .yellow
            pinAnnotaion.canShowCallout = true
            return pinAnnotaion
        }
        
        return nil // use default view, so user locaiton beacon isn't modified.
    }


}

