//
//  StoreRow.swift
//  Finder WatchKit Extension
//
//  Created by Jervin Cruz on 3/28/18.
//  Copyright © 2018 Jervin Cruz. All rights reserved.
//

import WatchKit

class StoreRow: NSObject {

    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var rating: WKInterfaceImage!
    @IBOutlet var reviews: WKInterfaceLabel!
    @IBOutlet var price: WKInterfaceLabel!
    @IBOutlet var distance: WKInterfaceLabel!
    @IBOutlet var rowGroup: WKInterfaceGroup!
    @IBOutlet var nameBackground: WKInterfaceGroup!
    @IBOutlet var reviewBG: WKInterfaceGroup!
    @IBOutlet var priceBG: WKInterfaceGroup!
    @IBOutlet var distanceBG: WKInterfaceGroup!
    
}
