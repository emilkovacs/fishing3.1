//
//  EditEntry.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

//Creates or edits an entry.

@Observable
class EditEntryViewModel {
    
    var context: ModelContext
    var entry: Entry
    var new: Bool
    var backAction: () -> Void
    
    var weather: EntryWeather?
    var locationCoordinate: CLLocation?
    
    //View controls
    var showListSpecies: Bool = false
    var showListBaits: Bool = false
    var showMoreDetails: Bool = false
    var showWeatherDetails: Bool = false
    var showPhotoManager: Bool = false
    var viewTitle: String
    
    
    //Alert controls
    var alertDisplay: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    func showAlert(_ title: String, _ message: String){
        alertTitle = title
        alertMessage = message
        alertDisplay = true
    }
    
    
    //Photo variables
    var pickedPhotos: [PhotosPickerItem] = []
    var photos: [UIImage] = []
    var maxPhotos: Int = 5
    var photosRemaining: Int { maxPhotos - photos.count }
    var photosEnabled: Bool {
        photos.count < maxPhotos + 1
    }
    
    init(context: ModelContext,entry: Entry, new: Bool, weather: EntryWeather? = nil, location: CLLocation, backAction: @escaping () -> Void) {
        self.context = context
        self.entry = entry
        self.new = new
        self.weather = weather
        self.locationCoordinate = location
        self.backAction = backAction
        self.viewTitle = new ? "Add Catch" : "Edit Catch"
    }
    
    func getWeather(){
        Task{
            if let loc = locationCoordinate {
                let currentWeather = try await WeatherManager.shared.getWeather(location: loc)
                    weather = currentWeather
            } else {
                weather = nil
            }
        }
    }
    
    //View functions
    
    func showDetails(){
        withAnimation { showMoreDetails.toggle() }
    }
    
    func showSpecies(){
        withAnimation { showListSpecies = true }
    }
    func hideSpecies(){
        withAnimation { showListSpecies = false }
    }
    func showBaits(){
        withAnimation { showListBaits = true }
    }
    func hideBaits(){
        withAnimation { showListBaits = false }
    }
    
    //Context functions
    func saveContext(){
        
        //Check for if species is set
        guard entry.species != nil else {
            showAlert("Set Species", "To saveContext the catch set the species.")
            return
        }
        
        //check for it it's new
        if new {
            //generate new uuid to be sure
            entry.id = UUID()
            //insert to context
            context.insert(entry)
        }
    
        do {
            try context.save()
        } catch {
            showAlert("Failed to Save", "Failed to save catch.")
            return
        }
    
        backAction()
        
    }    
    func backContext(){
        context.rollback()
        backAction()
    }
    
    
    
}

struct EditEntry: View {
    @Environment(\.modelContext) var context
    @Bindable var vm: EditEntryViewModel
    
    init(context: ModelContext, location: CLLocation, entry: Entry, newEntry: Bool, backAction: @escaping () -> Void ) {
        self.vm = EditEntryViewModel(context: context,entry: entry, new: newEntry,location: location, backAction: backAction)
    }
    
    var body: some View {
        ZStack{
            //Content
            ScrollView{
                if vm.locationCoordinate != nil {
                    EditEntryMap(
                        vm: vm,
                        initialLocation: CLLocationCoordinate2D(latitude: vm.locationCoordinate!.coordinate.latitude, longitude: vm.locationCoordinate!.coordinate.longitude))
                }
                
                EditEntryContent(vm: vm)
            }
            .scrollIndicators(.hidden)
            
            //Controls
            ListBottomBlocker().ignoresSafeArea(.all)
            EditEntry_BottomControls(vm: vm)
            EditEntry_TopControls()
            
            //Overlays
            if vm.showMoreDetails {
                EditEntryDetails(entry: vm.entry) {
                    withAnimation { vm.showMoreDetails.toggle() }
                }
                .transition(.blurReplace)
            }
            
            if vm.showPhotoManager {
                PhotoManager(photos: $vm.photos) {
                    vm.showPhotoManager.toggle()
                }
            }
             
            
            if vm.showWeatherDetails {
                EditEntryWeather(entryWeather: vm.entry.weather) {
                    vm.showWeatherDetails.toggle()
                }
                .transition(.blurReplace)
            }
            
            if vm.showListSpecies{
                ListSpecies(mode: .select, selectedSpecies: $vm.entry.species, context: context)
                    .transition(.blurReplace)
            }
            if vm.showListBaits{
                ListBaits(mode: .select, selectedBait: $vm.entry.bait, context: context)
                    .transition(.blurReplace)
            }
                
        }
        .alert(vm.alertTitle, isPresented: $vm.alertDisplay, actions: {}, message: {Text(vm.alertMessage)})
        .environment(vm)
        .background(AppColor.tone.ignoresSafeArea(.all))
        .ignoresSafeArea(.container)
    }
}

struct EditEntryContent: View {
    
    @Bindable var vm: EditEntryViewModel
    
    @State private var displayCatch: Bool = false
    @State private var displayWater: Bool = false
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 0) {
                //Main & Photoes.
                EditEntry_Header()
                EditMainDetails(vm: vm)
            }
        }
        .padding()
        .padding(.bottom,AppSafeArea.edges.bottom + AppSize.buttonSize)
        .background(EntryFadeBackground())
        .padding(.top,-102)
    }
}
struct EditEntry_Header: View {
    @Environment(EditEntryViewModel.self) var vm
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            Text(vm.viewTitle)
                .font(.title)
                .fontWeight(.medium)
                .padding(.top,16)
        }
        .overlay(alignment: .bottomTrailing) {
            PhotoManagerButtonEdit()
        }
        .padding(.bottom,32)
        
    }
}

struct PhotoManagerButtonEdit: View {
    @Environment(EditEntryViewModel.self) var vm
    var body: some View {
        if !vm.photos.isEmpty {
            if let photo = vm.photos.first {
                Button {
                    AppHaptics.light()
                    withAnimation {
                        vm.showPhotoManager.toggle()
                    }
                } label: {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 120)
                        .cornerRadius(10)
                        .overlay(alignment: .topTrailing) {
                            let count = vm.photos.count
                            if count > 1 {
                                Text("\(count)")
                                    .foregroundStyle(Color.white)
                            }
                        }
                }

            }
        }
    }
}


struct EditMainDetails: View {
    @Bindable var vm: EditEntryViewModel
    
    var speciesTitle: String {
        vm.entry.species == nil ? "Select Species" : vm.entry.species!.name
    }
    var baitTitle: String {
        vm.entry.bait == nil ? "Select Bait" : vm.entry.bait!.name
    }
    
    var body: some View {
        VStack{
            SelectorButton("Species", speciesTitle) {
                vm.showSpecies()
            }
            HStack(spacing: 12) {
                LargeDoubleInput(title: "Length", value: $vm.entry.length, unit: AppUnits.length)
                LargeDoubleInput(title: "Weight", value: $vm.entry.weight, unit: AppUnits.weight)
            }
            SelectorButton("Bait", baitTitle) {
                vm.showBaits()
            }
            LargeStringVerticalInput("Notes", "Your observations ...", $vm.entry.notes)
        }
    }
}



//MARK: - Main Components

struct EditEntry_TopControls: View {
    @Environment(EditEntryViewModel.self) var vm
    var body: some View {
        HStack{
            CircleButton("chevron.left") {
                vm.backContext()
            }
            if let weather = vm.entry.weather {
                CapsuleButton(weather.condition_symbol, "\(Int(weather.temp_current))\(AppUnits.temperature)") {
                    withAnimation {
                        vm.showWeatherDetails.toggle()
                    }
                }
            } else {
                CircleButton("thermometer.medium.slash") {
                    vm.showAlert("Weather is unavailable", "Failed to load weather for your location.")
                }
            }
            
            Spacer()
            
            
            TextButton("Save") {
                vm.saveContext()
            }
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
struct EditEntry_BottomControls: View {
    
    @Bindable var vm: EditEntryViewModel
    
    var body: some View {
        HStack{
            CircleButton("ellipsis") {
                vm.showDetails()
            }
            
            Spacer()
            
            
            if vm.photosEnabled {
                PhotosPicker(selection: $vm.pickedPhotos, maxSelectionCount: vm.photosRemaining, matching: .any(of: [.images,.not(.screenshots),.not(.panoramas)])) {
                    CircleLabel(symbol: "photo")
                }
                .buttonStyle(ActionButtonStyle({
                    AppHaptics.light()
                }))
                .onChange(of: vm.pickedPhotos) { _, _ in
                    Task { @MainActor in
                        for item in vm.pickedPhotos {
                            if let data = try? await item.loadTransferable(type: Data.self)
                                ,let uiImage = UIImage(data: data) {
                                vm.photos.append(uiImage)
                            } else {
                                print("fuck")
                            }
                        }
                        vm.pickedPhotos = []
                    }
                    print("\(vm.photos.count) remains\(vm.photosRemaining),\(vm.photosEnabled)")
                }
            } else {
                CircleButton("photo") {
                    vm.showAlert("Max 5 photos.", "To ensure performance max 5 photos.")
                }
            }
            

            
            CapsuleButton("camera.fill", "Camera") {}
            
        }
        .padding(.horizontal)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.all)
    }
}

struct MapLocationMark: View {
    var body: some View {
        Circle()
            .fill(AppColor.dark.opacity(0.3))
            .stroke(Color.white, lineWidth: 3)
            .frame(width: 20,height: 20)
    }
}


struct EditEntryMap: View {
    
    @Bindable var vm: EditEntryViewModel
    let initialLocation: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition
    @State private var cameraCenter: CLLocationCoordinate2D?
    //If default location then unlimited move, eg palic or apple park.
    //If NEW or Eidt then 5km adjustment radius
    
    //If map center is same as the initial location only one pin
    //If map center is not same location that fishing line view
    //While dragged need to dipslay a map center crosshair
    
    //DESIGN VARIABLES
    @State private var showCrosshair: Bool = false
    @Environment(\.colorScheme) var scheme
    @State private var isSatelite: Bool = false
    var mapStyle: MapStyle {
        isSatelite ? MapStyle.hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false) : MapStyle.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll, showsTraffic: false)
    }
    private let mapHeight: CGFloat = 420
    let strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        dash: [3, 6]
    )
    let gradient = Gradient(colors: [.red, .green, .blue])
    
    init(vm: EditEntryViewModel, initialLocation: CLLocationCoordinate2D) {
        self.vm = vm
        self.initialLocation = initialLocation
        self.cameraCenter = initialLocation
        self._cameraPosition = State(initialValue: MapCameraPosition.region(
            MKCoordinateRegion(center: initialLocation, span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001))
        ))
    }
    
    var body: some View {
        ZStack{
            GeometryReader{ geo in
                
                let clampedY = max(geo.frame(in: .global).minY, 0)
                
                ZStack(alignment: .center){
                    
                    Map(position: $cameraPosition){
                       
                        if vm.new {
                            Annotation("", coordinate: initialLocation) {
                                MapLocationMark()
                            }
                            
                            
                            if cameraCenter != nil {
                                if initialLocation != cameraCenter {
                                    
                                    
                                    let initialCL = CLLocation(latitude: initialLocation.latitude, longitude: initialLocation.longitude)
                                    let cameraCL = CLLocation(latitude: cameraCenter!.latitude, longitude: cameraCenter!.longitude)
                                    
                                    let distance = initialCL.distance(from: cameraCL)
                                    
                                    Marker("Catch \(Int(distance))m", coordinate: cameraCenter!)
                                        .tint(Color.white.opacity(0.65))
                                    
                                    let coordinates = [initialCL,cameraCL]
                                    MapPolyline(coordinates:[initialLocation,cameraCenter!])
                                        .stroke(gradient, style: strokeStyle)
                                }
                            }
                            
                        }

                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged({ drag in
                                showCrosshair  = true
                            })
                            .onEnded({ drag in
                                showCrosshair = false
                            })
                    )
                    .overlay(alignment: .center, content: {
                        if showCrosshair {
                            Image(systemName: "plus")
                        }
                    })

                    .onMapCameraChange(frequency: .onEnd) { context in
                        cameraCenter = context.region.center
                        
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

extension Double {
    func roundTo(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}


//MARK: - PREVIEW
#if DEBUG
struct EditEntry_PreviewWrapper: View {
    
    @Environment(\.modelContext) var context
    @Query var entries: [Entry]
    @State private var newEntry: Entry?
    @State private var location: CLLocation?
    
    var body: some View {
        ZStack{
            if newEntry != nil {
                if location != nil {
                    EditEntry(context: context, location: location!, entry: newEntry!, newEntry: true) {
                    }
                }
            }
        }
        .onAppear {
            LocationManager.shared.requestAuthorization()
            LocationManager.shared.getCurrentLocation { location in
                self.location = location
                newEntry = Entry(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                
                newEntry!.weather = DemoData.weathers.randomElement() as! EntryWeather
            }
            
            
        }
        
        
    }
}

#Preview {
    EditEntry_PreviewWrapper()
        .superContainer()
}
#endif

