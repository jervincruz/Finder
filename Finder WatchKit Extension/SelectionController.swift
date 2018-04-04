//
//  SelectionController.swift
//  Finder WatchKit Extension
//
//  Created by Jervin Cruz on 4/2/18.
//  Copyright © 2018 Jervin Cruz. All rights reserved.
//

import Foundation
import WatchKit

class SelectionController : WKInterfaceController, CLLocationManagerDelegate {
    
    var userSelection : String!
    
    var locationManager : CLLocationManager!
    var latitude : CLLocationDegrees!
    var longitude : CLLocationDegrees!
    
    override func willActivate() {
        super.willActivate()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        self.enableBasicLocationServices()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func findASpotButton() {
        // Voice, Scribble, Options
        presentTextInputController(withSuggestions: ["Food", "Gas", "ATM"], allowedInputMode: .plain) { [unowned self] result in
            guard let result = result?.first as? String else { return }
            self.userSelection = result
        }
        
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if userSelection == nil {
            userSelection = "Food"
        }
        return [userSelection, String(latitude), String(longitude)]
    }
    
    func enableBasicLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            // Request when in-use authorization initially
            //locationManager.requestWhenInUseAuthorization()
            
            // Request authorization always
            locationManager.requestAlwaysAuthorization()
            
            // Disable location features
            disableLocation()
            break
        case .restricted, .denied:
            
            // Disable location features
            disableLocation()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            enableLocation()
            break
        }
    }
    
    func enableLocation() {
        
        // get location of iPhone
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
    
    func disableLocation() {
        
        // set map to Cupertino, CA
        // 37.3230 N, 122.0322 W
        
        let lat : CLLocationDegrees = CLLocationDegrees.init(37.3230)
        let long : CLLocationDegrees = CLLocationDegrees.init(-122.0322)
        
        let mapLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get current location using location manager
        
        let currentLocation = locations[0]
        latitude = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
        
        let mapLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        print("LM Lat: ", latitude)
        print("LM Long: ", longitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error")
        print(error)
        print(error.localizedDescription)
    }

    
}

