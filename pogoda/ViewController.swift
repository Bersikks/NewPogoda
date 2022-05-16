//
//  ViewController.swift
//  pogoda
//
//  Created by Гость on 29.04.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temeratureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        startLocationManager()
    }

    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            
        }
    }
    func updateView(){
        cityNameLabel.text = weatherData.name
        weatherDescriptionLabel.text = DataSource.weatherIDs[weatherData.weather[0].id]
        temeratureLabel.text = weatherData.main.temp.description + "*"
        weatherIconImageView.image = UIImage(named: weatherData.weather[0].icon)
    }
    func updateWeatherInfo(latitude: Double, longtitude: Double) {
        let session = URLSession.shared
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&land=London&appid=a289ff68192fd73109e6fcfb7852428f")!
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("DataTask error: \(error!.localizedDescription)")
                return
            }
            do{
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch {
                print(error.localizedDescription)
            }
    }
        task.resume()
}
    
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
            print(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
        }
    }
}
