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
    private let fetchLimit: Int = 50
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
        descriptor.propertiesToFetch = [\.id,\.timestamp,\.entryCount]
        
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
    
    @Bindable var vm: ListSessionsViewModel
    
    init(context: ModelContext) {
        self.vm = ListSessionsViewModel(context: context)
    }
    
    var body: some View {
        ZStack{
            List{
                ListTopSpacer()
                
                ForEach(vm.loadedSessions){ session in
                        //SessionRowDesignA()
                    SessionRowDesignB()
                }
                Spacer().onAppear {
                    vm.fetchSessions()
                }
            }
            .listStyle(.plain)
            .onAppear {
                vm.fetchSessions()
            }
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
}

struct SessionRowDesignA: View {
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack{
                VStack(alignment:.leading, spacing: 6) {
                    Text("March 24, 2024")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    Text("1 species, 2 baits")
                        .font(.callout2)
                        .foregroundStyle(AppColor.half)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.half.opacity(0.2))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Text("6")
                            .font(.callout2)
                            .fontWeight(.medium)
                        
                    }
                
            }
            
            .padding(.vertical)
            Divider()
        }
        .modifier(ListModifier())
    }
}

struct SessionRowDesignB: View {
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            HStack{
                VStack(alignment:.leading, spacing: 8) {
                    HStack{
                        Text("March 24")
                            .font(.callout2)
                            .foregroundStyle(AppColor.half)
                       
                        
                        Spacer()
                        
                        HStack(spacing:4){
                            Image(systemName: "cloud")
                                .font(.caption2)
                            Text("Cloudy")
                        }
                        .font(.callout2)
                        .foregroundStyle(AppColor.half)
                        
                       
                    }
                    
                    HStack{
                        Text("4 catches")
                            .font(.callout)
                            .foregroundStyle(AppColor.primary)
                        
                        Spacer()

                        Text("Carp, Tuna +1")
                            .font(.callout2)
                            .foregroundStyle(AppColor.half)
                        
                    }
                }
                
            }
            .padding(.vertical)
            Divider()
        }
        .modifier(ListModifier())
    }
}

struct SessionRow: View {
    
    let session: Session
    
    var body: some View {
        VStack(spacing:0){
            HStack{
                Text("\(session.entries.count)")
                    .font(.callout)
                
                Spacer()
                
                Text("\(session.timestamp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.callout2)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColor.half)
                    .padding(.leading,8)
            }
            .padding(.vertical)
            Divider()
        }
        .modifier(ListModifier())
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
    ListSessions_PreviewWrapper()
        .superContainer()
}


#endif
