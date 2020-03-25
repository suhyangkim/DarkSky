//
//  DetailsVC.swift
//  DarkSky
//
//  Created by Su Hyang Kim on 3/20/20.
//  Copyright © 2020 Su Hyang Kim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

class DetailsVC: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var highLow: UILabel!
    
    //passed data in variables
    var index: Int!
    var apiKey: String!
    var lat: Double!
    var lon: Double!
    let week:Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    override func viewDidLoad() {
        super.viewDidLoad()
        fillIn()
        print(self.index!)
    }
    
    func fillIn(){
    
        Alamofire.request("https://api.darksky.net/forecast/\(self.apiKey!)/\(self.lat!),\(self.lon!)").responseJSON{
            response in
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonDailyData = jsonResponse["daily"]["data"][self.index!]
                let jsonIcon = jsonDailyData["icon"]
                self.weatherImage.image = UIImage(named: jsonIcon.stringValue + "1")
                var description = jsonDailyData.description
                if let finalStr = description.range(of: "{") {
                    description.replaceSubrange(finalStr, with: "")
                }
                self.details.insertText(jsonDailyData.description)
                let jsonHighTemp = jsonDailyData["apparentTemperatureHigh"]
                let jsonLowTemp = jsonDailyData["apparentTemperatureLow"]
                self.highLow.text = "\(Int(round(jsonHighTemp.doubleValue)))"  + "℃ / " + "\(Int(round(jsonLowTemp.doubleValue)))" + "℃"
                self.highLow.sizeToFit()
                self.dateLabel.text = self.week[self.index]
                self.dateLabel.sizeToFit()
//                let index = jsonTimeZone.stringValue.index(after: jsonTimeZone.stringValue.index(of: "/")!)
//                var newStr = String(jsonTimeZone.stringValue[index...])
//                if let finalStr = newStr.range(of: "_") {
//                  newStr.replaceSubrange(finalStr, with: " ")
//                }
//                self.locationLabel.text = newStr
                
//                let date = Date()
//                let format = DateFormatter()
//                format.dateFormat = "yyyy/MM/dd"
//                let formattedDate = format.string(from: date)
//                self.dateLabel.text = formattedDate
//                self.dateLabel.sizeToFit()
            }
        }
    }

}
