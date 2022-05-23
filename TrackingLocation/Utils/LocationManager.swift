//
//  LocationManager.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    
    typealias LocationCompletion = (CLLocation) -> ()

    private var locationManager = CLLocationManager()
    private var locationUpdating: LocationCompletion?
    private var locationGetError: ((Error) -> Void)?

    override init() {
        super.init()
        configLocationService()
    }

    private func configLocationService() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func request() {
        let status = locationManager.authorizationStatus
        
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
    }

    func getCurrentLocation() -> CLLocation? {
        return locationManager.location
    }
}
// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            manager.stopUpdatingLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationUpdating?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationGetError?(error)
    }
}
