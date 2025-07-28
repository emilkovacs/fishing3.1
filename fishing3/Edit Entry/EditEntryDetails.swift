//
//  EditEntryDetails.swift
//  fishing3
//
//  Created by Emil Kovács on 26. 7. 2025..
//

import SwiftUI
import SwiftData

struct EditEntryDetails: View {
    
    @Bindable var entry: Entry
    var backAction: () -> Void
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: AppSize.smallSpace) {
                    HStack{
                        Text("More details")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.top,AppSize.regularSpace)
                        Spacer()
                    }
                    .padding(.bottom,24)
                    
                    
                    LargeSelector("Casting method", $entry.castingMethod)
                    HStack(spacing: AppSize.smallSpace) {
                        LargeDoubleInput(title: "Catch depth", value: $entry.catchDepth, unit: AppUnits.length)
                        LargeDoubleInput(title: "Other depth", value: $entry.catchDepth, unit: AppUnits.length)
                    }
                    .padding(.bottom,32)
                    
                    LargeSelector("Tide state", $entry.tideState)
                    HStack(spacing: AppSize.smallSpace) {
                        LargeDoubleInput(title: "Temperature", value: $entry.waterTemperature, unit: AppUnits.temperature)
                        LargeDoubleInput(title: "Visibility", value: $entry.waterVisibility, unit: AppUnits.length)
                    }
                    LargeSelector("Bottom type", $entry.bottomType)
                    
                }
                .padding(.horizontal)
                .padding(.top,AppSafeArea.edges.top + AppSize.buttonSize + 32)
                .padding(.bottom,AppSafeArea.edges.bottom + AppSize.buttonSize + 32)
            }
            
            //Top Blocker
            ListTopBlocker()
            
            //Top Controls
            HStack{
                CircleButton("chevron.left") { backAction() }
                Spacer()
                TextButton("Done") { backAction() }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .padding(.top,AppSafeArea.edges.top)
            
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
}

//MARK: - PREVIEW
#if DEBUG

struct EditEntryDetails_PreviewWrapper: View {
    var body: some View {
        EditEntryDetails(entry: Entry(lat: 1.0, lon: 1.0)) {
            print("Back")
        }
    }
}

#Preview {
    EditEntryDetails_PreviewWrapper()
        
}


#endif
