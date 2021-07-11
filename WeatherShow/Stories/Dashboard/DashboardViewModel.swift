//
//  DashboardViewModel.swift
//  WeatherShow
//
//  Created by Gaurav Chandarana on 11/07/21.
//

import Foundation
import CoreLocation

protocol DashboardControllerProtocol: AnyObject {
    
}

class DashboardViewModel {

    private let primeNumbers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    private var geocoder: CLGeocoder?
    var lastKnownLocation: CLLocation?
    weak var viewController: DashboardControllerProtocol?
    
    /// Returns true if the given date is a prime number, false otherwise.
    /// - Parameter date: A date
    /// - Discussion: As long as we're checking only dates, we can use pre-defined data to check the number's being prime or not.
    func isDatePrime(_ date: Date) -> Bool {
        let selectedDay = Calendar.current.component(.day, from: date)
        return primeNumbers.contains(selectedDay)
    }
    
    func getCityNameFor(location: CLLocation, completion: @escaping (String?, String?, Error?) -> ())  {
        if geocoder == nil {
            self.geocoder = .init()
        }
        geocoder?.reverseGeocodeLocation(location) { placeMarks, error in
            completion(placeMarks?.first?.locality, placeMarks?.first?.country, error)
        }
    }

    /*
    func locale(for country: String?) -> String? {
        guard let country = country else { return nil }
        return NSLocale.isoCountryCodes.first(where: {
            let identifier = NSLocale(localeIdentifier: $0)
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: $0)
            return country.lowercased() == countryName?.lowercased()
        })
    }
     */
 
    func fetchWeatherDataFor(location: CLLocation, on date: Date, completion: @escaping (Weather?, Error?) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast") else { return }
        let params = ["lat": location.coordinate.latitude, "lon": location.coordinate.longitude, "appid": "3fdb1ef9917d93a1ef95142062df9e8d"] as [String: Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        encode(urlRequest: &request, with: params)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<300 ~= statusCode else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let weather = try? JSONDecoder().decode(Weather.self, from: data)
            DispatchQueue.main.async {
                completion(weather, nil)
            }
        }.resume()
    }
    
    private func encode(urlRequest: inout URLRequest, with parameters: [String: Any]?) {
        
        guard let url = urlRequest.url else {
            fatalError()
        }
        
        if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            
            comps.queryItems = .init()
            parameters?.forEach { (key, value) in
                let item = URLQueryItem(name: key, value: "\(value)")
                comps.queryItems?.append(item)
            }
            urlRequest.url = comps.url
        }
    }
}
