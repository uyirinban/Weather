//
//  WeatherManager.swift
//  Weather
//
//  Created by Jeevanantham Kalyanasundram on 2/23/17.
//  Copyright © 2017 Jeevanantham Kalyanasundram. All rights reserved.
//

import Foundation

// The delegate method didGetWeather is called if the weather data was received.
// The delegate method didNotGetWeather method is called if weather data was not received.
protocol WeatherManagerDelegate {
    func didGetWeather(weather: WeatherDetails)
    func didNotGetWeather(error: NSError)
    func didReceivedImageData(data: Data)
}


// MARK: WeatherManager

class WeatherManager {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "a241aca7068f1107227442653a64682c"
    
    private var delegate: WeatherManagerDelegate
    
    
    // MARK: -
    init(delegate: WeatherManagerDelegate) {
        self.delegate = delegate
    }
    
    func getWeather(city: String) {
            
        // This is the shared session will do.
        let session = URLSession.shared
        
        let cityName = city.replacingOccurrences(of: " ", with: "")
        
        let weatherRequestURL =  URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(cityName)")!
        
        let task = session.dataTask(with: weatherRequestURL, completionHandler: { (data, response, error) in

            if let networkError = error {
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetWeather(error: networkError as NSError)
            }
            else {
                print("Success")
                // We got data from the server!
                do {

                    let weatherData = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]
                    
                    // Initializing dictionary to Weather struct.
                    let weather = WeatherDetails(weatherData: weatherData)
                    
                    // Pass Weather struct to view controller to display the weather info.
                    self.delegate.didGetWeather(weather: weather)
                }
                catch let jsonError as NSError {
                    self.delegate.didNotGetWeather(error: jsonError)
                }
            }
            
        })
        
        task.resume()
    }
   
    func getWeatherImage(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.delegate.didReceivedImageData(data: data!)
  
            })
            
        }).resume()
        
        
    }
    
}
