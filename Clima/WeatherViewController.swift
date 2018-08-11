//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, passCityNameToWeatherVC {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    //5a9c5f80060598353f5d0868d6f2d707
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()

    //Create a weatherDataModel Object
    let weatherDataModelObj = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getweatherData(url: String, params: [String : String]){
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            switch response.result {
                case .success:
                    print("Success! Got the weather data!")

                    let weatherJSON : JSON = JSON(response.result.value!)
                    print(weatherJSON)
                    self.updateWeatherData(json: weatherJSON)
                case .failure(let error):
                    print(error)
                    self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        //optional binding instead of force unwrapping
        if let tempResult = json["main"]["temp"].double{
            weatherDataModelObj.tempurature = Int(tempResult - 273.15)
            weatherDataModelObj.city = json["name"].stringValue
            weatherDataModelObj.condition = json["weather"][0]["id"].intValue
            weatherDataModelObj.weatherIconName = weatherDataModelObj.updateWeatherIcon(condition: weatherDataModelObj.condition)
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModelObj.city
        temperatureLabel.text = String(weatherDataModelObj.tempurature) +  "°"
        weatherIcon.image = UIImage(named: weatherDataModelObj.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here: everytime startUpdatingLocation() finds a value, it updats to locations[CLLocation] array.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //The location’s latitude and longitude identify the center of the circle, and this value indicates the radius of that circle. A negative value indicates that the latitude and longitude are invalid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //it takes some time to stop updating location, so make it nil
            locationManager.delegate = nil
            print("Longitude: \(location.coordinate.longitude), Latitude: \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let param : [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            //print(param)
            getweatherData(url: WEATHER_URL, params: param)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String){
        let cityparam:[String : String] = ["q":city, "appid": APP_ID]
        getweatherData(url: WEATHER_URL, params: cityparam)
        print(city)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self //??? dont understand
        }
    }
    
    
    
    
}


