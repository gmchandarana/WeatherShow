//
//  DashboardViewController.swift
//  WeatherShow
//
//  Created by Gaurav Chandarana on 11/07/21.
//

import UIKit
import CoreLocation

class DashboardViewController: BaseViewController<DashboardViewModel> {
    
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var currentCityWeatherView: UIView!
    @IBOutlet weak var weatherStatsStackView: UIStackView!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var shouldFetchData = false
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        viewModel.viewController = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleLocationManagerAccess()
    }
    
    private func handleLocationManagerAccess() {
        
        guard CLLocationManager.locationServicesEnabled() else {
            presentAlertControllerWith(title: "Error", message: "Please enable your location services in order to see weather conditions for the current city.")
            return
        }
        
        let permission = CLLocationManager.authorizationStatus()
        if permission == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if permission == .denied || permission == .restricted {
            presentAlertControllerWith(title: "Error", message: "Please allow location access in order to see weather conditions for the current city.")
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func getViewModel() -> DashboardViewModel {
        DashboardViewModel()
    }
    
    @IBAction func selectDateButtonAction(_ sender: UIButton) {
        guard let selectDateViewController = storyboard?.instantiateViewController(withIdentifier: SelectDateViewController.identifier) as? SelectDateViewController else {
            fatalError("Could not find a viewController with identifier: \(SelectDateViewController.identifier)")
        }
        selectDateViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: selectDateViewController)
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        present(navigationController, animated: true)
    }
    
    private func presentAlertControllerWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(okay)
        present(alertController, animated: true)
    }
    
    func didChangeAuthorization(status: CLAuthorizationStatus) {
        handleLocationManagerAccess()
    }
    
    func didUpdateTo(location: CLLocation?) {
        guard let location = location else { return }
        viewModel.lastKnownLocation = location
        locationManager.stopUpdatingLocation()
        activityIndicator.startAnimating()
        viewModel.fetchWeatherDataFor(location: location, on: .init()) { [weak self] weather, error in
            guard let self = self else { return }
            self.activityIndicator.startAnimating()
            if let weather = weather {
                self.currentCityLabel.text = weather.city.name
                let currentTemp = weather.list.first?.main.temp
                let maxTemp = weather.list.first?.main.tempMax
                let minTemp = weather.list.first?.main.tempMin
                
                let label1 = self.weatherStatsStackView.arrangedSubviews[safe: 0] as? UILabel
                let label2 = self.weatherStatsStackView.arrangedSubviews[safe: 1] as? UILabel
                let label3 = self.weatherStatsStackView.arrangedSubviews[safe: 2] as? UILabel
                
                label1?.text = "Temp: \(currentTemp ?? 0)"
                label2?.text = "Max: \(maxTemp ?? 0)"
                label3?.text = "Min: \(minTemp ?? 0)"
                
            } else {
                self.presentAlertControllerWith(title: "Error", message: error?.localizedDescription ?? "Sorry, something went wrong, please try again.")
            }
            
        }
        
        /* //Alternatively, city name can also be searched this way. But, openweathermap returns city name for coords, so we're using that from the response.
        viewModel.getCityNameFor(location: location) { [weak self] city, country, error in
            guard let self = self else { return }
            guard let city = city else {
                let message = error?.localizedDescription ?? "Sorry, something went wrong, please try again."
                self.presentAlertControllerWith(title: "Error", message: message)
                return
            }

            self.activityIndicator.stopAnimating()
            self.currentCityLabel.text = city
        }
         */
    }
}

extension DashboardViewController: SelectDateViewControllerProtocol {
    
    func selectDateViewController(_ controller: SelectDateViewController, didSelect date: Date) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard self.viewModel.isDatePrime(date) else {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                return
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.didUpdateTo(location: self.viewModel.lastKnownLocation)
        }
    }
    
    func selectDateViewControllerDidCancel(_ controller: SelectDateViewController) {
        controller.dismiss(animated: true)
    }
}

extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationManagerAccess()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateTo(location: locations.last)
    }
}

extension DashboardViewController: DashboardControllerProtocol {
    
    
}
