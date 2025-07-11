//
//  Weather Model.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation
import SwiftData

import CoreLocation
import WeatherKit

//MARK: - MANAGER


 /// Because  it's not on the main thread,
/*
 Task {
     let weather = try await WeatherManager.shared.getWeather(location: loc)
     await MainActor.run {
         self.viewModel.weather = weather
     }
 }
 */

class WeatherManager {
    
    private let weatherService = WeatherService()
    
    private let maxCacheDuration: TimeInterval = 15 * 60 // 15 minutes
    private let distanceThreshold: CLLocationDistance = 10_000 // 5 km
    
    private var lastFetchedAt: Date?
    var lastLocation: CLLocation?
    private var cachedWeather: EntryWeather?
    
    
    init() {}
    
    func getWeather(location: CLLocation) async throws -> EntryWeather {
        let now = Date()
        
        if let lastLoc = lastLocation,
           let lastTime = lastFetchedAt,
           let cached = cachedWeather {
            
            let distance = location.distance(from: lastLoc)
            let timeSinceLast = now.timeIntervalSince(lastTime)
            
            if distance < distanceThreshold && timeSinceLast < maxCacheDuration {
            #if DEBUG
            print("☁️ Cached weather data.")
            #endif
                return cached
            }
        }
        
        let weather = try await weatherService.weather(for: location)
        #if DEBUG
        print("🌩️ New weather API call.")
        #endif
        lastFetchedAt = now
        lastLocation = location
        let newWeather =  EntryWeather(weather: weather)
        cachedWeather = newWeather
        return newWeather
    }
    
    func refreshWeather(location: CLLocation) async throws -> EntryWeather {
        #if DEBUG
        print("🌩️ Forced New weather API call.")
        #endif
        let weather = try await weatherService.weather(for: location)
        lastFetchedAt = Date()
        lastLocation = location
        let newWeather =  EntryWeather(weather: weather)
        cachedWeather = newWeather

        return newWeather
    }
    
    func clearCache() {
        lastFetchedAt = nil
        lastLocation = nil
        cachedWeather = nil
    }
}



//MARK: - MODEL

@Model
class EntryWeather {
    @Attribute(.unique) var id: UUID
    
    // Temperature
    var temp_current: Double
    var temp_feels: Double
    var temp_low: Double
    var temp_high: Double
    
    // Pressure & Humidity
    var humidity: Double
    var pressure: Double
    var pressureTrend: EntryPressureTrend
    
    // Light & Sky Conditions
    var condition: String
    var condition_symbol: String
    var cloudCover: Double
    var uvIndex: Int
    
    //Day
    var isDaylight: Bool
    var sunset: Date
    var sunrise: Date
    var dawn: Date
    var dusk: Date
    
    var visibility: Double
    
    // Wind
    var wind_speed: Double
    var wind_gusts: Double
    
    //Rain
    var precipitation_amount: Double
    var precipitation_chance: Double
    
    //Moon
    var moon: EntryMoonPhase
    
    
    init(weather: Weather){
        
        let current = weather.currentWeather
        let forecast = weather.dailyForecast.first
        
        self.id = UUID()
        
        self.temp_current = current.temperature.value
        self.temp_feels = current.apparentTemperature.value
        self.temp_low = forecast?.lowTemperature.value ?? current.temperature.value
        self.temp_high = forecast?.highTemperature.value ?? current.temperature.value
        
        self.humidity = current.humidity
        self.pressure = current.pressure.value
        self.pressureTrend = EntryPressureTrend(rawValue: current.pressureTrend.rawValue) ?? .error
        
        self.condition = current.condition.description
        self.condition_symbol = current.symbolName
        self.cloudCover = current.cloudCover
        self.uvIndex = current.uvIndex.value
        self.isDaylight = current.isDaylight
        self.sunset = forecast?.sun.sunset ?? Date()
        self.sunrise = forecast?.sun.sunrise ?? Date()
        self.dawn =  forecast?.sun.civilDawn ?? Date()
        self.dusk = forecast?.sun.civilDusk ?? Date()
        
        self.visibility = current.visibility.value
        self.wind_speed = current.wind.speed.value
        self.wind_gusts = current.wind.gust?.value ?? 0
        
        self.precipitation_amount = current.precipitationIntensity.value
        self.precipitation_chance = forecast?.precipitationChance ?? 0
        self.moon = EntryMoonPhase(rawValue:  forecast?.moon.phase.description ?? "error") ?? .error
    }
    
    init(id: UUID, temp_current: Double, temp_feels: Double, temp_low: Double, temp_high: Double, humidity: Double, pressure: Double, pressureTrend: EntryPressureTrend, condition: String, condition_symbol: String, cloudCover: Double, uvIndex: Int, isDaylight: Bool, sunset: Date, sunrise: Date, dawn: Date, dusk: Date, visibility: Double, wind_speed: Double, wind_gusts: Double, precipitation_amount: Double, precipitation_chance: Double, moon: EntryMoonPhase) {
        self.id = id
        self.temp_current = temp_current
        self.temp_feels = temp_feels
        self.temp_low = temp_low
        self.temp_high = temp_high
        self.humidity = humidity
        self.pressure = pressure
        self.pressureTrend = pressureTrend
        self.condition = condition
        self.condition_symbol = condition_symbol
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.isDaylight = isDaylight
        self.sunset = sunset
        self.sunrise = sunrise
        self.dawn = dawn
        self.dusk = dusk
        self.visibility = visibility
        self.wind_speed = wind_speed
        self.wind_gusts = wind_gusts
        self.precipitation_amount = precipitation_amount
        self.precipitation_chance = precipitation_chance
        self.moon = moon
    }
    
}




