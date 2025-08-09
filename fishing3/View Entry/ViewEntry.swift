//
//  ViewEntry.swift
//  fishing3
//
//  Created by Emil Kovács on 15. 7. 2025..
//

import SwiftUI
import SwiftData
import MapKit


struct ViewEntry: View {
    
    ///External variables
    @Bindable var entry: Entry
    var backAction: () -> Void
    
    ///Internal variables
    @State private var showEditor: Bool = false
    
    var body: some View {
        ZStack{
            ScrollView{
                ViewEntryMap(entry: entry)
                ViewEntryContent()
            }
            .scrollIndicators(.hidden)
            ViewEntryControls(action: backAction, toggle: $showEditor)
            
            ListBottomBlocker()
            ViewEntryBottomControls()
            
            if showEditor{ Text("Editor") .transition(.blurReplace)}
        }
        .environment(entry)
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        
    }
    
}

struct ViewEntryContent: View {
    @Environment(Entry.self) var entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                ViewEntryHeader()
                    .padding(.horizontal)
            
                ViewEntryDrops()
        }
        .padding(.top,16)
        .background(EntryFadeBackground())
        .padding(.top,-96)
    }
    

    
}
struct ViewEntryHeader: View {
    @Environment(Entry.self) var entry
    
    var title: String {
        guard let speciesName = entry.species?.name,
              let baitName = entry.bait?.name else {
            return "Unknown Entry"
        }
        return "\(speciesName), \(baitName)"
    }
    var subtitle: String {
        let length = Int(entry.length ?? 0)
        let weight = Int(entry.weight ?? 0)
        return "\(length)\(AppUnits.length), \(weight)\(AppUnits.weight)"
    }
    var date: String { AppFormatter.dayAndTimeFormatter.string(from: entry.timestamp) }
    
    var body: some View {

        HStack{
            Text(title)
                .font(.title1)
                .fontWeight(.medium)
                .padding(.vertical,12)
            
            Spacer()
                
        }
        Text(subtitle)
            .font(.callout)
            .foregroundStyle(AppColor.half)
            .padding(.bottom,28)
        if !entry.notes.isEmpty {
            Text(entry.notes)
                .font(.body)
                .padding(.bottom,28)
        }
    }
}
struct ViewEntryDrops: View {
    
    @Environment(Entry.self) var entry
    
    @State private var expandCatch: Bool = false
    @State private var expandWater: Bool = false
    @State private var expandWeather: Bool = false
    @State private var expandSolunar: Bool = false
    @State private var expandMetada: Bool = false
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Divider()
            
            
            
            HeaderDrop("Catch", "figure.fishing", $expandCatch) {
                Text(entry.castingMethod.shortLabel)
            } content: {
                VStack(spacing: 12){
                    HeaderDropRow(title: "Casting method", symbol: "circle") {
                        Text(entry.castingMethod.label)
                    }
                    HeaderDropRow(title: "Catch depth", symbol: "circle") {
                        Text("\(Int(entry.catchDepth ?? 0)) \(AppUnits.length)")
                    }
                    .padding(.bottom,16)

                }
            }
            
            HeaderDrop("Water", "drop", $expandWater) {
                if entry.waterTemperature != nil {
                    Text("\(Int(entry.waterTemperature ?? 0)) \(AppUnits.temperature)")
                } else {
                    Text("")
                }
            } content: {
                VStack(spacing: 12){
                    HeaderDropRow(title: "Tide state", symbol: "circle") {
                        Text(entry.tideState.label)
                    }
                    HeaderDropRow(title: "Temperature", symbol: "circle") {
                        Text("\(Int(entry.waterTemperature ?? 0)) \(AppUnits.temperature)")
                    }
                    HeaderDropRow(title: "Visibility", symbol: "circle") {
                        Text("\(Int(entry.waterVisibility ?? 0)) \(AppUnits.length)")
                    }
                    .padding(.bottom,16)

                }
            }

            
            if let weather = entry.weather {
                HeaderDrop("Weather", "cloud.sun", $expandWeather) {
                    if entry.waterTemperature != nil {
                        Text("\(Int(entry.waterTemperature ?? 0)) \(AppUnits.temperature)")
                    } else {
                        Text("")
                    }
                } content: {
                    VStack(spacing: 12){
                        HeaderDropRow(title: "Temperature", symbol: "circle") {
                            Text("\(Int(weather.temp_current)) \(AppUnits.temperature)")
                        }
                        HeaderDropRow(title: "Temperature range", symbol: "circle") {
                            Text("\(Int(weather.temp_low)) - \(Int(weather.temp_high)) \(AppUnits.temperature)")
                        }
                        HeaderDropRow(title: "Pressure", symbol: "circle") {
                            HStack{
                                Image(systemName: weather.pressureTrend.symbolName)
                                    .font(.caption)
                                Text("\(Int(weather.pressure)) \(AppUnits.pressure)")
                            }
                        }
                        HeaderDropRow(title: "Humidity", symbol: "circle") {
                            Text("\(Int(weather.humidity)) \(AppUnits.humidity)")
                        }
                        .padding(.bottom,16)
                        
                        HeaderDropRow(title: "Condition", symbol: "circle") {
                            HStack{
                                Image(systemName: weather.condition_symbol)
                                    .font(.caption)
                                Text(weather.condition)
                            }
                        }
                        HeaderDropRow(title: "Cloud Cover", symbol: "circle") {
                            Text("\(Int(weather.cloudCover)) \(AppUnits.humidity)")
                        }
                        
                        HeaderDropRow(title: "Rain amount", symbol: "circle") {
                            Text("\(Int(weather.precipitation_amount)) \(AppUnits.rain)")
                        }
                        HeaderDropRow(title: "Rain chance", symbol: "circle") {
                            Text("\(Int(weather.precipitation_chance)) \(AppUnits.humidity)")
                        }
                        .padding(.bottom,16)
                        
                        HeaderDropRow(title: "Wind speed", symbol: "circle") {
                            Text("\(Int(weather.wind_speed)) \(AppUnits.windspeed)")
                        }
                        HeaderDropRow(title: "Wind gusts", symbol: "circle") {
                            Text("\(Int(weather.wind_gusts)) \(AppUnits.windspeed)")
                        }
                        
                        Spacer()
                            .padding(.bottom,16)

                    }
                }
                
                HeaderDrop("Solunar", "moon.stars", $expandSolunar) {
                    Text("A")
                } content: {
                    VStack(spacing: 12) {
                        
                        
                        
                        HeaderDropRow(title: "Moon", symbol: "moon") {
                            HStack{
                                Image(systemName: weather.moon.symbolName)
                                Text(weather.moon.label)
                            }
                        }
                        
                        HeaderDropRow(title: "Sunrise & Sunset", symbol: "circle") {
                            HStack{
                                Image(systemName: "sunrise")
                                    .font(.caption)
                                Text("\(AppFormatter.time(weather.sunrise))")
                                Image(systemName: "sunset")
                                    .font(.caption)
                                Text("\(AppFormatter.time(weather.sunset))")
                            }
                        }
                        HeaderDropRow(title: "Moonrise & Moonset", symbol: "circle") {
                            HStack{
                                Image(systemName: "moonrise")
                                    .font(.caption)
                                Text("\(AppFormatter.time(weather.moonrise))")
                                Image(systemName: "moonset")
                                    .font(.caption)
                                Text("\(AppFormatter.time(weather.moonset))")
                            }
                        }

                        
                        Spacer().padding(.bottom,16)
                    }
                }
            }
            
            HeaderDrop("Metada", "info.circle.text.page", $expandMetada) {
                Text("A")
            } content: {
                VStack(spacing: 12) {
                    
                    HeaderDropRow(title: entry.species!.name, symbol: "circle") {
                        HStack{
                            Text("\(entry.species!.water.label), \(entry.species!.behaviour.shortLabel)")
                        }
                    }
                    HeaderDropRow(title: entry.bait!.name, symbol: "circle") {
                        HStack{
                            Text("\(entry.bait!.type.shortLabel), \(entry.bait!.position.label)")
                        }
                    }
                    .padding(.bottom,12)
                    
                    HeaderDropRow(title: "Date & Time", symbol: "circle") {
                        Text(AppFormatter.dayAndTime(entry.timestamp))
                    }
                    HeaderDropRow(title: "Coordinates", symbol: "circle") {
                        Text(" \(entry.latitude,format: .number.precision(.fractionLength(4))) - \(entry.longitude,format: .number.precision(.fractionLength(4)))")
                    }
                    
                    Spacer().padding(.bottom,12)
                }

                //Date and time, location coordinates,
                //Species data,
                //Bait data,
            }
        }
        .padding(.horizontal)
        .padding(.bottom, AppSafeArea.edges.bottom + 16)
    }
}

struct ViewEntryMap: View {
    
    /// Shows catch location, for entry's location, Satelite/Standard mode support, Snaps nicely with content.
    
    @State private var cameraPosition: MapCameraPosition
    @State private var isSatelite: Bool = false
    let location: CLLocationCoordinate2D
    let mapHeight: CGFloat = 480
    var mapStyle: MapStyle { isSatelite ? AppMap.hybridStyle : AppMap.standardStyle }

    var body: some View {
            GeometryReader{ geo in
                let geoSize = max(geo.frame(in: .global).minY, 0)
                ZStack{
                    Map(position: $cameraPosition){
                        Marker("Catch", coordinate: location)
                            .tint(Color.white.opacity(0.65))
                    }
                    .mapControlVisibility(.hidden)
                    .grayscale(1.0)
                    .mapStyle(mapStyle)
                    .safeAreaPadding(.vertical,190)
                    .safeAreaPadding(.horizontal,6)
                    .frame(height: mapHeight * 1.5)
                    .onLongPressGesture { isSatelite.toggle() }
                    
                    MapColorCorrections(isSatelite: isSatelite)
                    MapColorFade()
                }
                .frame(height: mapHeight + geoSize).offset(y: -geoSize)
            }
            .frame(height: mapHeight)
       
    }
    
    init(entry: Entry) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: entry.latitude, longitude: entry.longitude)
        self.location = coordinate
        self._cameraPosition = State(initialValue: MapCameraPosition.region(MKCoordinateRegion(center: coordinate, span: AppMap.mediumSpan))
        )
    }
}

struct ViewEntryControls: View {
    
    var action: () -> Void
    @Binding var toggle: Bool
    
    var body: some View {
        HStack{
            CircleButton("chevron.left") { action() }
            Spacer()
            CapsuleButton("pencil", "Edit") {
                withAnimation {
                    toggle = true
                }
            }
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
struct ViewEntryBottomControls: View {
    

    var body: some View {
        HStack{
            CircleButton("ellipsis") {  }
            Spacer()
            CircleButton("square.and.arrow.up") {  }

        }
        .padding(.horizontal)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}


//MARK: - SHARED

struct HeaderDropRow<Values:View>: View {
    
    let title: String
    let symbol: String
    let values: () -> Values
    
    var body: some View {
        HStack{
            Image(systemName: symbol)
                .foregroundStyle(AppColor.primary)
                .frame(width: 22, alignment: .center)
                .font(.caption)
            Text(title)
                .foregroundStyle(AppColor.primary)
                .font(.callout)
            Spacer()
            values()
                .foregroundStyle(AppColor.half)
                .font(.callout)
        }
    }
}
struct HeaderDrop<TrailingContenet: View, Content: View>: View {
    
    let title: String
    let symbol: String?
    @Binding var expanded: Bool
    var trailingContent: () -> TrailingContenet
    var content: () -> Content
    
    @State private var opacity: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            //Title area
            Button {
                AppHaptics.light()
                withAnimation { expanded.toggle() }
                animatePress(scale: $opacity)
            } label: {
                HStack{
                    if let icon = symbol {
                        Image(systemName: icon)
                            .frame(width: 24, alignment: .center)
                            .font(.callout2)
                            .foregroundStyle(AppColor.primary)
                            .fontWeight(.medium)
                    }
                    Text(title)
                        .font(.callout)
                        .foregroundStyle(AppColor.primary)
                        .fontWeight(.medium)
                        .font(.body)
                    Spacer()
                    
                    trailingContent()
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.half)
                        .fontWeight(.medium)
                        .font(.caption2)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                    
                }
                .opacity(opacity)
            }
            .padding(.vertical,20)
            
            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                        .transition(.blurReplace)
                }
            }
            Divider()
        }
        .clipped()
    }
    
    init(_ title: String, _ symbol: String?, _ expanded: Binding<Bool>, trailingContent: @escaping () -> TrailingContenet,  content: @escaping () -> Content) {
        self.title = title
        self.symbol = symbol
        self._expanded = expanded
        self.trailingContent = trailingContent
        self.content = content
    }
}


struct AppMap {
    
    static let mapHeight: CGFloat = 480
    
    static let mediumSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    static let smallSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    static let hybridStyle: MapStyle = MapStyle.hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false)
    static let standardStyle: MapStyle = MapStyle.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll, showsTraffic: false)
}
//Shared move later
struct EntryFadeBackground: View {
    var body: some View {
        VStack(spacing: 0, content: {
            LinearGradient(
                colors: [
                    AppColor.tone,
                    AppColor.tone.opacity(0.75),
                    AppColor.tone.opacity(0.0)
                ],
                startPoint: .bottom, endPoint: .top)
            .frame(height: 50)
            .allowsHitTesting(false)
            
            AppColor.tone
        })
    }
}





//MARK: - PREVIEW

#if DEBUG

private struct ViewEntry_Preview: View {
    
    @Environment(\.modelContext) var context
    @Query var allEntries: [Entry]
    
    var body: some View {
        NavigationStack{
            ViewEntry(entry: allEntries[3]) {
                
            }
            .onAppear{
                allEntries[3].notes = "Catch around midwater strong currents above the shore, nice corn trick."
            }
        }
    }
}

#endif

#Preview {
    ViewEntry_Preview()
        .superContainer()
}
