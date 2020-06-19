//
//  UserLocationViewController.swift
//  soilconnect-map
//
//  Created by Jeremy Mankin on 6/19/20.
//  Copyright © 2020 Jeremy Mankin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class UserLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressName: UILabel!
    @IBOutlet var addressLocality: UILabel!
    @IBOutlet var addressState: UILabel!
    @IBOutlet var addressZipCode: UILabel!
    
    let locationManager = CLLocationManager()
    let regionRadius: Double = 800                      // adjust to set the radius of the map
    
    var locationLatitude: CLLocationDegrees?
    var locationLongitude: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // requesr authorization to determine user location
        configureLocationRequest()
        
        locationManager.delegate = self
        mapView.delegate = self

        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.mapType = .mutedStandard
    }
    
    // MARK: CoreLocation Delegate Functions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // center user location on map
        centerMapOnUserLocation()
         
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locationValue.latitude) \(locationValue.longitude)")
        
        // show user location address, if not possible, display as Times Square default location
        let locationVariable: CLLocation = CLLocation(latitude: manager.location?.coordinate.latitude ?? 40.7580, longitude: manager.location?.coordinate.longitude ?? 73.9855)
        displayCurrentLocationLabel(location: locationVariable)
        
    }

    // MARK: User Location Helper Methods
    func configureLocationRequest() {
        
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
    
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnUserLocation() {
        
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayCurrentLocationLabel(location: CLLocation) {
        
        let geoCoder = CLGeocoder()
             
             geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                 var placemark:CLPlacemark!
                 var placeName: String = ""
                 var streetCity: String = ""
                 var streetState: String = ""
                 var streetZipCode: String = ""
                 
                 if error == nil {
                     placemark = (placemarks?[0])! as CLPlacemark
                     
                     if placemark.country == "United States" { // country e.g. US
                         if placemark.postalCode != nil { // zip code e.g. 10001
                             streetZipCode = placemark.postalCode ?? "Unknown"
                         }
                         if placemark.administrativeArea != nil { // state e.g. NY
                             streetState = placemark.administrativeArea!
                         }
                         if placemark.locality != nil {  // city e.g. New York
                             streetCity =  placemark.locality ?? "New York"
                         }
                         if placemark.name != nil { // location name?
                             placeName = placemark.name ?? "Unknown"
                         }
                         
                         /*
                         print("placemark.name is: \(String(describing: placemark.name))")
                         print("placemark.locality is: \(String(describing: placemark.locality))")
                         print("placemark.state is: \(String(describing: placemark.administrativeArea))")
                         print("placemark.postalCode is: \(String(describing: placemark.postalCode))")
                        */
                        
                        self.addressName.text = placeName
                        self.addressLocality.text = streetCity
                        self.addressState.text = streetState
                        self.addressZipCode.text = streetZipCode

                     }
                     
                 }
                 
             })
    }
    
    


}
