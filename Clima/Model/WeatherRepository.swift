//
//  WeatherRepository.swift
//  Clima
//
//  Created by protector on 1/5/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherRepositoryDelegate {
    func didUpdateWeather(_ weatherRepository: WeatherRepository, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherRepository {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=b24a42e4574179dd3fa708367fa8d567&units=metric"
    
    var delegate : WeatherRepositoryDelegate?
    
    func fetchWeather(cityName : String) {
        let url = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: url)
    }
    
    func fetchWeather(lat : CLLocationDegrees, lon: CLLocationDegrees) {
        let url = "\(weatherUrl)&lat=\(lat)&lon=\(lon)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString : String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let savedData = data {
                    if let weather = parseJSON(savedData) {
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather.first!.id
            let temperature = decodedData.main.temp
            let cityName = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temperature)
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}


