//
//  ViewEntry.swift
//  fishing3
//
//  Created by Emil Kovács on 15. 7. 2025..
//

import SwiftUI
import SwiftData
import MapKit


// Leave the dropdowns for a bit, they can be sorted out later.
/// Maybe create a `solunar` part for the moon phase and sunrise/sunset etc thing.
/// Maybe some simple charts, comparisons, percentiles?


//Apple Maps and Weather attribution needs to be fixed.

// Implement the photo overlay part, decide on design, options as now:
/// --> Overlay which opens to a photo viewer, like in the old add catch.
/// Overlay which expands and replaces the map.

// Add new marker to map
// Map Satelite switch

///`Finish this fucking part before starting an another.`

/// Controls Back, Edit
/// Map or Photos?
/// Title
/// Details



struct ViewEntry: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let entry: Entry
    
    var body: some View {
        ZStack{
            ScrollView{
                ViewEntryMap(lat: entry.latitude, lon: entry.longitude)
                VStack(alignment: .leading){
                    ViewEntryHeader(entry: entry)
                    ViewEntryDrops(entry: entry)
                }
                .padding()
                .background(
                    VStack(spacing: 0, content: {
                        LinearGradient(
                            colors: [
                                AppColor.tone,
                                AppColor.tone.opacity(0.75),
                                AppColor.tone.opacity(0.0)
                            ],
                            startPoint: .bottom, endPoint: .top)
                            .frame(height: 50)
                        AppColor.tone
                    })
                   
                )
                .padding(.top,-84)
            }
            .scrollIndicators(.hidden)
            
            ViewEntryTopControls()
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
    }
}



//Large Components
struct ViewEntryTopControls: View {
    var body: some View {
        HStack{
            CircleButton("chevron.left") {
                
            }
            Spacer()
            //CircleButton("square.and.arrow.up") {}
            CapsuleButton("pencil.line", "Edit") {
                
            }
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
struct ViewEntryMap: View {
    
    let entryCoordinate: CLLocationCoordinate2D
    let entryRegion: MKCoordinateRegion
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isSatelite: Bool = false
    var mapStyle: MapStyle {
        isSatelite ? MapStyle.hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false) : MapStyle.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll, showsTraffic: false)
    }
    
    private let mapHeight: CGFloat = 480
    
    init(lat: Double, lon: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let delta = 0.006
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: delta, longitudeDelta: delta))
        self.entryCoordinate = coordinate
        self.entryRegion = region
    }
    
    var body: some View {
        ZStack{
            GeometryReader{ geo in
                
                let clampedY = max(geo.frame(in: .global).minY, 0)
                
                ZStack(alignment: .center){
                    Map(initialPosition: .region(entryRegion)){
                        Marker(coordinate: entryCoordinate) {
                            Text("Catch")
                        }
                    }
                    .mapStyle(mapStyle)
                    .grayscale(1.0)
                    .safeAreaPadding(.vertical,190)
                    .safeAreaPadding(.horizontal,6)
                    .frame(height: mapHeight * 1.5)
                    .onLongPressGesture {
                        isSatelite.toggle()
                    }
                    
                    MapColorCorrections(isSatelite: isSatelite)
                    MapColorFade()
                    
                }
                .frame(height: mapHeight + clampedY)
                .offset(y: -clampedY)
            }
            
                
        }
        .frame(height: mapHeight)
    }
    

    
}
struct ViewEntryHeader: View {
    let entry: Entry
    
    var titleLine: String {
        let species = entry.species?.name ?? "Unnamed"
        let bait = entry.bait?.name ?? "Unnamed"
        return "\(species), \(bait)"
    }
    var detailsLine: String {
        let values: [String] = [
            entry.weight.map { "\(Int($0))\(AppUnits.weight)" },
            entry.length.map { "\(Int($0))\(AppUnits.length)" },
            entry.catchDepth.map { "at \(Int($0))\(AppUnits.length) depth" }
        ].compactMap { $0 }

        guard !values.isEmpty else { return "" }
        return values.joined(separator: ", ") + "."
    }

    var body: some View {
        VStack(alignment: .leading,spacing: 12) {
            HStack{
                
                HStack{
                    Image(systemName: "calendar")
                    Text(DateFormatter.dayAndTime.string(from: entry.timestamp))
                }
                    .font(.caption)
                    .padding(.vertical,6)
                    .padding(.horizontal,12)
                    .background(AppColor.secondary)
                    .cornerRadius(30)
                    .padding(.leading,-6)
                Spacer()
            }
            
            Text(titleLine)
                .font(.title)
                .fontWeight(.medium)
            
            Text(detailsLine)
                .foregroundStyle(AppColor.half)
                .padding(.bottom,12)
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .padding(.vertical,12)
            }
        }
        
    }
}

struct ViewEntryDrops: View {
    let entry: Entry
    
    @AppStorage("expandDetails") var expandDetails: Bool = false
    @AppStorage("expandConditions") var expandConditions: Bool = false
    @AppStorage("expandSolunar") var expandSolunar: Bool = true
    @AppStorage("expandStatistics") var expandStatistics: Bool = false
    
    var body: some View {
        Group{
            Divider().padding(.top,12)
            ViewEntryDrop(symbol: "matter.logo", title: "Catch details",isExpanded: $expandDetails) {
                ViewCatchDetails(entry: entry)
            }
            ViewEntryDrop(symbol: "cloud", title: "Conditions",isExpanded: $expandConditions) {
                ViewEntry_Weather(entryWeather: entry.weather)
            }
            
            ViewEntryDrop(symbol: "sun.horizon.fill", title: "Sulunar",isExpanded: $expandSolunar) {
                ViewEntry_Solunar(entry: entry)
            }
            
            ViewEntryDrop(symbol: "externaldrive", title: "Statistics",isExpanded: $expandStatistics) {
                ViewEntry_Metada(entry: entry)
            }
            ViewEntry_WeatherAttribution()
        }
        .animation(.default, value: expandDetails)
        .animation(.default, value: expandConditions)
        .animation(.default, value: expandSolunar)
        .animation(.default, value: expandStatistics)
    }
}

struct ViewEntryDrop<Content:View>:View {
    
    let symbol: String
    let title: String
    @Binding var isExpanded: Bool
    let content: () -> Content
    
    var body: some View {
        VStack {
            Button {
                AppHaptics.light()
                isExpanded.toggle()
            } label: {
                HStack{
                    Image(systemName: symbol)
                        .font(.subheadline)
                        .frame(width: 24,alignment: .center)
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.half)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .foregroundStyle(AppColor.primary)
                .padding(.vertical,12)
                .background(AppColor.tone)
            }
            if isExpanded {
                content()
                    .transition(.blurReplace)
                    .padding(.top,4)
                    .padding(.bottom,12)
                
            }
            Divider()
        }
    }
}
struct ViewEntryLine<Content:View>:View {
    let symbol: String
    let title: String
    
    let content: () -> Content
    
    var body: some View {
        HStack{
            if !symbol.isEmpty {
                Image(systemName: symbol)
                    .foregroundStyle(AppColor.half)
                    .font(.callout2)
                    .frame(width: 18,alignment: .center)
            }
            Text(title)
                .foregroundStyle(AppColor.primary)
                .font(.callout)
            Spacer()
            content()
                .foregroundStyle(AppColor.half)
                .font(.callout)
        }
    }
}


//Drops Content
struct ViewCatchDetails: View {
    
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
               Text("Casting method")
                Spacer()
                Text("Shore")
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Catch depth")
                Spacer()
                Text("14m")
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Bottom type")
                Spacer()
                Text("Hard, Sand")
                    .foregroundStyle(AppColor.half)
            }
        }
        .font(.callout)
        
    }
}
struct ViewEntry_WaterDetails: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
               Text("Temperature")
                Spacer()
                Text("14C")
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Visiblity")
                Spacer()
                Text("14m")
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Tide state")
                Spacer()
                Text("Rising")
                    .foregroundStyle(AppColor.half)
            }
        }
        .font(.callout)
    }
}
struct ViewEntry_Metada: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
               Text("Location")
                Spacer()
                Text("15.2344, 58.2344")
                    .textSelection(.enabled)
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Time of log")
                Spacer()
                Text("2025, July 15 at 14:14")
                    .foregroundStyle(AppColor.half)
            }
            HStack{
               Text("Tide state")
                Spacer()
                Text("Rising")
                    .foregroundStyle(AppColor.half)
            }
        }
        .font(.callout)
    }
}
struct ViewEntry_Weather: View {
    let entryWeather: EntryWeather?
    var body: some View {
        if let weather = entryWeather {
            VStack(spacing:16){
                

                
                HStack{
                    Image(systemName: "thermometer.medium")
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    Text("Temperature")
                    Spacer()
                    Text("24C")
                        .foregroundStyle(AppColor.half)
                }
                
                
                HStack{
                    Image(systemName: "humidity.fill")
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    Text("Humidity")
                    Spacer()
                    Text("\(Int(weather.humidity))%")
                        .foregroundStyle(AppColor.half)
                }
                
                HStack{
                    Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    Text("Pressure")
                    Spacer()
                    
                    Image(systemName: weather.pressureTrend.symbolName)
                        .foregroundStyle(AppColor.half)
                        .font(.caption)
                    Text("\(Int(weather.pressure))hpa")
                        .foregroundStyle(AppColor.half)
                        
                }
                
                HStack{
                    Image(systemName: weather.condition_symbol)
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    Text("Condition")
                    Spacer()
                    Text(weather.condition)
                        .foregroundStyle(AppColor.half)
                }
                
                HStack{
                    Image(systemName: "wind")
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    Text("Winds")
                    Spacer()
                    Text("\(Int(weather.wind_speed))kmh, with \(Int(weather.wind_gusts))kmh gusts. ")
                        .foregroundStyle(AppColor.half)
                }
                
            }
            .font(.callout)
        } else {
            Text("Error no weather")
        }
    }
}

struct ViewEntry_Solunar: View {
    let entry: Entry
    var body: some View {
        ViewEntryLine(symbol: entry.weather?.moon.symbolName ?? "moon.stars.fill", title: "Moon Phase") {
                Text(entry.weather?.moon.label ?? "asd")
        }
        
        ViewEntryLine(symbol: "deskclock.fill", title: "Time of catch") {
            Text(DateFormatter.dateTime(entry.timestamp))
        }
        ViewEntryLine(symbol: "sunrise.fill", title: "Sunrise") {
            Text(DateFormatter.dateTime(entry.weather?.sunrise ?? Date()))
        }
        ViewEntryLine(symbol: "sunset.fill", title: "Sunset") {
            Text(DateFormatter.dateTime(entry.weather?.sunset ?? Date()))
        }
        
    }
}



//End Drops Content



//MARK: - OTHER STUFF

struct ViewEntry_WeatherAttribution: View {
    
    private let imageHeight: CGFloat = 12
    
    var body: some View {
        HStack(alignment: .firstTextBaseline){
            Image("weather_attribution")
                .resizable()
                .scaledToFit()
                .frame(height: imageHeight)
            Text("Legal")
                .foregroundStyle(AppColor.half)
                .underline()
                .font(.caption2)
        }
        .padding(.vertical)
    }
}

//Helpers or idk
extension DateFormatter {
    static let dayAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd - HH:mm")
        return formatter
    }()
    
    static func dateTime(_ date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

//Map stuff, move later
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


//MARK: - PREVIEW

#if DEBUG

private struct ViewEntry_Preview: View {
    
    @Environment(\.modelContext) var context
    @Query var allEntries: [Entry]
    
    var body: some View {
        ViewEntry(entry: allEntries[3])
    }
}

#endif

#Preview {
    ViewEntry_Preview()
        .modelContainer(for: [Entry.self,Species.self,Bait.self])
}
