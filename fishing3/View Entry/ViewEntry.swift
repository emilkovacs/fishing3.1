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


//Apple Maps and Weather acknowledgement need to be fixed.

// Implement the photo overlay part, decide on design, options as now:
/// --> Overlay which opens to a photo viewer, like in the old add catch.
/// Overlay which expands and replaces the map.

///`Finish this fucking part before starting an another.`

/// Controls Back, Edit
/// Map or Photos?
/// Title
/// Details


struct ViewEntry: View {
    
    let entry: Entry
    
    @AppStorage("catchDetails") var catchDetails: Bool = true
    
    var body: some View {
        ZStack{
            ScrollView{
                ViewEntryMap(lat: entry.latitude, lon: entry.longitude)
                
                VStack(alignment: .leading){
                    ViewEntryHeader(entry: entry)
                    ViewEntryDrops(entry: entry)
                }
                .padding()
                .background(AppColor.tone)
                .padding(.top,-64)
                
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
    
    private let mapHeight: CGFloat = 480
    
    init(lat: Double, lon: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let delta = 0.012
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
                            Text("adfgf")
                        }
                    }
                    .grayscale(1.0)
                    .frame(height: mapHeight * 1.5)
                    
                    MapColorCorrections(isSatelite: isSatelite)
                    MapColorFade()
                    
                }
                .frame(height: mapHeight + clampedY)
                .offset(y: -clampedY)
            }
            
            MapColorFade()
                .padding(.bottom,64-8)
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
                Image(systemName: "calendar")
                    .font(.caption)
                Text(DateFormatter.dayAndTime.string(from: entry.timestamp))
                    .font(.callout)
            }
            .padding(.bottom,6)
            .foregroundStyle(AppColor.half)
            
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
            
            Divider().padding(.vertical,12)
            
        }
        
    }
}
struct ViewEntryDrops: View {
    let entry: Entry
    var body: some View {
        ViewEntryDrop(symbol: "matter.logo", title: "Catch details") {
            ViewCatchDetails(entry: entry)
        }
        ViewEntryDrop(symbol: "humidity.fill", title: "Water details") {
            ViewEntry_WaterDetails(entry: entry)
        }
        ViewEntryDrop(symbol: "cloud", title: "Weather details") {
            ViewEntry_Weather(entryWeather: entry.weather)
        }
        ViewEntryDrop(symbol: "cloud", title: "Metada") {
            ViewEntry_Metada(entry: entry)
        }
    }
}


struct ViewEntryDrop<Content:View>:View {
    
    let symbol: String
    let title: String
    let content: () -> Content
    
    @State private var isExpanded: Bool = false
    @Namespace var ns
    
    var body: some View {
        VStack {
            
            
            HStack{
                Image(systemName: symbol)
                    .font(.subheadline)
                    .frame(width: 24,alignment: .center)
                Text(title)
                    .matchedGeometryEffect(id: "title", in: ns,properties: .position)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.half)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            
            
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                content()
                    .transition(.blurReplace)
                    .padding(.vertical,10)
                
            }
            
            Divider().padding(.vertical,12)
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
//End Drops Content


struct EntryDetailRow:View {
    
    var body: some View {
        HStack{
            
        }
    }
}



//Helpers or idk
extension DateFormatter {
    static let dayAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMd - HH:mm")
        return formatter
    }()
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
                .fill(AppColor.dark.opacity(isSatelite ? 0.2 : 0.55))
                .blendMode(.overlay)
                .allowsHitTesting(false)
        }
    }
}

#if DEBUG

private struct ViewEntry_Preview: View {
    
    @Environment(\.modelContext) var context
    @Query var allEntries: [Entry]
    
    var body: some View {
        ViewEntry(entry: allEntries[9])
    }
}

#endif

#Preview {
    ViewEntry_Preview()
        .modelContainer(for: [Entry.self,Species.self,Bait.self])
}
