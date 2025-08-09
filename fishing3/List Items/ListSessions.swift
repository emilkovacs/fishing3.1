//
//  ListSessions.swift
//  fishing3
//
//  Created by Emil Kovács on 5. 8. 2025..
//

import SwiftUI
import SwiftData

@Observable
class ListSessionsViewModel {
    let context: ModelContext
    
    var loadedSessions: [Session] = []
    private let fetchLimit: Int = 100
    private var fetchOffset: Int = 0
    private var isLoading: Bool = false
    
    var descriptor: FetchDescriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.timestamp,order: .reverse)])
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchSessions(){
        
        guard !isLoading else {return}
        isLoading = true
        descriptor.fetchLimit = fetchLimit
        descriptor.fetchOffset = fetchOffset
        descriptor.propertiesToFetch = [\.id,\.timestamp,\.speciesNames]
        
        Task{
            let newSessions = try? context.fetch(descriptor)
            if let newSessions {
                loadedSessions += newSessions
                fetchOffset += newSessions.count
            } else {
                #if DEBUG
                print("Failed to fetch")
                #endif
            }
            isLoading = false
        }
    }
    
}

struct ListSessions: View {
    
    /// Progressively fetches Sessions with only metada, not the whole entries.
    @Environment(\.dismiss) var dismiss
    @Bindable var vm: ListSessionsViewModel
    
    init(context: ModelContext) {
        self.vm = ListSessionsViewModel(context: context)
    }
    
    var body: some View {
        ZStack{
            List{
                ListTopSpacer()
                Text("All catches")
                    .font(.title)
                    .fontWeight(.medium)
                    .modifier(ListModifier())
                    .padding(.bottom)
                
                ForEach(vm.loadedSessions){ session in
                    SessionRow(session: session)
                }
                
                Spacer().onAppear{vm.fetchSessions()}.modifier(ListModifier())
            }
            .listStyle(.plain)
            
            .onAppear {vm.fetchSessions()}
            
            //Top Control Area
            ListTopBlocker()
            HStack{
                CircleButton("chevron.left") {
                    dismiss()
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top,AppSafeArea.edges.top)
            .frame(maxHeight: .infinity,alignment:.top)
            
        }
        .cornerRadius(30)
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        
        
        
    }
}

struct SessionRow: View {
    @Environment(\.modelContext) var context
    let session: Session
    @Namespace var namespace
    
    @State private var bool: Bool = false
    var body: some View {
        Button {
                bool.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack{
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.timestamp.formatted(date: .abbreviated, time: .omitted))
                            .font(.callout2)
                            .foregroundStyle(AppColor.half)
                            .matchedTransitionSource(id: session.id.uuidString, in: namespace)

                        Text(session.speciesSummary)
                            .font(.callout)
                            
                    }
                    Spacer()
                    //Counter
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.half.opacity(0.2))
                        .frame(width: 42,height: 42)
                        .overlay(alignment: .center) {
                            Text("\(session.speciesNames.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    
                }
                .padding(.vertical)
                Divider()
            }
        }
        .modifier(ListModifier())
        .navigationDestination(isPresented: $bool) {
            SessionView(session: session, ns: namespace, context: context)
                .navigationTransition(.zoom(sourceID: session.id.uuidString, in: namespace))
                .navigationBarBackButtonHidden()
        }
        
       
        
        
    }
}

//MARK: OTHER SHIT



struct EntryRowNow: View {
    
    @Bindable var entry: Entry
    @State private var bool: Bool = false
    @Namespace var ns
    var body: some View {
        Button {
            bool.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack{
                    VStack(alignment: .leading, spacing: 0) {
                        Text("14:56")
                            .font(.callout2)
                            .foregroundStyle(AppColor.half)
                        Text("\(entry.species?.name ?? "Err"), \(entry.bait?.name ?? "")")
                            .lineLimit(1)
                            .padding(.vertical,6)
                        Text("20kg, 16cm, from Shore")
                            .font(.callout2)
                            .foregroundStyle(AppColor.half)
                    }
                    .padding(.vertical)
                    Spacer()
                    //Image later
                }
                Divider()
            }
            
        }
        .modifier(ListModifier())
        .navigationDestination(isPresented: $bool) {
            ViewEntry(entry: entry) {
                bool.toggle()
            }
            .navigationTransition(.zoom(sourceID: "src", in: ns))
            .navigationBarBackButtonHidden()
        }

    }
}


#if DEBUG

struct ListSessions_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    var body: some View {
        ZStack{
            NavigationStack{
                ListSessions(context: context)
            }
            .background(Color.red)
        }
        .background(Color.red)
    }
}

#Preview {
        ListSessions_PreviewWrapper()
            .superContainer()
}


#endif
