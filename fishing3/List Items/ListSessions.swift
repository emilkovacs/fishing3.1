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
        print("Batch request")
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
    
    @Namespace var listNS
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
                        //SessionRowDesignA()
                    SessionRow(ns:listNS, session: session)
                }
                Spacer().onAppear {
                    vm.fetchSessions()
                }
                .modifier(ListModifier())
            }
            .listStyle(.plain)
            .onAppear {
                vm.fetchSessions()
            }
            
            //Top Control Area
            ListTopBlocker()
            HStack{
                CircleButton("chevron.left") {
                    
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
    let ns: Namespace.ID
    let session: Session
    
    @Namespace var rowNS
    @Namespace var textNS
    var body: some View {
        NavigationLink {
            if #available(iOS 18.0, *) {
                QuickListDemo(ns: rowNS, text: session.speciesSummary,id: session.id.uuidString)
                    
            } else {
                // Fallback on earlier versions
            }
        } label: {
            if #available(iOS 18.0, *) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack{
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.timestamp.formatted(date: .abbreviated, time: .omitted))
                                .font(.callout2)
                                .foregroundStyle(AppColor.half)

                                
                            Text(session.speciesSummary)
                                .font(.callout)
                                .matchedTransitionSource(id: session.id.uuidString, in: rowNS)
                                
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
                
            } else {
                // Fallback on earlier versions
            }
        }
        .modifier(ListModifier())
        

    }
}

struct QuickListDemo: View {
    let ns: Namespace.ID
    let text: String
    let id: String
    var body: some View {
        ZStack{
            ScrollView{
                ListTopSpacer()
                if #available(iOS 18.0, *) {
                    Text("Dec30 2025")
                        .navigationTransition(.zoom(sourceID: "date", in: ns))
                    Text(text)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .matchedGeometryEffect(id: id, in: ns)
                        .navigationTransition(.zoom(sourceID: id, in: ns))
                } else {
                    // Fallback on earlier versions
                }
                HStack{
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        .navigationBarBackButtonHidden()
    }
}

#if DEBUG

struct ListSessions_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    var body: some View {
        ListSessions(context: context)
    }
}

#Preview {
    NavigationStack{
        ListSessions_PreviewWrapper()
            .superContainer()
    }
    .background(AppColor.tone)
}


#endif
