//
//  MainVC.swift
//  DarkSky
//
//  Created by Su Hyang Kim on 3/16/20.
//  Copyright © 2020 Su Hyang Kim. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class MainVC: UIViewController, CLLocationManagerDelegate {
    //main
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    //7 day forecast
    @IBOutlet weak var firstDay: UIImageView!
    @IBOutlet weak var secondDay: UIImageView!
    @IBOutlet weak var thirdDay: UIImageView!
    @IBOutlet weak var fourthDay: UIImageView!
    @IBOutlet weak var fifthDay: UIImageView!
    @IBOutlet weak var sixthDay: UIImageView!
    @IBOutlet weak var seventhDay: UIImageView!

    var week = [UIImageView]()
    
    //forecast buttons
    @IBOutlet weak var day1: UIButton!
    @IBOutlet weak var day2: UIButton!
    @IBOutlet weak var day3: UIButton!
    @IBOutlet weak var day4: UIButton!
    @IBOutlet weak var day5: UIButton!
    @IBOutlet weak var day6: UIButton!
    @IBOutlet weak var day7: UIButton!
    
    //time machine
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var index = 0
    let backgroundLayer = CAGradientLayer()
    let apiKey = "ff4ef6f22d12b1428ac210dc19a4034e"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(backgroundLayer)
        
        //activity indicator
        let indicatorSize: CGFloat = 70
        let indicatorFram = CGRect(x: (view.frame.width - indicatorSize)/2, y: (view.frame.height - indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFram, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        //getting users location
        locationManager.requestWhenInUseAuthorization()
        activityIndicator.startAnimating()
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        self.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        var time = sender.date.description
        if let finalStr = time.range(of: " ") {
            time.replaceSubrange(finalStr, with: "T")
        }
        let endOfWantedString = time.firstIndex(of: " ")!
        let wantedString = time[...endOfWantedString]
        weatherTimeTravel(String(wantedString))
    }

    override func viewWillAppear(_ animated: Bool) {
        setBlueBackground()
    }
    let group = DispatchGroup()
    self.group.enter()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        Alamofire.request("https://api.darksky.net/forecast/\(apiKey)/\(lat),\(lon)").responseJSON{
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonTimeZone = jsonResponse["timezone"]
                let jsonCurrent = jsonResponse["currently"]
                let jsonWeather = jsonCurrent["summary"]
                let jsonIcon = jsonCurrent["icon"]
                let jsonTemp = jsonCurrent["temperature"]
                
                self.weatherImage.image = UIImage(named: jsonIcon.stringValue)
                self.weatherLabel.text = jsonWeather.stringValue
                self.tempLabel.text = "\(Int(round(jsonTemp.doubleValue)))"  + "℃"
                //how do you get exact location through darksky?
                let index = jsonTimeZone.stringValue.index(after: jsonTimeZone.stringValue.index(of: "/")!)
                var newStr = String(jsonTimeZone.stringValue[index...])
                if let finalStr = newStr.range(of: "_") {
                  newStr.replaceSubrange(finalStr, with: " ")
                }
                self.locationLabel.text = newStr
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                var iconCheck = jsonIcon.stringValue
                if let finalStr = iconCheck.range(of: "-") {
                  iconCheck.replaceSubrange(finalStr, with: " ")
                }
                if (iconCheck.contains("night")){
                    self.setBlackBackground()
                } else if (iconCheck.contains("day")){
                    self.setBlueBackground()
                } else{
                    self.setGreyBackground()
                }
                
                self.week = [self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay, self.sixthDay, self.seventhDay]
                let jsonDailyData = jsonResponse["daily"]["data"]
                while(self.index != 7){
                    self.week[self.index].image = UIImage(named: jsonDailyData[self.index]["icon"].stringValue)
                    self.index += 1
                }
            }
        }
        //to save battery life
        self.locationManager.stopUpdatingLocation()
        group.leave()
    }
    
    var strResult:NSString = ""
    func weatherTimeTravel(_ string: String) {
        print(string)
        let url = "https://api.darksky.net/forecast/\(apiKey)/\(lat),\(lon),\(string)"
        Alamofire.request(url).responseJSON{
            response in
            if let responseStr = response.result.value {
                print("bruh")
                let jsonResponse = JSON(responseStr)
                let jsonCurrent = jsonResponse["currently"]
                let jsonWeather = jsonCurrent["summary"]
                let jsonIcon = jsonCurrent["icon"]
                let jsonTemp = jsonCurrent["temperature"]

                self.weatherImage.image = UIImage(named: jsonIcon.stringValue)
                self.weatherLabel.text = jsonWeather.stringValue
                self.tempLabel.text = "\(Int(round(jsonTemp.doubleValue)))"  + "℃"

                var iconCheck = jsonIcon.stringValue
                if let finalStr = iconCheck.range(of: "-") {
                  iconCheck.replaceSubrange(finalStr, with: " ")
                }
                if (iconCheck.contains("night")){
                    self.setBlackBackground()
                } else if (iconCheck.contains("day")){
                    self.setBlueBackground()
                } else{
                    self.setGreyBackground()
                }

                self.week = [self.firstDay, self.secondDay, self.thirdDay, self.fourthDay, self.fifthDay, self.sixthDay, self.seventhDay]
                let jsonDailyData = jsonResponse["daily"]["data"]
                while(self.index != 7){
                    self.week[self.index].image = UIImage(named: jsonDailyData[self.index]["icon"].stringValue)
                    self.index += 1
                }
            }
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    //background
    func setBlueBackground(){
        //creates gradient background
        let topColor = UIColor(red: 95.0/225.0, green: 165.0/225.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/225.0, green: 114.0/255.0, blue: 184.0/255.0, alpha:1.0).cgColor
        backgroundLayer.frame = view.bounds
        backgroundLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyBackground(){
        //creates gradient background
        let topColor = UIColor(red: 151.0/225.0, green: 151.0/225.0, blue: 151.0/225.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/225.0, green: 72.0/255.0, blue: 72.0/255.0, alpha:1.0).cgColor
        backgroundLayer.frame = view.bounds
        backgroundLayer.colors = [topColor, bottomColor]
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func setBlackBackground(){
        backgroundLayer.frame = view.bounds
        backgroundLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor,
        UIColor.black.withAlphaComponent(1.0).cgColor]
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    //button functions
    @IBAction func firstButton(_ sender: Any) {
        index = 0
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func secondButton(_ sender: Any) {
        index = 1
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func thirdButton(_ sender: Any) {
        index = 2
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func fourthButton(_ sender: Any) {
        index = 3
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func fifthButton(_ sender: Any) {
        index = 4
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func sixthButton(_ sender: Any) {
        index = 5
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    @IBAction func seventhButton(_ sender: Any) {
        index = 6
        self.performSegue(withIdentifier: "toDetailsVC", sender: self)
    }
    
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailsVC, segue.identifier == "toDetailsVC" {
            destinationVC.index = index
            destinationVC.apiKey = apiKey
            destinationVC.lat = lat
            destinationVC.lon = lon
        }
    }
}
