//
//  EditEntryWeather.swift
//  fishing3
//
//  Created by Emil Kovács on 26. 7. 2025..
//

import SwiftUI

struct EditEntryWeather: View {
    
    let entryWeather: EntryWeather?
    var backAction: () -> Void
    
    var body: some View {
        ZStack{
            ScrollView{
                if let weather = entryWeather {
                    VStack(alignment: .leading, spacing: AppSize.regularSpace) {
                        
                        Text("Conditions")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.vertical,16)
                        
                        WeatherRow(.temp, "\(weather.temp_current)")
                        WeatherRow(.pressure, "\(Int(weather.pressure))",weather.pressureTrend.symbolName)
                        WeatherRow(.humidity, "\(Int(weather.humidity))")
                        
                        Spacer().frame(height: AppSize.smallSpace)
                        
                        
                        WeatherRow(.cloud_cover, "\(Int(weather.cloudCover))")
                        WeatherRow(.rain_amount, "\(Int(weather.precipitation_amount))")
                        WeatherRow(.rain_chance, "\(Int(weather.precipitation_chance))")
                        
                        Spacer().frame(height: AppSize.regularSpace)
                        
                        WeatherRow(.wind_speed, "\(Int(weather.wind_speed))")
                        WeatherRow(.wind_gust, "\(Int(weather.wind_gusts))")
                        
                        Spacer().frame(height: AppSize.smallSpace)
                        
                        Text("Solunar")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.vertical,16)
                        
                        WeatherRow(.moon, weather.moon.label, weather.moon.symbolName)
                        WeatherRow(.sunrise, "\(AppFormatter.dayAndTime(weather.sunrise))")
                        WeatherRow(.sunset, "\(AppFormatter.dayAndTime(weather.sunrise))")
                        WeatherRow(.moonrise, "\(AppFormatter.dayAndTime(weather.sunrise))")
                        WeatherRow(.moonset, "\(AppFormatter.dayAndTime(weather.sunrise))")
                        
                        
                        
                        Spacer().frame(height: AppSize.smallSpace)
                        Text("Other")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding(.vertical,16)
                        
                        WeatherRow(.temp_low, "\(weather.temp_low)")
                        WeatherRow(.temp_high, "\(weather.temp_high)")
                        WeatherRow(.temp_feels, "\(weather.temp_feels)")
                        
                        Spacer().frame(height: AppSize.smallSpace)
                        WeatherRow(.visibility, "\(Int(weather.visibility))")
                        WeatherRow(.uv_index, "\(weather.uvIndex)")
                        
                        Spacer().frame(height: AppSize.smallSpace)
                        
                        Text("Apple Weather")
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top,AppSafeArea.edges.top + AppSize.buttonSize + 32)
                    .padding(.bottom,AppSafeArea.edges.bottom)
                }
            }
            .scrollIndicators(.hidden)
            
            //Top Blocker
            ListTopBlocker()
            
            //Top Controls
            HStack{
                CircleButton("chevron.left") {
                    backAction()
                }
                Spacer()
                TextButton("Done") {
                    backAction()
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            .padding(.top,AppSafeArea.edges.top)
            
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
    
    
}

struct WeatherRow: View {
    
    let type: WeatherTypes
    let value: String
    let trailingSymbol: String?
    
    var body: some View {
        
            HStack(spacing: 0){
                Image(systemName: type.symbolName)
                    .frame(width: AppSize.symbolWidth,alignment: .center)
                    .font(.callout2)
                    .padding(.trailing,AppSize.spacing)
                Text(type.label)
                    .font(.callout)
                Spacer()
                if let symbol = trailingSymbol  {
                    Image(systemName: symbol)
                        .frame(width: AppSize.symbolWidth,alignment: .center)
                        .font(.callout2)
                        .padding(.trailing,AppSize.spacing)
                }
                Text(value)
                    .font(.callout)
                if let unit = type.unit {
                    Text(unit)
                }
            }
            Divider()
        
    }
    
    init(_ type: WeatherTypes, _ value: String, _ trailingSymbol: String? = nil) {
        self.type = type
        self.value = value
        self.trailingSymbol = trailingSymbol
    }
}

//MARK: - PREVIEW

#if DEBUG

struct EditEntryWeather_PreviewWrapper: View {
    var body: some View {
        ZStack{
            EditEntryWeather(entryWeather: DemoData.weathers[1]) {
                print("<- Back action")
            }
        }
        .background(Color.yellow)
        
    }
}

#endif

#Preview {
    EditEntryWeather_PreviewWrapper()
}
