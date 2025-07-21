//
//  EditEntry.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData
import MapKit


//Creates or edits an entry.

//Map
//Main
//Details
//Conditions
//Solunar

class EditEntryViewModel {
    
    var entry: Entry
    var new: Bool
    
    var weather: EntryWeather?
    var location: CLLocation?
    
    init(entry: Entry, new: Bool, weather: EntryWeather? = nil, location: CLLocation? = nil) {
        self.entry = entry
        self.new = new
        self.weather = weather
        self.location = location
    }
}

struct EditEntry: View {
    
    @Environment(\.modelContext) var context
    
    @Bindable var entry: Entry
    var newEntry: Bool
    var backAction: () -> Void
    
    var body: some View {
        ZStack{
            ScrollView{
                EditEntryMap(lat: entry.latitude, lon: entry.longitude)
                EditEntryContent(entry: entry)
                    .padding(.top,-84)
            }
            .scrollIndicators(.hidden)
            
            ListBottomBlocker()
                .ignoresSafeArea(.all)
            EditEntry_BottomControls()
            EditEntry_TopControls()
                
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
        
    }
}

//MARK: - Main Components

struct EditEntry_TopControls: View {
    var body: some View {
        HStack{
            CircleButton("chevron.left") {}
            Spacer()
            
            CapsuleButton("plus", "Save") {}
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct EditEntry_BottomControls: View {
    var body: some View {
        HStack{
            CircleButton("ellipsis") {}
            
            Spacer()
            CircleButton("photo") {}
            CapsuleButton("camera.fill", "Camera") {}
            
        }
        .padding(.horizontal)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.all)
    }
}



struct EditEntryMap: View {
    
    @State private var cameraPosition: MapCameraPosition
    let entryCoordinate: CLLocationCoordinate2D
    let entryRegion: MKCoordinateRegion
    
    @Environment(\.colorScheme) var scheme
    
    @State private var isSatelite: Bool = false
    var mapStyle: MapStyle {
        isSatelite ? MapStyle.hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false) : MapStyle.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll, showsTraffic: false)
    }
    
    @State private var otherCenter: CLLocationCoordinate2D?
    private let mapHeight: CGFloat = 420
    let strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        dash: [3, 6]
    )
        
    let gradient = Gradient(colors: [.red, .green, .blue])
    
    init(lat: Double, lon: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let delta = 0.006
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: delta, longitudeDelta: delta))
        self.entryCoordinate = coordinate
        self.entryRegion = region
        self._cameraPosition = State(initialValue: MapCameraPosition.region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            )
        ))
    }
    
    var body: some View {
        ZStack{
            GeometryReader{ geo in
                
                let clampedY = max(geo.frame(in: .global).minY, 0)
                
                ZStack(alignment: .center){
                    
                    
                    Map(position: $cameraPosition){
                    
                        Marker(coordinate: entryCoordinate) { Text("Catch")}
                        
                        if let coordinate = cameraPosition.camera?.centerCoordinate {
                            Marker(coordinate: coordinate) { Text("Center")}
                            let content = [coordinate,entryCoordinate]
                            MapPolyline(coordinates: content)
                            .stroke(gradient, style: strokeStyle)

                        }
                        
                        
                        if let asd = otherCenter{
                            
                            let a1 = CLLocation(latitude: asd.latitude, longitude: asd.longitude)
                            let a2 =  CLLocation(latitude: entryCoordinate.latitude, longitude: entryCoordinate.longitude)
                            
                            let dist = a1.distance(from: a2)
                            
                            
                            let content = [asd,entryCoordinate]
                            Marker(coordinate: asd) { Text("\(Int(dist))")}
                            
                            MapPolyline(coordinates:content)
                            .stroke(gradient, style: strokeStyle)

                        }
                        
                        
                        
                    }
                    .onMapCameraChange { context in
                        otherCenter = context.region.center
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
struct EditEntryContent: View {
    @Bindable var entry: Entry
    var body: some View {
        VStack{
            VStack(
                alignment: .leading, spacing: 0
            ) {
                HStack{
                    HStack{
                        Image(systemName: "calendar")
                        Text("June 26, 14:38")
                    }
                        .font(.caption)
                        .padding(.vertical,6)
                        .padding(.horizontal,12)
                        .background(AppColor.secondary)
                        .cornerRadius(30)
                        .padding(.leading,-6)
                    Spacer()
                }
                .padding(.bottom,18)
                
                
                Text("New Catch")
                    .font(.title)
                    .fontWeight(.medium)
                    .padding(.bottom,24)
                
                
                SelectorButton("Species", "Select Species") {}
                
                HStack{
                    LargeStringInput("Length", "0 cm", .constant(""))
                    LargeStringInput("Weight", "0 kg", .constant(""))
                }
                SelectorButton("Bait", "Select Bait") {
                    
                }
                LargeStringInput("Notes", "Observations and details", .constant(""))
                    .padding(.bottom,16)
                 
                
                Text("Catch details")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top,24)
                    .padding(.bottom,24)
                
                //Experimental
                LargeSelector("Casting method", $entry.castingMethod)
                
                HStack{
                    LargeStringInput("Catch depth", "0 cm", .constant(""))
                    LargeStringInput("Weight", "0 kg", .constant(""))
                }
                
                Text("Water details")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top,24)
                    .padding(.bottom,24)
                //Experimental
                LargeSelector("Tide state", $entry.tideState)
                HStack{
                    LargeStringInput("Water temp", "0 C", .constant(""))
                    LargeStringInput("Water visibility", "0 cm", .constant(""))
                }
                LargeSelector("Bottom type", $entry.bottomType)
                
                
                Text("Weather")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top,24)
                    .padding(.bottom,24)
                
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
                
                Text("Solunar")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top,24)
                    .padding(.bottom,24)
                
                /*
                ViewEntryDrop(symbol: "photo", title: "Photos", isExpanded: .constant(false)) {
                    EmptyView()
                }
                
                ViewEntryDrop(symbol: "matter.logo", title: "Details", isExpanded: .constant(false)) {
                    EmptyView()
                }
                ViewEntryDrop(symbol: "cloud", title: "Conditions", isExpanded: .constant(false)) {
                    EmptyView()
                }
                ViewEntryDrop(symbol: "moon.stars", title: "Solunar", isExpanded: .constant(false)) {
                    EmptyView()
                }
                 */
            }
            .padding(.bottom,AppSafeArea.edges.bottom + AppSize.buttonSize + 16)
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
        
    }
}


//MARK: - PREVIEW
#if DEBUG
struct EditEntry_PreviewWrapper: View {
    
    @Query var entries: [Entry]
    @State private var newEntry: Entry?
    
    var body: some View {
        ZStack{
            if newEntry != nil {
                EditEntry(entry: newEntry!, newEntry: true) {
                    print("back")
                }
            }
        }
        .onAppear {
            LocationManager.shared.requestAuthorization()
            LocationManager.shared.getCurrentLocation { location in
                newEntry = Entry(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            }
        }
        
        
    }
}

#Preview {
    EditEntry_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}
#endif


struct Mappp: View {
    let coordinates = [
        CLLocationCoordinate2D(latitude: 37.3347, longitude: -122.0089),
        CLLocationCoordinate2D(latitude: 37.3358, longitude: -122.0089),
        CLLocationCoordinate2D(latitude: 37.3359, longitude: -122.0089)
    ]

    let strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        dash: [5, 5]
    )
        
    let gradient = Gradient(colors: [.red, .green, .blue])
    
    var body: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.3353, longitude: -122.0089),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )) {
            MapPolyline(coordinates: coordinates)
                .stroke(gradient, style: strokeStyle)

            ForEach(coordinates, id: \.latitude) { coord in
                Marker("Point", coordinate: coord)
            }
        }
        .frame(height: 400)
    }
}

