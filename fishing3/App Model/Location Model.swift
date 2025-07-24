//
//  Location Model.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private var locationCompletion: ((CLLocation) -> Void)?
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    let fallbackLocation = CLLocation(latitude: 46.09776, longitude: 19.75805) // Palic Park
    
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

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        Double(lhs.latitude).roundTo(toPlaces: 4) == Double(rhs.latitude).roundTo(toPlaces: 4) && Double(lhs.longitude).roundTo(toPlaces: 4) == Double(rhs.longitude).roundTo(toPlaces: 4)
        
    }
}


//Map Components
struct MapColorFade: View {
    
    var body: some View {
        LinearGradient(
            colors: [AppColor.tone,AppColor.tone.opacity(0.65),Color.clear],
            startPoint: .bottom,
            endPoint: .top)
            .frame(height: 64)
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
struct MapColorCorrections: View {
    @Environment(\.colorScheme) var colorScheme
    var isSatelite: Bool
    
    var body: some View {
        if colorScheme == .dark {
            Rectangle()
                .fill(AppColor.dark.opacity(isSatelite ? 0.4 : 0.55))
                .blendMode(.overlay)
                .allowsHitTesting(false)
        }
    }
}
struct MapMarker: View {
    var body: some View {
        Circle()
            .fill(AppColor.primary.opacity(0.25))
            .stroke(Color.white, lineWidth: 3)
            .frame(width: 22, height: 22, alignment: .center)
    }
}


