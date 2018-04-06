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
    var sort : [String] = ["best_match", "distance", "rating"]
    var sortSelection : String = "best_match"
    
    @IBOutlet var sortPicker: WKInterfacePicker!
    
    
    override func willActivate() {
        super.willActivate()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        self.enableBasicLocationServices()
        setPickerItems()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func findASpotButton() {
        // Voice, Scribble, Options
        presentTextInputController(withSuggestions: ["Food", "Gas", "ATM"], allowedInputMode: .plain) { [unowned self] result in
            guard let result = result?.first as? String else { return }
            self.userSelection = result
            
            DispatchQueue.main.async {
            self.pushController(withName: "InterfaceController", context: [self.userSelection, String(self.latitude), String(self.longitude), self.sortSelection])
            }
        }
        
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if userSelection == nil {
            userSelection = "Food"
        }
        return [userSelection, String(latitude), String(longitude), sortSelection]
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
    
    func setPickerItems() {
        
        let sortByBestMatch : WKPickerItem = WKPickerItem()
        sortByBestMatch.title = "Best Match"
        
        let sortByDistance : WKPickerItem = WKPickerItem()
        sortByDistance.title = "Closest"
        
        let sortByRatings : WKPickerItem = WKPickerItem()
        sortByRatings.title = "Highest Ratings"
        
        sortPicker.setItems([sortByBestMatch, sortByDistance, sortByRatings])
        sortPicker.focus()
        sortPicker.setEnabled(true)        
    }
    @IBAction func pickerAction(_ value: Int) {
        sortSelection = sort[value]
        print(sortSelection)
    }
    
}

