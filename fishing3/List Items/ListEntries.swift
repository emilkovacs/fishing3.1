//
//  ListEntries.swift
//  fishing3
//
//  Created by Emil Kovács on 5. 8. 2025..
//

import SwiftUI
import SwiftData

//Resolution /Years //Months //Etc
//View/Edit overlay. :))

@Observable
class ListEntriesViewModel {
    var context: ModelContext
    
    var allEntries: [Entry] = []
    var dayEntries: [Date: [Entry]] = [:]
    
    private var batchSize: Int = 20
    private var currentOffset: Int = 0
    private var isLoading: Bool = false
    
    var descriptor = FetchDescriptor<Entry>(
        sortBy: [SortDescriptor(\.timestamp,order: .forward)]
    )
    
    func loadBatch(){
        
        guard !isLoading else {return}
        print("Batch request")
        isLoading = true
        
        descriptor.fetchLimit = batchSize
        descriptor.fetchOffset = currentOffset
        descriptor.propertiesToFetch = [\.id,\.timestamp,\.species,\.bait]
        
        Task{
            let newEntries = try? context.fetch(descriptor)
            if let newEntries {
                allEntries += newEntries
                currentOffset += newEntries.count
                
                for entry in newEntries {
                    let date = Calendar.current.startOfDay(for: entry.timestamp)
                    dayEntries[date, default: []].append(entry)
                }
                
            } else {
                print("no new entries")
            }
            isLoading = false
        }
    }
    
    init(context: ModelContext) {
        self.context = context
    }
}

struct ListEntries: View {
    
    @Bindable var vm: ListEntriesViewModel
    @State private var openedSection: [Date: Bool] = [:]
    
    init(context: ModelContext) {
        self.vm = ListEntriesViewModel(context: context)
    }
    
    var body: some View {
        List{
            
            DemoSec(date: Date())
            
            ForEach(vm.dayEntries.keys.sorted(by: >),id: \.self){ date in
                DemoSec(date: date)
            }
        }
        
        .onAppear {
            vm.loadBatch()
        }
    }
}

struct DemoSec: View {
    var date: Date
    @State private var isExpanded: Bool = true
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text("E")
            Text("E")
            Text("E")
        } label: {
            Text("\(date)")
        }
    }
}


#if DEBUG
struct ListEntries_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    var body: some View {
        ListEntries(context: context)
    }
}
#Preview {
    ListEntries_PreviewWrapper()
        .superContainer()
}


#endif
