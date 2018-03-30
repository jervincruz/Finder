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

class InterfaceController: WKInterfaceController {
    
    var url : String = "https://api.yelp.com/v3/businesses/search"
    var reviewURL : String = ""
    var term : String?
    let api_key = "rCEYWGihgFHL7ygVqocEiH0KCGySfdHzE3OMfzy_2KYmLlEy3Br85WhQZk6b_1Mz-4UoE-a1RPlQF797HthInPDCPoz5A5moCNVPBArgbmT6Uz_UMLx7ptM9jsG7WnYx"
    var headers : HTTPHeaders?
    var params : Parameters?
    let delegate = WKExtension.shared().delegate as! ExtensionDelegate
    
    var stores : [String] = []
    var statuses : [Bool] = []
    var prices : [String] = []
    var ratings : [Double] = []
    var reviews : [String] = []
    var images : [String] = []
    var distances : [Double] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0{
        didSet{
           // getData(url: url)
        }
    }
    
    @IBOutlet var shopTable: WKInterfaceTable!
    
    
 
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        headers = ["Authorization": "Bearer " + api_key]
        self.delegate.locationManager?.requestLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)){
            self.latitude = self.delegate.latitude!
            print("Lattts: ", self.latitude)
            
            self.longitude = self.delegate.longitude!
            print("Longggg:", self.longitude)
            
            self.params = ["term": "boba milk tea", "latitude": self.latitude, "longitude": self.longitude, "limit": 10, "offset": 0]
            
            self.getData(url: self.url)
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
            //     displayedImages.append(json["businesses"][x]["image_url"].stringValue)
            x = x + 1
        }
        print("Stores: ", stores)
        print("Prices: ", prices)
        print("Statuses: ", statuses)
        print("Ratings: ", ratings)
        print("Reviews: ", reviews)
        print("Distances: ", distances)
        
        print(stores.count)
        DispatchQueue.main.async {
            self.shopTable.setNumberOfRows(self.stores.count, withRowType: "StoreRow")
            for rowIndex in 0 ..< self.stores.count{
                self.set(row: rowIndex, to: self.stores[rowIndex])
                print(rowIndex)
            }
        }
    }
    
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
        let data = try? Data(contentsOf: url!)
        
        row.rowGroup.setBackgroundImage(UIImage(data: data!))
        
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

    
    
}

