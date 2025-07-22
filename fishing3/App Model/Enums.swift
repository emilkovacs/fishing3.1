//
//  Enums.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation


//MARK: - BAIT
/// Enums connected to baits for data categorization.
enum BaitType: String, Selectable {
    case bait, lure, fly, other, unknown
    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .bait: return "Bait"
        case .lure: return "Lure"
        case .fly: return "Fly"
        case .other: return "Other"
        case .unknown: return "Unknown"
        }
    }
    
    var shortLabel: String { self.label }
    
    var symbolName: String {
        switch self {
        case .bait: return "leaf.circle.fill"
        case .lure: return "circle.circle.fill"
        case .fly: return "circle.circle.fill"
        case .other: return "circle.hexagongrid.circle.fill"
        case .unknown: return "questionmark"
        }
    }
    
    
}
enum BaitPosition: String, Selectable {
    case  topwater, midwater, suspending, sinking, bottom, unknown
    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .topwater: return "Topwater"
        case .midwater: return "Midwater"
        case .suspending: return "Suspending"
        case .sinking: return "Sinking"
        case .bottom: return "Bottom"
        case .unknown: return "Unknown"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .topwater: return "Top"
        case .midwater: return "Mid"
        case .suspending: return "Susp"
        case .sinking: return "Sink"
        case .bottom: return "Bottom"
        case .unknown: return "Unknown"
        }
    }
    
    var symbolName: String {
        switch self {
        case .topwater: return "circle.fill"
        case .midwater: return "circle.fill"
        case .suspending: return "circle.fill"
        case .sinking: return "circle.fill"
        case .bottom: return "circle.fill"
        case .unknown: return "circle.fill"
        }
    }
    
}



//MARK: - SPECIES
/// Enums connected to species for data categorization.
enum SpeciesWater: String, Selectable {
    case fresh, salty, unknown
    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .fresh: return "Fresh water"
        case .salty: return "Salt water"
        case .unknown: return "Unknown"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .fresh: return "Fresh"
        case .salty: return "Salty"
        case .unknown: return "Unknown"
        }
    }
    
    var symbolName: String {
        switch self {
        case .fresh: return "drop.fill"
        case .salty: return "drop.halffull"
        case .unknown: return "questionmark"
        }
    }
    
}
enum SpeciesBehaviour: String, Selectable {
    case predator, prey, unknown
    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .prey: return "Prey"
        case .predator: return "Predator"
        case .unknown: return "Unknown"
        }
    }
    var shortLabel: String {self.label}
    var symbolName: String {
        switch self {
        case .prey: return "leaf.fill"
        case .predator: return "fish.fill"
        case .unknown: return "questionmark"
        }
    }
}


//MARK: - LIST AND EDIT

enum ListOrders: String, Selectable {
    case recents, lastAdded, forward, reverse
    var id: String {self.rawValue}
    var label: String {
        switch self {
        case .recents: return "Recents"
        case .lastAdded: return "Last Added"
        case .forward: return "A-Z"
        case .reverse: return "Z-A"
        }
    }
    var shortLabel: String {
        self.label
    }
    var symbolName: String {
        switch self {
        case .recents: return "cursorarrow.click.badge.clock"
        case .lastAdded: return "plus.arrow.trianglehead.clockwise"
        case .forward: return "arrowshape.forward.circle"
        case .reverse: return "arrowshape.backward.circle"
        }
    }
    
}
enum ListModes { case select, edit }


//MARK: - DETAILS

enum CastingMethod: String, Selectable {
    case shore,boat,fly, trolling, unknown
    
    var id: String {self.rawValue}
    
    var label: String {
        switch self {
        case .shore: return "Shore casting"
        case .boat: return "Boat casting"
        case .fly: return "Fly"
        case .trolling: return "Trolling"
        case .unknown: return "Unknown"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .shore: return "Shore"
        case .boat: return "Boat"
        case .fly: return "Fly"
        case .trolling: return "Trolling"
        case .unknown: return "Unknown"
        }
    }
    
    var symbolName: String {
        switch self {
        case .shore: return "figure.fishing"
        case .boat: return "sailboat.fill"
        case .fly: return "fish.fill"
        case .trolling: return "stroller.fill"
        case .unknown: return "questionmark"
        }
    }
       
    var viewLabel: String {
        switch self {
        case .shore: return "from Shore"
        case .boat: return "from Boat"
        case .fly: return "with Fly"
        case .trolling: return "with Trolling"
        case .unknown: return "unknown method"
        }
    }
        
    
}
enum TideState: String, Selectable {
    case low, incoming, high, outgoing, unknown
    var id: String {self.rawValue}
    var label: String {
        switch self {
        case .low: return "Low Tide"
        case .incoming: return "Incoming Tide"
        case .high: return "High Tide"
        case .outgoing: return "Outgoing Tide"
        case .unknown: return "Unknown"
        }
    }
    var shortLabel: String {
        switch self {
        case .low: return "Low"
        case .incoming: return "Incoming"
        case .high: return "High"
        case .outgoing: return "Outgoing"
        case .unknown: return "Unknown"
        }
    }
    
    var symbolName: String {
        switch self {
        case .low: return "arrow.down"
        case .incoming: return "arrow.up.right"
        case .high: return "arrow.up"
        case .outgoing: return "arrow.down.left"
        case .unknown: return "questionmark"
        }
    }
    
    
}
enum BottomType: String, Selectable {
    case soft       // mud, silt, clay, sand
    case hard       // rock, gravel
    case grass // grass, weeds, submerged vegetation
    case timber  // wood, docks, shell beds
    case reef       // coral, artificial reefs
    case unknown
    
    var id: String {self.rawValue}
    
    var label: String {
        switch self {
        case .soft: return "Soft - mud, silt, clay, sand"
        case .hard: return "Hard - rock, gravel"
        case .grass: return "Grass - vegetation"
        case .timber: return "Timber - wood, docks, logs"
        case .reef: return "Reef - coral, reefs"
        case .unknown: return "Unknown"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .soft: return "Soft"
        case .hard: return "Hard"
        case .grass: return "Grass"
        case .timber: return "Timber"
        case .reef: return "Reef"
        case .unknown: return "Unknown"
        }
    }
    var symbolName: String { "" }
}


//MARK: - WEATHER

enum EntryPressureTrend: String,CaseIterable, Codable {
    case falling, rising, steady, error
    
    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .falling: return "Falling"
        case .rising: return "Rising"
        case .steady: return "Steady"
        case .error: return "Error"
        }
    }
    var symbolName: String {
        switch self {
        case .falling: return "arrow.down.right"
        case .rising: return "arrow.up.right"
        case .steady: return "arrow.right"
        case .error: return "questionmark"
        }
    }
}
enum EntryMoonPhase: String, CaseIterable, Codable {
    case firstQuarter
    case full
    case lastQuarter
    case new
    case waningCrescent
    case waningGibbous
    case waxingCrescent
    case waxingGibbous
    case error

    var label: String {
        switch self {
        case .firstQuarter: return "First Quarter"
        case .full: return "Full"
        case .lastQuarter: return "Last Quarter"
        case .new: return "New"
        case .waningCrescent: return "Waning Crescent"
        case .waningGibbous: return "Waning Gibbous"
        case .waxingCrescent: return "Waxing Crescent"
        case .waxingGibbous: return "Waxing Gibbous"
        case .error: return "Error"
        }
    }

    var symbolName: String {
        switch self {
        case .firstQuarter: return "moonphase.first.quarter"
        case .full: return "moonphase.full.moon"
        case .lastQuarter: return "moonphase.last.quarter"
        case .new: return "moonphase.new.moon"
        case .waningCrescent: return "moonphase.waning.crescent"
        case .waningGibbous: return "moonphase.gibbous"
        case .waxingCrescent: return "moonphase.waxing.crescent"
        case .waxingGibbous: return "moonphase.waxing.gibbous"
        case .error: return "questionmark.circle"
        }
    }
}


//MARK: - PROTOCOLS

///Selectable used to create generics for pickers
protocol Selectable: RawRepresentable, CaseIterable, Codable, Identifiable, Hashable where RawValue == String, AllCases: RandomAccessCollection{
    var label: String { get }
    var shortLabel: String { get }
    var symbolName: String { get }
}



