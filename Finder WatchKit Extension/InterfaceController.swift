//
//  InterfaceController.swift
//  Finder WatchKit Extension
//
//  Created by Jervin Cruz on 3/28/18.
//  Copyright © 2018 Jervin Cruz. All rights reserved.
//

import WatchKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Kingfisher

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    var url : String = "https://api.yelp.com/v3/businesses/search"
    var reviewURL : String = ""
    var term : String?
    let api_key = "rCEYWGihgFHL7ygVqocEiH0KCGySfdHzE3OMfzy_2KYmLlEy3Br85WhQZk6b_1Mz-4UoE-a1RPlQF797HthInPDCPoz5A5moCNVPBArgbmT6Uz_UMLx7ptM9jsG7WnYx"
    var headers : HTTPHeaders?
    var params : Parameters?
    let delegate = WKExtension.shared().delegate as! ExtensionDelegate
    var userSelection = ""
    
    var stores : [String] = []
    var statuses : [Bool] = []
    var prices : [String] = []
    var ratings : [Double] = []
    var reviews : [String] = []
    var images : [String] = []
    var distances : [Double] = []
    var addresses : [String] = []
    var latitude : CLLocationDegrees!
    var longitude : CLLocationDegrees!
    var coordinates: [(latitude: Double, longitude: Double)] = []
    var locationManager : CLLocationManager!
    var mapItem : MKMapItem!
 
    @IBOutlet var shopTable: WKInterfaceTable!
    
    var pmark : [CLPlacemark]!
    var location : CLLocation!

    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        headers = ["Authorization": "Bearer " + api_key]
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //self.enableBasicLocationServices()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(7)){
            
            if let values = context as? [String] {
                print("Values:", values)
                self.userSelection = values[0]
                self.latitude = CLLocationDegrees(values[1])
                self.longitude = CLLocationDegrees(values[2])
            } else {
                self.userSelection = "Food"
            }
            
            // Get Current Location
            self.params = ["term": self.userSelection, "latitude": self.latitude, "longitude":                                                self.longitude, "limit": 10, "offset": 0]
            self.getData(url: self.url)
            print("Lattts: ", self.latitude)
            print("Longggg:", self.longitude)
            
        }

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func getData(url: String){
        Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success!")
                print(response)
                                let yelpJSON : JSON = JSON(response.result.value!)
                                self.updateYelpData(json: yelpJSON)
                //                self.tableView.reloadData()
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    // Fetch Yelp Business Data
    func updateYelpData(json : JSON){
        var x : Int = 0

        while json["businesses"][x] != JSON.null{
            stores.append(json["businesses"][x]["name"].stringValue)
            prices.append(json["businesses"][x]["price"].stringValue)
            statuses.append(json["businesses"][x]["price"].boolValue)
            ratings.append(json["businesses"][x]["rating"].doubleValue)
            reviews.append(json["businesses"][x]["review_count"].stringValue)
            images.append(json["businesses"][x]["image_url"].stringValue)
            distances.append(json["businesses"][x]["distance"].doubleValue * 0.000621371)
            coordinates.append((latitude: json["businesses"][x]["coordinates"]["latitude"].double!, longitude: json["businesses"][x]["coordinates"]["longitude"].double!))
            print("JSONCOORDINATES: ", json["businesses"][x]["coordinates"]["latitude"])
           // addresses.append(json["businesses"][x]["location"]["address1"].stringValue + ", " + json["businesses"][x]["location"]["city"].stringValue + " " + json["businesses"][x]["location"]["state"].stringValue + ", " + json["businesses"][x]["location"]["zip_code"].stringValue)
           // displayedImages.append(json["businesses"][x]["image_url"].stringValue)
            x = x + 1
        }
        print("Stores: ", stores)
        print("Prices: ", prices)
        print("Statuses: ", statuses)
        print("Ratings: ", ratings)
        print("Reviews: ", reviews)
        print("Distances: ", distances)
        print("Addresses: ", addresses)
        
        DispatchQueue.main.async {
            self.shopTable.setNumberOfRows(self.stores.count, withRowType: "StoreRow")
            for rowIndex in 0 ..< self.stores.count{
                self.set(row: rowIndex, to: self.stores[rowIndex])
            }
        }
    }
    
    // Row Attributes
    func set(row rowIndex: Int, to text: String){
        guard let row = shopTable.rowController(at: rowIndex) as? StoreRow else { return }
        row.name.setText(stores[rowIndex])
        row.price.setText(prices[rowIndex])
        row.reviews.setText(reviews[rowIndex] + " Reviews")
        row.distance.setText(String(format: "%.2f", distances[rowIndex]) + " mi")
        row.nameBackground.setBackgroundColor(UIColor.black)
        row.reviewBG.setBackgroundColor(UIColor.black)
        row.priceBG.setBackgroundColor(UIColor.black)
        row.distanceBG.setBackgroundColor(UIColor.black)
        
        let url = URL(string: images[rowIndex])
        
        if let placeUrl = URL(string: images[rowIndex]) {
            _ = KingfisherManager.shared.retrieveImage(with: placeUrl, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in

                if image != nil {
                    DispatchQueue.main.async {
                        row.rowGroup.setBackgroundImage(image)
                    }
                }
            })
        }
        

        switch ratings[rowIndex]{
        case 0:
            row.rating.setImage(UIImage(named: "small_0"))
        case 1:
            row.rating.setImage(UIImage(named: "small_1"))
        case 1.5:
            row.rating.setImage(UIImage(named: "small_1_half"))
        case 2:
            row.rating.setImage(UIImage(named: "small_2"))
        case 2.5:
            row.rating.setImage(UIImage(named: "small_2_half"))
        case 3:
            row.rating.setImage(UIImage(named: "small_3"))
        case 3.5:
            row.rating.setImage(UIImage(named: "small_3_half"))
        case 4:
            row.rating.setImage(UIImage(named: "small_4"))
        case 4.5:
            row.rating.setImage(UIImage(named: "small_4_half"))
        case 5:
            row.rating.setImage(UIImage(named: "small_5"))
        default:
            row.rating.setImage(UIImage(named: "small_0"))

        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
   
            let coordinate = CLLocationCoordinate2DMake(coordinates[rowIndex].latitude, coordinates[rowIndex].longitude)
            let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
            mapItem.name = self.stores[rowIndex]
            mapItem.openInMaps(launchOptions: options)
    }
    
}

//public extension WKInterfaceImage {
//    public func setImageWithURL(url: String, scale: CGFloat = 1.0) -> WKInterfaceImage {
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if (data != nil && error == nil) {
//                let image = UIImage(data: data!, scale: scale)
//
//                dispatch_asyn
//            }
//        }
//
//    }
//}
