//
//  Concepts.swift
//  fishing3
//
//  Created by Emil Kovács on 14. 7. 2025..
//

import SwiftUI
import MapKit

struct Concepts: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: AppSize.spacing) {

                    Text("Today")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom,12)
                    
                    InlineRow_Demo()
                    NoCatch_Demo()
                    InlineRow_Demo()
                        .padding(.bottom)
                    
                    Text("March")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom,12)
                        .padding(.top,12)
                    
                    CatchDay_DemoAlt()
                    CatchDay_DemoAlt()
                    
                    Text("February")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom,12)
                        .padding(.top,12)
                    
                    CatchDay_DemoAlt()

                    
                    Text("January")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom,12)
                        .padding(.top,12)
                    
                    CatchDay_DemoAlt()
                    CatchDay_DemoAlt()
                    CatchDay_DemoAlt()
                    
                    
                    
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            HStack{Spacer()}
        }
        .background(AppColor.tone)
    }
    
    struct CatchDay_DemoAlt: View {
        var body: some View {
            VStack{
                
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(" June 12,  ")
                            
                            Image(systemName: "clock")
                                .font(.caption)
                            Text(" 4h  ")
                            
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColor.half)
                        .padding(.bottom,6)
                        
                        HStack{
                            Text("Lake Palic, Subotica")
                                .fontWeight(.medium)
                            Spacer()
                            
                        }
                        
                        HStack{
                            Text("5 catches, 2 species, 6 baits")
                                .font(.subheadline)
                                .foregroundStyle(AppColor.half)
                            Spacer()
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: AppSize.radius)
                        .fill(AppColor.secondary)
                        .frame(width: 74, height: 74)
                        .overlay(alignment: .center) {
                            VStack{
                               Text("5")
                            }
                            .font(.callout)
                        }
                       
                    
                }
                
                
                Divider()
                    .padding(.vertical,12)
            }
        }
    }
    struct NoCatch_Demo: View {
        var body: some View {
            VStack(alignment: .leading){
                HStack(spacing: 0){
                   

                   
                   Text("Northern Pike, Trailing Bait")
                       .fontWeight(.medium)
                   
                   Spacer()
                   
                    HStack(spacing:0){
                        
                        Image(systemName: "cloud")
                            .font(.caption)
                            .fontWeight(.medium)
                            
                        Text(" Cloudy,  ")
                        
                        Text("14:36  ")
                        
                    }
                   
                }
                .font(.subheadline)
                .foregroundStyle(AppColor.half)
                
                Divider()
                    .padding(.vertical,12)
            }
        }
    }
    struct InlineRow_Demo: View {
        var body: some View {
            VStack{
                HStack(alignment: .center){
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing:0){
                            
                            Image(systemName: "cloud")
                                .font(.caption)
                                .fontWeight(.medium)
                                
                            Text(" Cloudy,  ")
                            
                            Text("14:48  ")
                            
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColor.half)
                        .padding(.bottom,6)
                        
                        Text("Northern Pike, Trailing Bait")
                            .fontWeight(.medium)
                        
                        Text("20kg, 63cm, from Shore ")
                            .font(.subheadline)
                            .foregroundStyle(AppColor.half)
                    }
                    
                    Spacer()
                    Image("demoC")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 82, height: 82,alignment: .top)
                        .cornerRadius(12)
                    
                }
                
                Divider()
                    .padding(.vertical,12)
                
            }
        }
    }
}

struct ViewCatchDemo:View {
    
    //where are the images?
    
    var body: some View {
        ZStack{
            ScrollView{
                ViewCatchMap()
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack(spacing:8){
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("June 16, 14:23")
                            .font(.callout)
                    }
                    .foregroundStyle(AppColor.half)
                    .padding(.bottom,6)
                    
                    Text("Northern Pike, Trailing Bait")
                        .font(.title)
                        .fontWeight(.medium)
                    Text("23kg, 45cm, from shore")
                        .font(.callout)
                        .foregroundStyle(AppColor.half)
                        
                    
                    Text("I made a great catch, the corn trick was beautiful. Sun is strong i have some beer.")
                        .padding(.top)
                        .padding(.bottom)
                    
                    Divider()
                        .padding(.vertical,12)
                    
                    HStack{
                        Image(systemName: "matter.logo")
                            .font(.callout)
                        Text("Catch details")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    
                    Divider()
                        .padding(.vertical,12)
                    
                    HStack{
                        Image(systemName: "humidity.fill")
                            .font(.callout)
                        Text("Water details")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    
                    Divider()
                        .padding(.vertical,12)
                    
                    HStack{
                        Image(systemName: "cloud")
                            .font(.callout)
                        Text("Weather details")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    
                    Divider()
                        .padding(.vertical,12)
                    
                    HStack{
                        Image(systemName: "swiftdata")
                            .font(.callout)
                        Text("Metada")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    
                    
                    HStack{ Spacer() }
                }
                .padding()
                .padding(.top,-80)
                .padding(.bottom,32)
                
            }
        }
        .scrollIndicators(.hidden)
        .background(AppColor.tone)
        .ignoresSafeArea()
    }
}

struct ViewCatchMap: View {
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.04454, longitude: 19.93753), span: .init(latitudeDelta: 0.012, longitudeDelta: 0.012))
    
    private let mapHeight: CGFloat = 480
    private let horizontalPadding: CGFloat = 6
    private let verticalPadding: CGFloat = 84
    var body: some View {
        Map(initialPosition: .region(region))
            .grayscale(1.0)
            .mapControlVisibility(.hidden)
            .safeAreaPadding(.vertical, verticalPadding)
            .safeAreaPadding(.horizontal, horizontalPadding)
            .frame(height: mapHeight)
            .overlay{
                AppColor.dark.opacity(0.5)
                    .blendMode(.overlay)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [AppColor.tone, AppColor.tone.opacity(0.6), AppColor.tone.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 84)
                .frame(maxHeight: .infinity,alignment: .bottom)
            }
            .overlay(alignment: .center) {
                Circle()
                    .fill(AppColor.primary.opacity(0.25))
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 22, height: 22, alignment: .center)
            }
    }
}

struct ViewCatchImage: View {
    let name: String
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(height: 240)
            .cornerRadius(10)
    }
}


struct FeedbackDemo: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 12) {
                    
                    
                    Text("Feedback")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Share your opinion. Tell us what you like, dislike or request features, anonymously. ")
                        .foregroundStyle(AppColor.half)
                    
                
                    
                    Divider().padding(.vertical,8)
                    
                    HStack{ Spacer() }
                }
                .padding()
                .padding(.top,48)
            }
        }
        .background(AppColor.tone)
    }
}

struct SettingsDemo: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 12) {
                    
                    
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Manage preferences and things.")
                        .foregroundStyle(AppColor.half)
                    
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "app")
                            .font(.callout)
                        Text("App Icon")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.callout)
                        Text("Color scheme")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "chart.dots.scatter")
                            .font(.callout)
                        Text("Analytics")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.callout)
                        Text("Share application")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "star")
                            .font(.callout)
                        Text("Leave a review")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    
                    Text("Subscription")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Manage your subscription things.")
                        .foregroundStyle(AppColor.half)
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "matter.logo")
                            .font(.callout)
                        Text("Manage subscription")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "shekelsign.arrow.trianglehead.counterclockwise.rotate.90")
                            .font(.callout)
                        Text("Restore purchases")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    
                    
                    
                    Text("Documents")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Manage and view your saved data.")
                        .foregroundStyle(AppColor.half)
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "hand.raised.fill")
                            .font(.callout)
                        Text("Privacy policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "document")
                            .font(.callout)
                        Text("Terms of use")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "matter.logo")
                            .font(.callout)
                        Text("References")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    
                    HStack{ Spacer() }
                }
                .padding()
                .padding(.top,48)
            }
        }
        .background(AppColor.tone)
    }
}

struct ManageDataDemo: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 12) {
                    Text("Manage Data")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Manage and view your saved data.")
                        .foregroundStyle(AppColor.half)
                    
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "calendar.day.timeline.left")
                            .font(.callout)
                            .frame(width: 24, alignment: .center)
                        Text("Manage Catches")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "fish")
                            .font(.callout)
                            .frame(width: 24, alignment: .center)
                        Text("Manage species")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "capsule")
                            .font(.callout)
                            .frame(width: 24, alignment: .center)
                        Text("Manage baits")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    
                    
                    
                    Text("Explore Data")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Manage and view your saved data.")
                        .foregroundStyle(AppColor.half)
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "note.text")
                            .font(.callout)
                            .frame(width: 24, alignment: .center)
                        Text("Excrept all notes")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "photo.stack")
                            .font(.callout)
                            .frame(width: 24, alignment: .center)
                        Text("Excrept all images")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    
                    
                    
                    
                    
                    Text("Advanced")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.top,32)
                    Text("Manage and view your saved data.")
                        .foregroundStyle(AppColor.half)
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "icloud")
                            .font(.callout)
                        Text("iCloud backup")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "externaldrive")
                            .font(.callout)
                        Text("Export data backup")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "opticaldiscdrive")
                            .font(.callout)
                        Text("Import data backup")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    Divider().padding(.vertical,8)
                    HStack{
                        Image(systemName: "trash")
                            .font(.callout)
                        Text("Delete all data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    
                    
                    HStack{ Spacer() }
                }
                .padding()
                .padding(.top,48)
            }
        }
        .background(AppColor.tone)
    }
}

struct PaywallDemo: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    Text("Let's start fishing.")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding()
                    Text("Test the full app, 24 free logged catches with auto location and weather, subscribe later. ")
                        .padding(.horizontal)
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                    
                    Text("$9.99 monthly or $89.99 a year. ")
                        .font(.caption)
                        .foregroundStyle(AppColor.half)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
    
                    Button {} label: {
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "app.gift.fill")
                                Text("Start free trial.")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .padding()
                        .padding(.vertical,4)
                        .foregroundStyle(AppColor.primary)
                        .background(AppColor.secondary)
                        .cornerRadius(AppSize.radius)
                        .padding()
                    }

                    Text("View all plans")
                        .underline()
                        .padding(.bottom,24)
                    
                    HStack{
                        Text("Terms of Use")
                        Spacer()
                        Text("Privacy")
                        Spacer()
                        Text("Redeem")
                        Spacer()
                        Text("Restore")
                    }
                    .foregroundStyle(AppColor.half)
                    .font(.subheadline)
                    .padding()
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
        }
        .background(AppColor.tone)
    }
}

/*
#Preview("Paywall", body: {
    PaywallDemo()
})

#Preview("Feedback") {
    FeedbackDemo()
       
}

#Preview("View Catch") {
    ViewCatchDemo()
       
}
*/

#Preview {
    Concepts()
    //ViewCatchDemo()
}
