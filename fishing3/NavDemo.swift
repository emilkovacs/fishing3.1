//
//  NavDemo.swift
//  fishing3
//
//  Created by Emil Kovács on 8. 8. 2025..
//

import SwiftUI

struct NavDemo: View {
    @Namespace var ns
    var body: some View {
        NavigationStack{
            
            NavigationLink("alma") {
                if #available(iOS 18.0, *) {
                    DemoDestination()
                        .navigationTransition(.zoom(sourceID: "a", in: ns))
                        .transition(.blurReplace)
                } else {
                    // Fallback on earlier versions
                    DemoDestination()
                }
                   
            }
            
        }
    }
}

struct DemoDestination: View {
    @Namespace var ns
    var body: some View {
        ZStack{
            ScrollView{
                ListTopSpacer()
                HStack{Spacer()}
                VStack{
                    Text("I am the destionation A")
                    NavigationLink("Go more") {
                        if #available(iOS 18.0, *) {
                            DemoDestinationB()
                                .navigationTransition(.zoom(sourceID: "b", in: ns))
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
            }
            .ignoresSafeArea(.container)
            .background(AppColor.tone.ignoresSafeArea(.all))
            .navigationBarBackButtonHidden()
            
        }
    }
}

struct DemoDestinationB: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack{
            ScrollView{
                ListTopSpacer()
                HStack{Spacer()}
                VStack{
                    Text("I am the destionation B")
                    Button {
                        dismiss()
                    } label: {
                        Text("Back")
                    }

                }
            }
            .ignoresSafeArea(.container)
            .background(AppColor.tone.ignoresSafeArea(.all))
            .navigationBarBackButtonHidden()
            
        }
    }
}

#Preview {
    NavDemo()
}
