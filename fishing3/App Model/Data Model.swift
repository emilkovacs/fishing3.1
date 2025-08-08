//
//  CatchLog Model.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import SwiftUI
import SwiftData

@Model
class Session {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    @Relationship(deleteRule: .cascade) var entries: [Entry]
    
    var speciesNames: [String] = []

    var speciesSummary: String {
        let counts = Dictionary(grouping: speciesNames, by: { $0 })
            .mapValues { $0.count }

        let uniqueNames = counts
            .sorted { $0.value > $1.value }
            .map { $0.key }

        var result = ""
        var remaining = uniqueNames.count

        for (_, name) in uniqueNames.enumerated() {
            let candidate = result.isEmpty ? name : result + ", " + name
            if candidate.count > 24 {
                let extra = remaining
                result += ", +\(extra)"
                break
            } else {
                result = candidate
                remaining -= 1
            }
        }

        return result
    }
    
    
    init(entries: [Entry]) {
        self.id = UUID()
        self.timestamp = Date()
        self.entries = entries
    }
    
    
    init(id: UUID, timestamp: Date, entries: [Entry]) {
        self.id = id
        self.timestamp = timestamp
        self.entries = entries
    }
}


@Model
class Entry {
    
    //Automatic values
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    
    @Relationship(deleteRule: .cascade) var weather: EntryWeather?
    
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
    

    init(
        id: UUID, timestamp: Date, latitude: Double, longitude: Double, weather: EntryWeather? = nil, species: Species? = nil, bait: Bait? = nil, weight: Double? = nil, length: Double? = nil, notes: String, imageIDs: [String], castingMethod: CastingMethod, catchDepth: Double? = nil, bottomType: BottomType, waterTemperature: Double? = nil, waterVisibility: Double? = nil, tideState: TideState
    ) {
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
    var timestamp: Date
    var name: String
    var water: SpeciesWater
    var behaviour: SpeciesBehaviour
    var star: Bool
    
    init(id: UUID, name: String, water: SpeciesWater, behaviour: SpeciesBehaviour,star: Bool) {
        self.id = id
        self.timestamp = Date()
        self.name = name
        self.water = water
        self.behaviour = behaviour
        self.star = star
    }
    init(_ name: String, _ water: SpeciesWater, _ behaviour: SpeciesBehaviour,) {
        self.id = UUID()
        self.timestamp = Date()
        self.name = name
        self.water = water
        self.behaviour = behaviour
        self.star = false
    }
}



@Model
class Bait {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var name: String
    var type: BaitType
    var position: BaitPosition
    var notes: String = ""
    var star: Bool
    
    init(id: UUID, name: String, type: BaitType, position: BaitPosition, notes: String,star: Bool) {
        self.id = id
        self.timestamp = Date()
        self.name = name
        self.type = type
        self.position = position
        self.notes = notes
        self.star = star
    }
    
    init(_ name: String, _ type: BaitType, _ position: BaitPosition, _ notes: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.name = name
        self.type = type
        self.position = position
        self.notes = notes
        self.star = false
    }
   
    
}

extension View {
    func superContainer() -> some View {
        self.modelContainer(for: [Session.self,Entry.self,Species.self,Bait.self,EntryWeather.self], inMemory: false, isAutosaveEnabled: false)
    }
}


