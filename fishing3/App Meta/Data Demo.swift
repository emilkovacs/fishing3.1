//
//  DataDemo.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

#if DEBUG
import SwiftUI
import SwiftData
import CoreLocation

struct DataDemo: View {
    
    @Environment(\.modelContext) var context
    @Query var allEntries: [Entry]
    @Query var allSpecies: [Species]
    @Query var allBaits: [Bait]
    @Query var allWeathers: [EntryWeather]
    
    @State private var slider: Double = 100
    
    @State private var demoWeather: EntryWeather?
    
    var body: some View {
        VStack{
            
            let entryDescriptor = FetchDescriptor<Entry>(predicate: #Predicate{$0.species != nil})
            let entryCount = (try? context.fetchCount(entryDescriptor) ) ?? 1111
            
            let speciesDescriptor = FetchDescriptor<Species>(predicate: #Predicate{$0.name != "alma"})
            let speciesCount = (try? context.fetchCount(speciesDescriptor) ) ?? 1111
            
            let baitDescriptor = FetchDescriptor<Bait>(predicate: #Predicate{$0.name != "alma"})
            let baitCount = (try? context.fetchCount(baitDescriptor) ) ?? 1111
            
            let weatherDescriptor = FetchDescriptor<EntryWeather>(predicate: #Predicate{$0.condition_symbol != "alma"})
            let weatherCount = (try? context.fetchCount(weatherDescriptor) ) ?? 1111
            
          
            Text("Entries: \(entryCount)")
            HStack{
                Text("Species: \(speciesCount)  ")
                Text("Baits: \(baitCount)")
                Text("Weathers: \(weatherCount)")
            }
            .padding(.bottom,32)
            .onAppear{
                //slider = Double(entryCount)
            }
            
            
            Text("Slider value: \(Int(slider))")

            
        
            Slider(value: $slider, in: 0...5000,step: 100)
            
            HStack{
                Button("Clear", systemImage: "delete.left.fill") {
                     clearDatabase()
                }
                .buttonStyle(.bordered)
                .padding(.trailing)
                
                Button("Replace", systemImage: "plus.circle.fill") {
                    Task { @MainActor in
                        await repopulateDatabase()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let bitch = demoWeather {
                Text(bitch.moonrise.description)
            }
            Text("A")

            if let first = allEntries.first {
                if let wthr = first.weather {
                    Text(wthr.temp_low.description)
                }
            }
            

            
        }
        .padding(32)
        
        
    }
    
    
    
    func clearDatabase()  {
        let localContext = context
        allEntries.forEach { entry in localContext.delete(entry)}
        allSpecies.forEach { entry in localContext.delete(entry)}
        allBaits.forEach { entry in localContext.delete(entry)}
        allWeathers.forEach { entry in localContext.delete(entry)}
        print("Context cleared")
        
        do {
            try localContext.save()
        } catch {
            print("Error saving context")
        }
    }
    
    func repopulateDatabase() async {
        // Insert species and bait
        DemoData.species.forEach { context.insert($0) }
        DemoData.baits.forEach { context.insert($0) }

        for _ in 1...Int(slider) {
            let locationCoord = DemoData.locations.randomElement() ?? CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
            let location = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)

            /*
            let weather: EntryWeather
            do {
                weather = try await WeatherManager.shared.getWeather(location: location)
            } catch {
                print("⚠️ Weather fetch failed: \(error)")
                continue
            }
             */
            
            let entry = Entry(lat: locationCoord.latitude, lon: locationCoord.longitude)
            entry.timestamp = DemoData().randomDates(count: 1).first!
            entry.weather = DemoData.weathers.randomElement()!
            entry.species = allSpecies.randomElement() ?? Species("Error", .unknown, .unknown)
            entry.bait = allBaits.randomElement() ?? Bait("Error", .unknown, .unknown, "Error")
            entry.weight = DemoData.fishWeights.randomElement()
            entry.length = DemoData.fishLengths.randomElement()
            entry.waterTemperature = DemoData.waterTemperatures.randomElement() ?? 11
            entry.waterVisibility = DemoData.waterVisibilities.randomElement() ?? 11
            entry.catchDepth = DemoData.catchDepts.randomElement() ?? 11
            entry.castingMethod = DemoData.methods.randomElement() ?? .unknown
            entry.notes = DemoData.notes.randomElement() ?? "Error"

            context.insert(entry)
        }

        do {
            try context.save()
            print("✅ Finished saving entries.")
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
}

#Preview {
    DataDemo()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
        
}

struct DemoData {
    
    static let species: [Species] = [
        Species("Atlantic Cod", .salty, .predator),
        Species("European Sea Bass", .salty, .predator),
        Species("Atlantic Mackerel", .salty, .predator),
        Species("European Eel", .fresh, .predator),
        Species("Common Sole", .salty, .prey),
        Species("Turbot", .salty, .predator),
        Species("Haddock", .salty, .prey),
        Species("Plaice", .salty, .prey),
        Species("Hake", .salty, .predator),
        Species("Ling", .salty, .predator),
        Species("Sprat", .salty, .prey),
        Species("Capelin", .salty, .prey),
        Species("Anchovy", .salty, .prey),
        Species("Sardine", .salty, .prey),
        Species("Horse Mackerel", .salty, .predator),
        Species("Garfish", .salty, .predator),
        Species("Red Mullet", .salty, .prey),
        Species("John Dory", .salty, .predator),
        Species("Whiting", .salty, .predator),
        Species("Pollack", .salty, .predator),
        Species("Conger Eel", .salty, .predator),
        Species("Gilt-head Bream", .salty, .prey),
        Species("Black Sea Bream", .salty, .prey),
        Species("Blue Whiting", .salty, .prey),
        Species("Megrim", .salty, .prey),
        Species("Boarfish", .salty, .prey),
        Species("Rough Dab", .salty, .prey),
        Species("Fourbeard Rockling", .salty, .predator),
        Species("Smelt", .fresh, .prey),
        Species("Pouting", .salty, .prey),
        Species("Zander", .fresh, .predator),
        Species("Perch", .fresh, .predator),
        Species("Pike", .fresh, .predator),
        Species("Tench", .fresh, .prey),
        Species("Roach", .fresh, .prey),
        Species("Rudd", .fresh, .prey),
        Species("Chub", .fresh, .predator),
        Species("Bream", .fresh, .prey),
        Species("Grayling", .fresh, .prey),
        Species("Minnow", .fresh, .prey),
        Species("Bullhead", .fresh, .prey),
        Species("Sturgeon", .fresh, .predator),
        Species("Shad", .salty, .prey),
        Species("Lamprey", .fresh, .predator),
        Species("Sea Trout", .salty, .predator),
        Species("Atlantic Salmon", .fresh, .predator),
        Species("Brown Trout", .fresh, .predator),
        Species("Arctic Char", .fresh, .predator),
        Species("European Flounder", .salty, .prey),
        Species("Wels Catfish", .fresh, .predator)
    ]
    static let baits: [Bait] = [
        Bait("Spinnerbait", .lure, .midwater, ""),
        Bait("Crankbait", .lure, .sinking, ""),
        Bait("Jerkbait", .lure, .suspending, ""),
        Bait("Swimbait", .lure, .midwater, ""),
        Bait("Chatterbait", .lure, .midwater, ""),
        Bait("Soft Plastic Worm", .lure, .bottom, ""),
        Bait("Grub", .lure, .bottom, ""),
        Bait("Tube Bait", .lure, .bottom, ""),
        Bait("Creature Bait", .lure, .bottom, ""),
        Bait("Drop Shot Worm", .lure, .suspending, ""),
        Bait("Topwater Frog", .lure, .topwater, ""),
        Bait("Buzzbait", .lure, .topwater, ""),
        Bait("Pencil Popper", .lure, .topwater, ""),
        Bait("Walk-the-Dog", .lure, .topwater, ""),
        Bait("Poppers", .lure, .topwater, ""),
        Bait("Jig", .lure, .bottom, ""),
        Bait("Football Jig", .lure, .bottom, ""),
        Bait("Swim Jig", .lure, .midwater, ""),
        Bait("Finesse Jig", .lure, .bottom, ""),
        Bait("Hair Jig", .lure, .bottom, ""),
        Bait("Inline Spinner", .lure, .midwater, ""),
        Bait("Spoon", .lure, .sinking, ""),
        Bait("Flutter Spoon", .lure, .sinking, ""),
        Bait("Casting Spoon", .lure, .sinking, ""),
        Bait("Jigging Spoon", .lure, .sinking, ""),
        Bait("Live Worm", .bait, .bottom, ""),
        Bait("Nightcrawler", .bait, .bottom, ""),
        Bait("Minnow", .bait, .midwater, ""),
        Bait("Shiner", .bait, .midwater, ""),
        Bait("Leech", .bait, .bottom, ""),
        Bait("Cut Bait", .bait, .bottom, ""),
        Bait("Squid Strip", .bait, .bottom, ""),
        Bait("Clam", .bait, .bottom, ""),
        Bait("Mussel", .bait, .bottom, ""),
        Bait("Sandworm", .bait, .bottom, ""),
        Bait("PowerBait", .bait, .suspending, ""),
        Bait("Trout Nugget", .bait, .suspending, ""),
        Bait("Corn", .bait, .bottom, ""),
        Bait("Cheese", .bait, .bottom, ""),
        Bait("Dough Ball", .bait, .bottom, ""),
        Bait("Salmon Egg", .bait, .suspending, ""),
        Bait("Bloodworm", .bait, .bottom, ""),
        Bait("Crayfish Imitation", .lure, .bottom, ""),
        Bait("Ned Rig", .lure, .bottom, ""),
        Bait("Wacky Rig", .lure, .suspending, ""),
        Bait("Neko Rig", .lure, .bottom, ""),
        Bait("Texas Rig", .lure, .bottom, ""),
        Bait("Carolina Rig", .lure, .bottom, ""),
        Bait("Drop Shot Rig", .lure, .suspending, ""),
        Bait("Spinner Rig", .lure, .midwater, "")
    ]
    static let locations: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 44.360011, longitude: 22.385922),
        CLLocationCoordinate2D(latitude: 42.413350, longitude: 22.077037),
        CLLocationCoordinate2D(latitude: 42.502508, longitude: 20.550549),
        CLLocationCoordinate2D(latitude: 42.581663, longitude: 18.913639),
        CLLocationCoordinate2D(latitude: 45.257016, longitude: 19.395527),
        CLLocationCoordinate2D(latitude: 44.210412, longitude: 18.961300),
        CLLocationCoordinate2D(latitude: 45.885407, longitude: 20.146437),
        CLLocationCoordinate2D(latitude: 43.003551, longitude: 22.616220),
        CLLocationCoordinate2D(latitude: 44.462379, longitude: 20.364264),
        CLLocationCoordinate2D(latitude: 43.945652, longitude: 22.043072),
        CLLocationCoordinate2D(latitude: 43.305882, longitude: 19.236143),
        CLLocationCoordinate2D(latitude: 44.816982, longitude: 20.055514),
        CLLocationCoordinate2D(latitude: 44.275671, longitude: 22.238257),
        CLLocationCoordinate2D(latitude: 45.221273, longitude: 22.035756),
        CLLocationCoordinate2D(latitude: 45.297291, longitude: 22.463317),
        CLLocationCoordinate2D(latitude: 45.320947, longitude: 20.919727),
        CLLocationCoordinate2D(latitude: 42.729310, longitude: 18.998462),
        CLLocationCoordinate2D(latitude: 44.832151, longitude: 19.420348),
        CLLocationCoordinate2D(latitude: 43.754204, longitude: 20.379212),
        CLLocationCoordinate2D(latitude: 44.742587, longitude: 22.136204),
        CLLocationCoordinate2D(latitude: 42.685035, longitude: 19.173285),
        CLLocationCoordinate2D(latitude: 44.260240, longitude: 20.643728),
        CLLocationCoordinate2D(latitude: 42.729013, longitude: 22.936058),
        CLLocationCoordinate2D(latitude: 43.001253, longitude: 18.853442),
        CLLocationCoordinate2D(latitude: 45.347222, longitude: 22.646515),
        CLLocationCoordinate2D(latitude: 44.302640, longitude: 19.410329),
        CLLocationCoordinate2D(latitude: 44.188525, longitude: 21.376274),
        CLLocationCoordinate2D(latitude: 44.299187, longitude: 20.057910),
        CLLocationCoordinate2D(latitude: 44.847711, longitude: 21.349862),
        CLLocationCoordinate2D(latitude: 43.895527, longitude: 18.945345),
        CLLocationCoordinate2D(latitude: 43.017569, longitude: 18.871934),
        CLLocationCoordinate2D(latitude: 44.511519, longitude: 19.254717),
        CLLocationCoordinate2D(latitude: 45.679123, longitude: 19.281617),
        CLLocationCoordinate2D(latitude: 44.622776, longitude: 18.885169),
        CLLocationCoordinate2D(latitude: 44.729867, longitude: 22.159486),
        CLLocationCoordinate2D(latitude: 44.617818, longitude: 19.329745),
        CLLocationCoordinate2D(latitude: 44.539682, longitude: 21.964742),
        CLLocationCoordinate2D(latitude: 42.955712, longitude: 20.066678),
        CLLocationCoordinate2D(latitude: 42.276473, longitude: 19.472099),
        CLLocationCoordinate2D(latitude: 44.862945, longitude: 21.438023),
        CLLocationCoordinate2D(latitude: 44.119944, longitude: 19.201252),
        CLLocationCoordinate2D(latitude: 43.303168, longitude: 21.897184),
        CLLocationCoordinate2D(latitude: 45.284997, longitude: 22.602630),
        CLLocationCoordinate2D(latitude: 44.464078, longitude: 21.787896),
        CLLocationCoordinate2D(latitude: 44.770648, longitude: 19.049456),
        CLLocationCoordinate2D(latitude: 43.647395, longitude: 22.648032),
        CLLocationCoordinate2D(latitude: 44.115764, longitude: 21.257014),
        CLLocationCoordinate2D(latitude: 43.823056, longitude: 22.763152),
        CLLocationCoordinate2D(latitude: 44.391217, longitude: 21.779119),
        CLLocationCoordinate2D(latitude: 45.112433, longitude: 19.123709),
        CLLocationCoordinate2D(latitude: 42.340842, longitude: 19.626932),
        CLLocationCoordinate2D(latitude: 44.057744, longitude: 21.940113),
        CLLocationCoordinate2D(latitude: 43.170099, longitude: 22.698862),
        CLLocationCoordinate2D(latitude: 44.112389, longitude: 21.135652),
        CLLocationCoordinate2D(latitude: 45.059866, longitude: 21.646873),
        CLLocationCoordinate2D(latitude: 44.586179, longitude: 21.399242),
        CLLocationCoordinate2D(latitude: 44.437703, longitude: 20.832664),
        CLLocationCoordinate2D(latitude: 44.978842, longitude: 20.022003),
        CLLocationCoordinate2D(latitude: 44.930670, longitude: 20.773280),
        CLLocationCoordinate2D(latitude: 44.827515, longitude: 22.244863),
        CLLocationCoordinate2D(latitude: 44.617263, longitude: 21.041058),
        CLLocationCoordinate2D(latitude: 45.122510, longitude: 22.095180),
        CLLocationCoordinate2D(latitude: 44.681793, longitude: 21.926707),
        CLLocationCoordinate2D(latitude: 44.122387, longitude: 20.082147),
        CLLocationCoordinate2D(latitude: 44.202428, longitude: 22.427951),
        CLLocationCoordinate2D(latitude: 44.159876, longitude: 20.335569),
        CLLocationCoordinate2D(latitude: 44.080134, longitude: 22.152713),
        CLLocationCoordinate2D(latitude: 45.045076, longitude: 21.416391),
        CLLocationCoordinate2D(latitude: 44.735271, longitude: 21.175793),
        CLLocationCoordinate2D(latitude: 45.309754, longitude: 21.891733),
        CLLocationCoordinate2D(latitude: 44.398373, longitude: 19.328887),
        CLLocationCoordinate2D(latitude: 45.302559, longitude: 20.143920),
        CLLocationCoordinate2D(latitude: 44.906991, longitude: 22.266939),
        CLLocationCoordinate2D(latitude: 44.789329, longitude: 20.106964),
        CLLocationCoordinate2D(latitude: 45.069526, longitude: 21.010670),
        CLLocationCoordinate2D(latitude: 44.408104, longitude: 21.864202),
        CLLocationCoordinate2D(latitude: 43.727246, longitude: 21.649157),
        CLLocationCoordinate2D(latitude: 43.085331, longitude: 21.234438),
        CLLocationCoordinate2D(latitude: 44.353797, longitude: 20.011196),
        CLLocationCoordinate2D(latitude: 44.641313, longitude: 20.960798),
        CLLocationCoordinate2D(latitude: 45.000215, longitude: 20.459831),
        CLLocationCoordinate2D(latitude: 44.761496, longitude: 21.348761),
        CLLocationCoordinate2D(latitude: 43.658217, longitude: 19.198301),
        CLLocationCoordinate2D(latitude: 43.986853, longitude: 22.820365),
        CLLocationCoordinate2D(latitude: 44.956342, longitude: 20.628070),
        CLLocationCoordinate2D(latitude: 44.613245, longitude: 22.693880),
        CLLocationCoordinate2D(latitude: 45.083797, longitude: 20.142516),
        CLLocationCoordinate2D(latitude: 44.279962, longitude: 20.307236),
        CLLocationCoordinate2D(latitude: 43.551808, longitude: 19.122740),
        CLLocationCoordinate2D(latitude: 44.542713, longitude: 21.255405),
        CLLocationCoordinate2D(latitude: 43.841340, longitude: 21.584115),
        CLLocationCoordinate2D(latitude: 44.745905, longitude: 20.480593),
        CLLocationCoordinate2D(latitude: 45.088149, longitude: 22.405081),
        CLLocationCoordinate2D(latitude: 44.070965, longitude: 22.331086),
        CLLocationCoordinate2D(latitude: 44.136403, longitude: 21.621929),
        CLLocationCoordinate2D(latitude: 44.377792, longitude: 21.284729),
        CLLocationCoordinate2D(latitude: 43.977437, longitude: 20.041494),
        CLLocationCoordinate2D(latitude: 44.422726, longitude: 22.761832),
        CLLocationCoordinate2D(latitude: 44.524112, longitude: 21.309422),
        CLLocationCoordinate2D(latitude: 44.794831, longitude: 21.690044)
    ]
   
    var dates: [Date] {
        randomDates(count: 500)
    }
    
    static let fishWeights: [Double] = [
        16.22, 15.41, 13.59, 24.54, 19.95, 24.78, 3.83, 9.82, 24.84, 3.8,
        5.66, 13.41, 19.76, 20.33, 15.79, 5.41, 20.32, 8.1, 23.63, 20.58,
        3.66, 7.96, 4.3, 10.48, 5.24, 16.76, 18.85, 12.05, 5.76, 0.96,
        11.71, 4.46, 20.37, 11.5, 2.09, 10.73, 8.23, 18.3, 9.74, 15.54,
        14.35, 2.61, 14.33, 2.17, 2.51, 16.51, 2.81, 17.6, 9.43, 8.94
    ]
    static let fishLengths: [Double] = [
        116.6, 128.1, 105.6, 84.6, 87.2, 41.4, 37.4, 55.7, 128.9, 17.1,
        87.0, 26.4, 68.1, 77.6, 83.9, 36.7, 78.4, 11.3, 141.0, 74.3,
        123.7, 59.9, 146.7, 104.8, 20.6, 32.2, 138.4, 14.9, 132.7, 12.7,
        98.0, 114.6, 58.9, 129.7, 17.6, 126.1, 119.8, 132.0, 68.0, 64.6,
        86.2, 123.5, 92.7, 28.6, 107.9, 70.9, 113.1, 148.9, 123.8, 21.4
    ]
    
    static let methods: [CastingMethod] = [
        .unknown,.unknown,.fly,.boat,.shore,.shore,.trolling,.boat,.shore
    ]
    static let waterTemperatures: [Double?] = [
        17,23,14,19,24,27,16,28,nil,nil,nil,nil,nil,nil,nil,nil
    ]
    static let waterVisibilities: [Double?] = [
        44,23,78,39,240,0,16,2,34,168,nil,nil,nil,nil,nil,nil,nil,nil,nil
    ]
    static let catchDepts: [Double?] = [
        168,392,134,234,87,90,234,235,34,55,13,47,345,389,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
    ]
    static let notes: [String] = [
        "","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","Caught right before sunset, very active.",
        "Hit the lure aggressively, near rocks.",
        "Shallow water, early morning strike.",
        "Strong fight, used a soft plastic bait.",
        "Near submerged tree, heavy vegetation.",
        "Took the bait mid-retrieve.",
        "Landed with a jig close to shore.",
        "Wasn't expecting one that big!",
        "Took live bait, slow bite overall.",
        "Caught just after a rainstorm.",
        "Clear water, visible strike.",
        "Deep water, slow retrieve worked.",
        "Aggressive strike, almost lost it.",
        "Strong current, fish pulled hard.",
        "Struck on the pause, classic ambush.",
        "Multiple hits before hooking.",
        "Calm day, sudden action burst.",
        "Unusual spot, near bridge supports.",
        "Hooked while testing a new lure.",
        "Bit as the bait hit the water.",
        "Surface hit, very visual catch.",
        "Buried in weeds after strike.",
        "Used scent attractant, seemed to help.",
        "Caught while reeling in fast.",
        "Snagged briefly before the hook-up.",
        "Was drifting when it hit.",
        "Took a while to tire out.",
        "Cloudy day, consistent action.",
        "Bait was almost too big!",
        "Got lucky—hooked just on the edge."
    ]
    
    static let weathers: [EntryWeather?] = [
        EntryWeather(
          id: UUID(),
          temp_current: 28.5, temp_feels: 30.0, temp_low: 20.0, temp_high: 31.0,
          humidity: 70.0, pressure: 1012.0, pressureTrend: .steady,
          condition: "Clear", condition_symbol: "sun.max",
          cloudCover: 0.1, uvIndex: 8,
          sunset: date(from: "2025-07-01 20:41"),
          sunrise: date(from: "2025-07-01 05:50"),
          moon: .firstQuarter,
          moonrise: date(from: "2025-07-01 00:17"),
          moonset: date(from: "2025-07-01 12:31"),
          visibility: 10_000, wind_speed: 5.0, wind_gusts: 8.0,
          precipitation_amount: 0.0, precipitation_chance: 0.1
        ),
        EntryWeather(
          id: UUID(),
          temp_current: 23.5, temp_feels: 30.5, temp_low: 24.0, temp_high: 32.0,
          humidity: 73.0, pressure: 1212.0, pressureTrend: .steady,
          condition: "Clear", condition_symbol: "sun.max",
          cloudCover: 0.45, uvIndex: 6,
          sunset: date(from: "2025-07-01 20:41"),
          sunrise: date(from: "2025-07-01 05:50"),
          moon: .firstQuarter,
          moonrise: date(from: "2025-07-01 00:17"),
          moonset: date(from: "2025-07-01 12:31"),
          visibility: 10_004, wind_speed: 5.0, wind_gusts: 8.0,
          precipitation_amount: 4.0, precipitation_chance: 0.2
        ),
        EntryWeather(
          id: UUID(),
          temp_current: 27.0, temp_feels: 29.0, temp_low: 21.0, temp_high: 30.0,
          humidity: 75.0, pressure: 1010.5, pressureTrend: .rising,
          condition: "Partly Cloudy", condition_symbol: "cloud.sun",
          cloudCover: 0.4, uvIndex: 7,
          sunset: date(from: "2025-07-21 20:45"),
          sunrise: date(from: "2025-07-21 05:51"),
          moon: .lastQuarter,
          moonrise: date(from: "2025-07-21 03:06"),
          moonset: date(from: "2025-07-21 17:42"),
          visibility: 10_000, wind_speed: 4.0, wind_gusts: 6.0,
          precipitation_amount: 0.5, precipitation_chance: 0.3
        ),
        EntryWeather(
          id: UUID(),
          temp_current: 26.0, temp_feels: 28.0, temp_low: 20.5, temp_high: 29.0,
          humidity: 72.0, pressure: 1009.0, pressureTrend: .falling,
          condition: "Overcast", condition_symbol: "cloud.fill",
          cloudCover: 0.8, uvIndex: 5,
          sunset: date(from: "2025-07-31 20:38"),
          sunrise: date(from: "2025-07-31 05:47"),
          moon: .waxingCrescent,
          moonrise: date(from: "2025-07-31 12:58"),
          moonset: date(from: "2025-07-30 18:38"), // previous evening
          visibility: 9_000, wind_speed: 6.0, wind_gusts: 9.0,
          precipitation_amount: 1.2, precipitation_chance: 0.5
        )
    ]
    
    
    //Helpers
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func randomDates(count: Int) -> [Date] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/New_York")

        guard let startDate = formatter.date(from: "2022-01-01"),
              let endDate = formatter.date(from: "2025-12-31") else {
            fatalError("Invalid date range")
        }

        let startTime = startDate.timeIntervalSince1970
        let endTime = endDate.timeIntervalSince1970
        var results: [Date] = []

        for _ in 0..<count {
            // Pick random day between start and end
            let randomDayInterval = TimeInterval.random(in: startTime...endTime)
            let randomDay = Date(timeIntervalSince1970: randomDayInterval)

            // Extract just Y/M/D
            var components = calendar.dateComponents([.year, .month, .day], from: randomDay)
            components.hour = Int.random(in: 0..<24)
            components.minute = Int.random(in: 0..<60)

            if let finalDate = calendar.date(from: components) {
                results.append(finalDate)
            }
        }

        return results
    }


    
}

func date(from string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    formatter.timeZone = TimeZone(identifier: "America/New_York") // or your desired TZ
    return formatter.date(from: string)!
}

#endif

