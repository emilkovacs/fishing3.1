//
//  Location Model.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation
import CoreLocation


@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var locationCompletion: ((CLLocation) -> Void)?
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let fallbackLocation = CLLocation(latitude: 46.09776, longitude: 19.75805) // Palic Park
    
    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: - 1. Request Authorization
    
    func requestAuthorization() {
        let status = manager.authorizationStatus
        authorizationStatus = status
        
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

    }
    
    // MARK: - 2. Get Current Location
    
    func getCurrentLocation(completion: @escaping (CLLocation) -> Void) {
            authorizationStatus = manager.authorizationStatus
            
            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationCompletion = completion
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters /// #Q is this good?
                manager.requestLocation()
            case .notDetermined, .denied, .restricted:
                completion(fallbackLocation)
            @unknown default:
                completion(fallbackLocation)
            }
        }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationCompletion?(location)
        } else {
            locationCompletion?(fallbackLocation)
        }
        locationCompletion = nil
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        locationCompletion?(fallbackLocation)
        locationCompletion = nil
    }
}
