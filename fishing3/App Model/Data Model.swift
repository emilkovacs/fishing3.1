//
//  CatchLog Model.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation
import SwiftData


@Model
class Entry {
    
    //Automatic values
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var weather: Bool?
    
    //Manualy set
    @Relationship var species: Species?
    @Relationship var bait: Bait?
    var weight: Double?
    var length: Double?
    var notes: String = ""
    
    var imageIDs: [String] = []
    
    //Details
    var castingMethod: CastingMethod = CastingMethod.unknown
    var catchDepth: Double?
    var bottomType: BottomType = BottomType.unknown
    
    var waterTemperature: Double?
    var waterVisibility: Double?
    var tideState: TideState = TideState.unknown
    

    init(id: UUID, timestamp: Date, latitude: Double, longitude: Double, weather: Bool? = nil, species: Species? = nil, bait: Bait? = nil, weight: Double? = nil, length: Double? = nil, notes: String, imageIDs: [String], castingMethod: CastingMethod, catchDepth: Double? = nil, bottomType: BottomType, waterTemperature: Double? = nil, waterVisibility: Double? = nil, tideState: TideState) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.weather = weather
        self.species = species
        self.bait = bait
        self.weight = weight
        self.length = length
        self.notes = notes
        self.imageIDs = imageIDs
        self.castingMethod = castingMethod
        self.catchDepth = catchDepth
        self.bottomType = bottomType
        self.waterTemperature = waterTemperature
        self.waterVisibility = waterVisibility
        self.tideState = tideState
    }
    
    init(lat: Double, lon: Double){
        self.id = UUID()
        self.timestamp = Date()
        self.latitude = lat
        self.longitude = lon
    }

}

@Model
class Species {
    @Attribute(.unique) var id: UUID
    var name: String
    var water: SpeciesWater
    var behaviour: SpeciesBehaviour
    
    init(id: UUID, name: String, water: SpeciesWater, behaviour: SpeciesBehaviour) {
        self.id = id
        self.name = name
        self.water = water
        self.behaviour = behaviour
    }
    init(_ name: String, _ water: SpeciesWater, _ behaviour: SpeciesBehaviour) {
        self.id = UUID()
        self.name = name
        self.water = water
        self.behaviour = behaviour
    }
}



@Model
class Bait {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: BaitType
    var position: BaitPosition
    var notes: String = ""
    
    init(id: UUID, name: String, type: BaitType, position: BaitPosition, notes: String) {
        self.id = id
        self.name = name
        self.type = type
        self.position = position
        self.notes = notes
    }
    
    init(_ name: String, _ type: BaitType, _ position: BaitPosition, _ notes: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.position = position
        self.notes = notes
    }
   
    
}

