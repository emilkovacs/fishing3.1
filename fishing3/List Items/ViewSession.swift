//
//  a.swift
//  fishing3
//
//  Created by Emil Kovács on 8. 8. 2025..
//

import SwiftUI
import SwiftData
import MapKit

@Observable
final class SessionViewModel {
    let context: ModelContext
    let partialSession: Session

    // Make this mutable & optional: it’s set after fetching.
    var fullSession: Session?

    // Keep descriptor around so you can reuse it.
    private var descriptor: FetchDescriptor<Session>

    init(context: ModelContext, partialSession: Session) {
        self.context = context
        self.partialSession = partialSession

        let targetID = partialSession.id  // capture a plain value
        self.descriptor = FetchDescriptor<Session>(
            predicate: #Predicate<Session> { $0.id == targetID } // compare to value, not a model
        )
        self.descriptor.fetchLimit = 1

        // Initial fetch of the "full" object
        do {
            let results = try context.fetch(descriptor)
            self.fullSession = results.first
        } catch {
            // handle/log as needed
            #if DEBUG
            print("Refetch failed:", error)
            #endif
        }
    }
}


struct SessionView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vm: SessionViewModel
    let ns: Namespace.ID
    
    
    init(session: Session, ns: Namespace.ID, context: ModelContext) {
        self.ns = ns
        self.vm = SessionViewModel(context: context, partialSession: session)
    }
    
    var body: some View {
        ZStack{
            List{
                SessionViewMap(entries: vm.fullSession?.entries ?? [])
                    .listRowSpacing(0)
                    .listRowBackground(AppColor.tone)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Text(vm.fullSession?.timestamp.formatted(date: .abbreviated, time: .omitted) ?? "")
                    .modifier(ListModifier())
                    .font(.title)
                    .fontWeight(.medium)
                    .matchedGeometryEffect(id: vm.fullSession!.id.uuidString, in: ns)
                   
                
                ForEach(vm.fullSession!.entries){ entry in
                    EntryRowNow(entry: entry)
                }
                
            }
            .listStyle(.plain)
            
            //TopControls
            ListTopBlocker()
            HStack{
                CircleButton("chevron.left") {
                    dismiss()
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top,AppSafeArea.edges.top)
            .frame(maxHeight: .infinity, alignment: .top)
            
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    }
}


struct SessionViewMap: View {
    
    let entries: [Entry]
    
    @State private var cameraPosition: MapCameraPosition
    @State private var isSatelite: Bool = false
    var mapStyle: MapStyle { isSatelite ? AppMap.hybridStyle : AppMap.standardStyle }
    
    var body: some View {
        GeometryReader{ geo in
            let geoSize = max(geo.frame(in: .global).minY, 0)
            ZStack{
                Map(position: $cameraPosition){
                    
                    ForEach(entries){ entry in
                        Marker(coordinate: CLLocationCoordinate2D(latitude: entry.latitude, longitude: entry.longitude)) {
                            Text(entry.species?.name ?? "")
                        }
                    }
                }
                .mapControlVisibility(.hidden)
                .grayscale(1.0)
                .mapStyle(mapStyle)
                .safeAreaPadding(.vertical,190)
                .safeAreaPadding(.horizontal,6)
                .frame(height: AppMap.mapHeight * 1.5)
                .onLongPressGesture { isSatelite.toggle() }
                
                MapColorCorrections(isSatelite: isSatelite)
                MapColorFade()
            }
            .frame(height: AppMap.mapHeight + geoSize).offset(y: -geoSize)
        }
        .frame(height: AppMap.mapHeight)
        .padding(.bottom,-54)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(colors: [AppColor.tone,AppColor.tone.opacity(0.65),Color.clear], startPoint: .bottom, endPoint: .top)
                )
                .frame(height: 32)
                .allowsHitTesting(false)
        }
    }
    
    init(entries: [Entry]) {
        self.entries = entries
        
        let averageLatitude = { let l = entries.compactMap { $0.latitude }; return l.reduce(0, +) / CGFloat(max(1, l.count)) }()
        let averageLongitude = { let l = entries.compactMap { $0.longitude }; return l.reduce(0, +) / CGFloat(max(1, l.count)) }()
        
        let coordinate = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        
        self._cameraPosition = State(initialValue: MapCameraPosition.region(MKCoordinateRegion(center: coordinate, span: AppMap.smallSpan))
        )
    }
}


#if DEBUG

struct SessionView_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    @Namespace var namespace
    
    @Query var allSessions: [Session]
    
    var body: some View {
        NavigationStack{
            SessionView(session: allSessions[18], ns: namespace, context: context)
        }
    }
}

#Preview {
    SessionView_PreviewWrapper()
        .superContainer()
}


#endif
