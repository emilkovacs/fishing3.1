//
//  EditSpecies.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData


struct EditSpecies: View {
    
    @Environment(\.modelContext) var context
    
    @Bindable var species: Species
    var new: Bool
    var backAction: () -> Void
    
    var title: String {
        new ? "New Species" : "Edit Species"
    }
    
    @State private var alertDisplay: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(title)
                        .font(.title)
                        .fontWeight(.medium)
                        .padding(.bottom,32)
                    
                    LargeStringInput("Name", "Unique Name", $species.name)
                    LargeSelector("Water", $species.water)
                    LargeSelector("Behaviour", $species.behaviour)
                    bottomControls
                }
                .padding(.horizontal)
                .padding(.top,64+16)
                .padding(.top,AppSafeArea.edges.top)
            }
            
            topControls
            
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
        .alert(alertTitle, isPresented: $alertDisplay) {} message: {Text(alertMessage)}
    }
    
    var topControls: some View {
        HStack{
            CircleButton("chevron.left") { back() }
            Spacer()
            CircleButton(species.star ? "star.fill" : "star") { species.star.toggle() }
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    var bottomControls: some View {
        HStack{
            CircleButton("trash") {
                delete()
            }
            Spacer()
            CapsuleButton("plus", new ? "Add" : "Save") {
                saveOrCreate()
            }
        }
        .padding(.top,32)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    
    func alertUser(_ title: String, _ message: String){
        alertTitle = title
        alertMessage = message
        alertDisplay = true
    }
    

    
    func delete(){
        withAnimation {
            context.delete(species)
        }
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to delete or save species.")
        }
        
        backAction()
    }
    func back(){
        context.rollback()
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to save species.")
        }
        
        backAction()
    }
    func saveOrCreate(){
        //Normalize name
        species.name = species.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Empty name check
        guard !species.name.isEmpty else {
            alertUser("Empty Name", "Give your species a name.")
            return
        }
        
        let nameToCheck = species.name

        let descriptor = FetchDescriptor<Species>(
            predicate: #Predicate { $0.name == nameToCheck }
        )

        do {
            let matchingSpecies = try context.fetch(descriptor)

            let isDuplicate = matchingSpecies.contains { $0.id != species.id }

            if isDuplicate {
                alertUser("Duplicate Name", "Give your species a unique name.")
                return
            }
        } catch {
            alertUser("Error", "Failed to check for duplicate name.")
        }
            
        
        //Save and insert if needed
        if new {
            context.insert(species)
        } else {
            // Update timestamp to be at the top of last added. :) 
            species.timestamp = Date()
        }
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to save species.")
        }
        
        //Close view
        backAction()
    }
}




#if DEBUG
struct EditSpecies_PreviewWrapper: View {
    
    @Query var species: [Species]
    
    var body: some View {
        EditSpecies(species: species[3], new: false) {
            print("bck")
        }
    }
}

#Preview {
    EditSpecies_PreviewWrapper()
        .superContainer()
}
#endif
