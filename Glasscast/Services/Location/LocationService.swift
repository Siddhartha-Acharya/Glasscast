//
//  LocationService.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Protocol

protocol LocationServiceProtocol {
    func requestPermission() async -> Bool
    func getCurrentLocation() async throws -> Location
    func startMonitoringLocation()
    func stopMonitoringLocation()
    var authorizationStatus: CLAuthorizationStatus { get }
}

// MARK: - Location Service Implementation

@MainActor
final class LocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Properties
    
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<Location, Error>?
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    @Published var isAuthorized: Bool = false

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    // MARK: - Initialization
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // 1 km
    }
    
    // MARK: - Permission
    
    func requestPermission() async -> Bool {
        let status = locationManager.authorizationStatus
        
        // Already authorized
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            return true
        }
        
        // Already denied
        if status == .denied || status == .restricted {
            return false
        }
        
        // Need to request
        return await withCheckedContinuation { continuation in
            self.permissionContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - Get Current Location
    
    func getCurrentLocation() async throws -> Location {
        // Check permission first
        let hasPermission = await requestPermission()
        
        guard hasPermission else {
            throw LocationError.permissionDenied
        }
        
        // Request location
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    // MARK: - Monitoring
    
    func startMonitoringLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let authorized =
                manager.authorizationStatus == .authorizedWhenInUse ||
                manager.authorizationStatus == .authorizedAlways

            isAuthorized = authorized

            permissionContinuation?.resume(returning: authorized)
            permissionContinuation = nil
        }
    }

    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let clLocation = locations.last else { return }
            
            // Convert CLLocation to our Location model
            let location = await convertToLocation(clLocation)
            
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationContinuation?.resume(throwing: LocationError.permissionDenied)
                case .network:
                    locationContinuation?.resume(throwing: LocationError.networkError)
                case .locationUnknown:
                    locationContinuation?.resume(throwing: LocationError.locationUnavailable)
                default:
                    locationContinuation?.resume(throwing: LocationError.unknown(error))
                }
            } else {
                locationContinuation?.resume(throwing: LocationError.unknown(error))
            }
            
            locationContinuation = nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertToLocation(_ clLocation: CLLocation) async -> Location {
        // Use geocoder to get city name
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            
            if let placemark = placemarks.first {
                let cityName = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                let country = placemark.isoCountryCode ?? placemark.country ?? "Unknown"
                
                return Location(
                    name: cityName,
                    country: country,
                    latitude: clLocation.coordinate.latitude,
                    longitude: clLocation.coordinate.longitude,
                    timezone: placemark.timeZone?.identifier
                )
            }
        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
        }
        
        // Fallback if geocoding fails
        return Location(
            name: "Current Location",
            country: "",
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude
        )
    }
}

// MARK: - Location Error

enum LocationError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    case networkError
    case geocodingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable it in Settings."
        case .permissionRestricted:
            return "Location services are restricted on this device."
        case .locationUnavailable:
            return "Unable to determine your location. Please try again."
        case .networkError:
            return "Network error while getting location."
        case .geocodingFailed:
            return "Failed to determine city name for your location."
        case .unknown(let error):
            return "Location error: \(error.localizedDescription)"
        }
    }
}

final class MockLocationService: LocationServiceProtocol {
    var shouldFail = false
    var mockLocation: Location?
    var mockAuthStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var delay: TimeInterval = 0.5
    
    var authorizationStatus: CLAuthorizationStatus {
        mockAuthStatus
    }
    
    func requestPermission() async -> Bool {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return mockAuthStatus == .authorizedWhenInUse || mockAuthStatus == .authorizedAlways
    }
    
    func getCurrentLocation() async throws -> Location {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldFail {
            throw LocationError.locationUnavailable
        }
        
        return mockLocation ?? Location(
            name: "San Francisco",
            country: "US",
            latitude: 37.7749,
            longitude: -122.4194,
            timezone: "America/Los_Angeles"
        )
    }
    
    func startMonitoringLocation() {
        print("Mock: Started monitoring location")
    }
    
    func stopMonitoringLocation() {
        print("Mock: Stopped monitoring location")
    }
}
