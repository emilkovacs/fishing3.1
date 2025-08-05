//
//  ContinuousChartTemplate.swift
//  fishing3
//
//  Created by Emil Kovács on 28. 7. 2025..
//

import SwiftUI
import SwiftData
import Charts


enum ChartTypes {
    case hBar, vBar, line, timeline, point
}
enum ChartDataTypes: String, Identifiable, CaseIterable {
    
    //Categorical and stats
    case species_name //*
    case species_water, species_behaviour
    case weight_distribution, length_distribution //*
    case bait_name //*
    case bait_type, bait_position //*
    case casting_method, bottom_type //*
    
    //Linear and stats
    case timestamp //*
    
    //Weather, linear
    case temp_current, temp_low, temp_high, temp_feels ///``@`
    case humidity, pressure ///``@`
    
    case cloudCover, uv_index, air_visibility  ///``@`
    case wind_speed, wind_gusts ///``@`
    
    case rain_chance, rain_amount ///``@`
    
    case water_temp, water_visibility ///``@`
    
    //Weather categorical
    case pressure_trend ///``@`
    case condition ///``@`
    case moon_phase //*
    case tide_state ///``@`
    
    var id: String {self.rawValue}
    
    var chartType: ChartTypes {
        switch self {
        case .species_name, .bait_name, .condition, .moon_phase : return ChartTypes.vBar
        case .weight_distribution, .length_distribution: return ChartTypes.point
        case .bait_type, .bait_position, .casting_method, .bottom_type, .pressure_trend, .tide_state, .species_water, .species_behaviour : return ChartTypes.hBar
        case .timestamp: return ChartTypes.timeline
        case .water_temp, .water_visibility, .rain_amount, .rain_chance, .wind_speed, .wind_gusts, .cloudCover, .uv_index, .air_visibility, .humidity, .pressure, .temp_current, .temp_low, .temp_high, .temp_feels: return ChartTypes.line
        }
    }
    
    var title: String {
        switch self {
        case .species_name: return "Top Species"
        case .species_water: return "Species Water"
        case .species_behaviour: return "Species Behaviour"
        case .weight_distribution: return "Weight distribution"
        case .length_distribution: return "Length distribution"
        case .bait_name: return "Top Baits"
        case .bait_type: return "Bait Types"
        case .bait_position: return "Bait Positions"
        case .casting_method: return "Casting method"
        case .bottom_type: return "Bottom type"
        case .timestamp: return "Time of the day"
            
        case .temp_current: return "Temperature"
        case .temp_low: return "Temperature, Low"
        case .temp_high: return "Temperature, High"
        case .temp_feels: return "Temperature, Feels"
        case .humidity: return "Humidity"
        case .pressure: return "Pressure"
        case .cloudCover: return "Cloud Cover"
        case .uv_index: return "UV Index"
        case .air_visibility: return "Visibility, Air"
        case .wind_speed: return "Wind Speed"
        case .wind_gusts: return "Wind Gusts"
        case .rain_chance: return "Rain Chance"
        case .rain_amount: return "Rain Amount"
        case .water_temp: return "Water Temperature"
        case .water_visibility: return "Visibility, Water"
        case .pressure_trend: return "Pressure Trend"
        case .condition: return "Condition"
        case .moon_phase: return "Moon Phase"
        case .tide_state: return "Tide State"
        }
    }
    var description: String {
        switch self {
        case .species_name: return "Top species caught"
        case .species_water: return "Amount of cathces by water type."
        case .species_behaviour: return  "Amount of cathces by species behaviour."
        case .weight_distribution: return "Distribution of weights"
        case .length_distribution: return "Distribution of lengths"
        case .bait_name: return "Top baits used"
        case .bait_type: return "Amount of cathces by type of bait."
        case .bait_position: return "Amount of cathces by position of bait."
        case .casting_method: return "Amount of cathces by casting methods."
        case .bottom_type: return "Amount of cathces by bottom types."
        case .timestamp: return "Amount of cathces by time of the day."
        case .temp_current: return "Amount of cathces by temperature."
        case .temp_low: return "Amount of cathces by daily low temperature."
        case .temp_high: return "Amount of cathces by daily high temperature."
        case .temp_feels: return  "Amount of cathces by feels like temperature."
        case .humidity: return  "Amount of cathces by humidity."
        case .pressure: return "Amount of cathces by pressure."
        case .cloudCover: return "Amount of cathces by cloud cover."
        case .uv_index: return "Amount of cathces by UV Index."
        case .air_visibility: return "Amount of cathces by visibility in air."
        case .wind_speed: return "Amount of cathces by wind speed."
        case .wind_gusts: return "Amount of cathces by wind gust strenghts."
        case .rain_chance: return "Amount of cathces by chance of rain."
        case .rain_amount: return "Amount of cathces by amount of rain."
        case .water_temp: return "Amount of cathces by water temperature."
        case .water_visibility: return "Amount of cathces by visibility in water."
        case .pressure_trend: return "Amount of cathces by pressure trend."
        case .condition: return "Amount of cathces by condition."
        case .moon_phase: return "Amount of cathces by moon phase."
        case .tide_state: return "Amount of cathces by tide state."
        }
    }
    
    var tint: Color {
        switch self {
        case .species_name: return Color.blue
        case .species_water: return Color.blue
        case .species_behaviour: return Color.blue
        case .weight_distribution: return  Color.blue
        case .length_distribution: return  Color.blue
        case .bait_name: return  Color.orange
        case .bait_type: return Color.orange
        case .bait_position: return Color.orange
        case .casting_method: return Color.mint
        case .bottom_type: return Color.green
        case .timestamp: return Color.yellow
        case .temp_current: return Color.orange
        case .temp_low: return Color.orange
        case .temp_high: return Color.orange
        case .temp_feels: return  Color.orange
        case .humidity: return  Color.teal
        case .pressure: return Color.blue
        case .cloudCover: return Color.mint
        case .uv_index: return Color.purple
        case .air_visibility: return Color.green
        case .wind_speed: return Color.purple
        case .wind_gusts: return Color.purple
        case .rain_chance: return Color.green
        case .rain_amount: return Color.green
        case .water_temp: return Color.blue
        case .water_visibility: return Color.indigo
        case .pressure_trend: return Color.blue
        case .condition: return Color.yellow
        case .moon_phase: return Color.purple
        case .tide_state: return Color.teal
        }
    }
    
    var path: PartialKeyPath<Entry>{
        switch self {
        case .species_name: return \.species?.name
        case .species_water: return \.species?.water.label
        case .species_behaviour: return \.species?.behaviour.label
        case .weight_distribution: return \.weight
        case .length_distribution: return \.length
        case .bait_name: return \.bait?.name
        case .bait_type: return \.bait?.type.label
        case .bait_position: return \.bait?.position.label
        case .casting_method: return \.castingMethod.chartsLabel
        case .bottom_type: return \.bottomType.chartsLabel
        case .timestamp: return \.timestamp
        case .temp_current: return \.weather?.temp_current
        case .temp_low: return \.weather?.temp_low
        case .temp_high: return \.weather?.temp_high
        case .temp_feels: return \.weather?.temp_feels
        case .humidity: return \.weather?.humidity
        case .pressure: return \.weather?.pressure
        case .cloudCover: return \.weather?.cloudCover
        case .uv_index: return \.weather?.uvIndex
        case .air_visibility: return \.weather?.visibility
        case .wind_speed: return \.weather?.wind_speed
        case .wind_gusts: return \.weather?.wind_gusts
        case .rain_chance: return \.weather?.precipitation_chance
        case .rain_amount: return \.weather?.precipitation_amount
        case .water_temp: return \.waterTemperature
        case .water_visibility: return \.waterVisibility
        case .pressure_trend: return \.weather?.pressureTrend.chartsLabel
        case .condition: return \.weather?.condition
        case .moon_phase: return \.weather?.moon.chartsLabel
        case .tide_state: return \.tideState.chartsLabel
        }
    }
}


struct SingleChart: View {
    
    let type: ChartDataTypes
    let allEntries: [Entry]
    
    var body: some View {
        ChartTitle(title: type.title, description: type.description,trailingContent: {
            EmptyView()
        })
            .modifier(ListModifier())
        switch type.chartType {
        case .hBar:
            HorizontalBarChart(allEntries: allEntries, keyPath: type.path as! KeyPath<Entry, String?>, tint: type.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
        case .vBar:
            VerticalBarChart(allEntries: allEntries, keyPath: type.path as! KeyPath<Entry, String?>, tint: type.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
        case .line:
            LineChart(allEntries: allEntries, keyPath: type.path as! KeyPath<Entry, Double?>, tint: type.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
        case .timeline:
            Text("Ooops")
        case .point:
            Text("Ooops")
        }
    }
}
struct MultiChart: View {
    
    let types: [ChartDataTypes]
    let allEntries: [Entry]
    
    @State private var selectedType: ChartDataTypes
    
    init(types: [ChartDataTypes], allEntries: [Entry]) {
        self.types = types
        self.allEntries = allEntries
        //This is dangereous....
        self.selectedType = types.first!
    }
    
    var body: some View {
        ChartTitle(title: selectedType.title, description: selectedType.description,trailingContent: {
            HStack{
                Menu {
                    Picker(selection: $selectedType) {
                        ForEach(types) { item in
                            Text(item.title).tag(item)
                        }
                    } label: {}
                } label: {
                    Image(systemName: "filemenu.and.selection")
                        .font(.callout2)
                        .foregroundStyle(AppColor.half)
                        .frame(width: 32, height: 32)
                        .allowsHitTesting(true)
                }
                .buttonStyle(ActionButtonStyle({AppHaptics.light()}))
            }
            
        })
        .modifier(ListModifier())
       
        switch selectedType.chartType {
        case .hBar:
            HorizontalBarChart(allEntries: allEntries, keyPath: selectedType.path as! KeyPath<Entry, String?>, tint: selectedType.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
                .id(selectedType.id)
        case .vBar:
            VerticalBarChart(allEntries: allEntries, keyPath: selectedType.path as! KeyPath<Entry, String?>, tint: selectedType.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
                .id(selectedType.id)
        case .line:
            LineChart(allEntries: allEntries, keyPath: selectedType.path as! KeyPath<Entry, Double?>, tint: selectedType.tint)
                .modifier(ListModifier())
                .padding(.bottom,32)
                .id(selectedType.id)
        case .timeline:
            Text("Ooops")
        case .point:
            Text("Ooops")
        }
    }
}



//Chart data types
/// Used to display categorical or continuous data on charts.
struct LabeledData: Identifiable {
    var id: String {x}
    var x: String
    var y: Int
}
struct NumericData: Identifiable {
    var id: Int {x}
    var x: Int
    var y: Int
}

//Chart transform functions
/// Used to prepare data
func compileLabeledData(_ allEntries: [Entry], keyPath: KeyPath<Entry, String?>) -> [LabeledData] {
    var counts = [String: Int](minimumCapacity: allEntries.count)

    for item in allEntries {
        guard let key = item[keyPath: keyPath] else { continue } // Skip nil values
        counts[key, default: 0] += 1
    }

    var result = [LabeledData]()
    result.reserveCapacity(counts.count)

    for (key, count) in counts {
        result.append(LabeledData(x: key, y: count))
    }

    result.sort { $0.y > $1.y } // Sort in place

    if result.count > 6 {
        result.removeSubrange(6..<result.count)
    }

    return result
}
func compileNumericData(_ allEntries: [Entry], keyPath: KeyPath<Entry, Double?>) -> [NumericData] {
    
    var counts = [Int: Int](minimumCapacity: allEntries.count)

    for entry in allEntries {
            if let rawValue = entry[keyPath: keyPath] {  //Safely unwrap
                let value = Int(rawValue.rounded())
                counts[value, default: 0] += 1
            }
        }

    var result = [NumericData]()
    result.reserveCapacity(counts.count)

    for (key, count) in counts {
        result.append(NumericData(x: key, y: count))
    }

    result.sort { $0.x < $1.x } // Sort in place
    return result
}
func compileTimeData(
    _ allEntries: [Entry],
    bucketSize: TimeInterval = 900 // 15 minutes
) -> [NumericData] {
    
    let totalBuckets = Int((24 * 60 * 60) / bucketSize) // 96 buckets for 15 min intervals
    var counts = Array(repeating: 0, count: totalBuckets)
    let calendar = Calendar.current
    
    for entry in allEntries {
        let timestamp = entry.timestamp
        let components = calendar.dateComponents([.hour, .minute], from: timestamp)
        let seconds = TimeInterval((components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60)
        let bucketIndex = Int(seconds / bucketSize)
        
        if bucketIndex >= 0 && bucketIndex < totalBuckets {
            counts[bucketIndex] += 1
        }
    }
    
    var result = [NumericData]()
    result.reserveCapacity(totalBuckets)
    
    for i in 0..<totalBuckets {
        let seconds = TimeInterval(i) * bucketSize
        result.append(NumericData(x: Int(seconds), y: counts[i]))
    }
    
    return result
}
func compileRange<T>( data: [T], key: (T) -> Int, expanded: Bool ) -> ClosedRange<Int> {
    //Usage example: let xRange = compileRange(data: chartData, key: { $0.x }, expanded: true)
    guard let first = data.first else { return 0...10 }

    var minValue = key(first)
    var maxValue = minValue

    for item in data.dropFirst() {
        let value = key(item)
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
    }

    if !expanded {
        return minValue...maxValue
    }

    let range = maxValue - minValue
    let padding = max(Int(Double(range) * 0.1), 1)

    return (minValue - padding)...(maxValue + padding)
}

//

struct ChartTitle<Content:View>: View {
    
    let title: String
    let description: String
    let trailingContent: () -> Content
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColor.half)
            }
            Spacer()
            trailingContent()
        }
        .padding(.bottom,16)
    }
}

//Chart templates
struct VerticalBarChart: View {
    
    let allEntries: [Entry]
    let keyPath: KeyPath<Entry, String?>
    let tint: Color
    
    @State private var data: [LabeledData] = []
    @State private var xRange: ClosedRange<Int> = 0...1
    @State private var loaded = false
    
    @State private var selectedY: String?
    
    var body: some View {
        VStack{
            if loaded {
                Chart(data) { item in
                    BarMark(
                        xStart: .value("", xRange.min()!),
                        xEnd: .value("", item.y),
                        y: .value("", item.x)
                    )
                    .annotation(position: .trailing, spacing: -4, content: {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(tint)
                            .frame(width: 4)
                            .frame(minHeight: 6)
                    })
                    .annotation(position: .trailing, spacing: 4, content: {
                        if item.x == selectedY {
                            Text("\(item.y)")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    })
                    .foregroundStyle(
                        LinearGradient(colors: [tint.opacity(item.x == selectedY ? 0.5 : 0.35),Color.clear], startPoint: .trailing, endPoint: .leading)
                    )
                    .cornerRadius(5)
                    
                }
                .chartYSelection(value: $selectedY)
                .chartXScale(domain: xRange)
                .frame(height: 240)
                .overlay(alignment: .center) {
                    if data.isEmpty {
                        EmptyChartMessage()
                    }
                }
                
            } else {
                ProgressView("Loading Chart…")
                    .frame(height: 140)
            }
        }
        .task {computeData()}
    }
    
    private func computeData() {
        // Copy happens on main thread
        let entriesCopy = allEntries
        let keyPathCopy = keyPath
        Task(priority: .userInitiated) {
            let calculatedData = compileLabeledData(entriesCopy, keyPath: keyPathCopy)
            let calculatedRange = compileRange(data: calculatedData, key: {$0.y}, expanded: true)
            await MainActor.run {
                self.data = calculatedData
                self.xRange = calculatedRange
                self.loaded = true
            }
        }
    }
}
struct HorizontalBarChart: View {
    
    let allEntries: [Entry]
    let keyPath: KeyPath<Entry, String?>
    let tint: Color
    
    @State private var data: [LabeledData] = []
    @State private var yRange: ClosedRange<Int> = 0...1
    @State private var loaded = false
    
    @State private var selectedX: String?
    
    var body: some View {
        VStack{
            if loaded {
                Chart(data) { item in
            
                    BarMark(
                        x: .value(item.x, item.x),
                        yStart: .value("", yRange.min()!),
                        yEnd: .value("", item.y)
                    )
                    
                    .annotation(position: .top, spacing: -4, content: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tint)
                            .frame(height: 4)
                            .frame(minWidth: 16)
                    })
                    .annotation(position: .top, spacing: 5, content: {
                        if selectedX == item.x {
                            Text("\(item.y)")
                                .font(.caption2)
                        }
                    })
                    .foregroundStyle(
                        LinearGradient(colors: [tint.opacity(selectedX == item.x ? 0.5 : 0.35),Color.clear], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(8)
                    
                }
                .chartXSelection(value: $selectedX)
                .chartYScale(domain: yRange)
                .frame(height: AppSize.chartHeight)
                .overlay(alignment: .center) {
                    if data.isEmpty {
                        EmptyChartMessage()
                    }
                }
            } else {
                ProgressView("Loading Chart…")
                    .frame(height: AppSize.chartHeight)
            }
        }
        .task {computeData()}
    }
    
    private func computeData() {
        // Copy happens on main thread
        let entriesCopy = allEntries
        let keyPathCopy = keyPath
        Task(priority: .userInitiated) {
            let calculatedData = compileLabeledData(entriesCopy, keyPath: keyPathCopy)
            let calculatedRange = compileRange(data: calculatedData, key: {$0.y}, expanded: true)
            await MainActor.run {
                self.data = calculatedData
                self.yRange = calculatedRange
                self.loaded = true
            }
        }
    }
}
struct LineChart: View {
    
    let allEntries: [Entry]
    let keyPath: KeyPath<Entry, Double?>
    let tint: Color
    
    @State private var data: [NumericData] = []
    @State private var xRange: ClosedRange<Int> = 0...1
    @State private var yRange: ClosedRange<Int> = 0...1
    @State private var loaded = false
    
    @State private var selectedX: Int?
    
    var body: some View {
        VStack(alignment: .leading){
            if loaded {
                Chart(data) { item in
                    
                    LineMark(
                        x: .value("", item.x),
                        y: .value("", item.y),
                        series: .value("", "Line")
                    )
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(tint)
                    
                    AreaMark(
                        x: .value("", item.x),
                        y: .value("", item.y),
                        series: .value("", "Line")
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [tint.opacity(0.35),Color.clear], startPoint: .top, endPoint: .bottom)
                    )
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.catmullRom)
                    
                    if let selected = selectedX{
                        RuleMark(x: .value("", selected))
                            .foregroundStyle(AppColor.half)
                            .annotation(position: .top) {
                                if let selected = selectedX{
                                    if let labelValue = data.first(where: {$0.x == selected}) {
                                        Text("\(labelValue.y)")
                                            .padding(.horizontal,4)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .annotation(position: .bottom) {
                                if let selected = selectedX{
                                    Text("\(selected)")
                                        .padding(.horizontal,4)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                    }

                }
                .frame(height: AppSize.chartHeight)
                .chartXSelection(value: $selectedX)
                .chartXScale(domain: xRange)
                .chartYScale(domain: yRange)
                .overlay(alignment: .center) {
                    if data.isEmpty {
                        EmptyChartMessage()
                    }
                }
                
                
            } else {
                ProgressView("Loading Chart…")
                    .frame(height: AppSize.chartHeight)
            }
        }
        .task { computeData() }
    }
    
    
    private func computeData() {
        // Copy happens on main thread
        let entriesCopy = allEntries
        let keyPathCopy = keyPath
        
        Task(priority: .userInitiated) {
            let calculatedData = compileNumericData(entriesCopy, keyPath: keyPathCopy)
            let calculatedXRange = compileRange(data: calculatedData, key: {$0.x}, expanded: false)
            let calculatedYRange = compileRange(data: calculatedData, key: {$0.y}, expanded: true)
    
            await MainActor.run {
                (self.data, self.xRange, self.yRange, self.loaded) = (calculatedData, calculatedXRange, calculatedYRange, true)
            }
        }
    }
}
struct TimeLineChart: View {
    let allEntries: [Entry]
    let tint: Color
    
    @State private var data: [NumericData] = []
    @State private var xRange: ClosedRange<Int> = 0...1
    @State private var yRange: ClosedRange<Int> = 0...1
    @State private var loaded = false
    
    @State private var selectedX: Int?
    
    var body: some View {
        VStack{
            if loaded {
                Chart(data) { item in
                    
                    LineMark(
                        x: .value("", item.x),
                        y: .value("", item.y),
                        series: .value("", "Line")
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(tint)
                
                    AreaMark(
                        x: .value("", item.x),
                        y: .value("", item.y),
                        series: .value("", "Line")
                    )
                    .foregroundStyle(
                        LinearGradient(colors: [tint.opacity(0.35),Color.clear], startPoint: .top, endPoint: .bottom)
                    )
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.catmullRom)
                    
                    if let selected = selectedX{
                         
                        RuleMark(x: .value("", selected))
                            .foregroundStyle(AppColor.half)
                            .annotation(position: .top, spacing: 0) {
                                if let labelValue = data.first(where: {$0.x == selected}) {
                                    Text("\(labelValue.y)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppColor.primary)
                                        .padding(6)
                                        .background(AppColor.tone)
                                }
                            }
                            .annotation(position: .bottom, spacing: 0) {
                                Text("\(selected)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppColor.primary)
                                    .padding(6)
                                    .background(AppColor.tone)
                            }
                    }

                }
                .frame(height: 140)
                .chartXAxis{
                    AxisMarks(values: .stride(by: 14_400)){ value in
                        AxisGridLine()
                        AxisTick()
                        if let value = value.as(Double.self) {
                            AxisValueLabel {
                                let valueLabel = "\(Int(value / 3600)):00"
                                Text(valueLabel)
                            }
                        }
                    }
                }
                .chartXSelection(value: $selectedX)
                .chartXScale(domain: xRange)
                .chartYScale(domain: yRange)
                
                
            } else {
                ProgressView("Loading Chart…")
                    .frame(height: 140)
            }
        }
        .task { computeData() }
    }
    
    
    private func computeData() {
        // Copy happens on main thread
        let entriesCopy = allEntries
        
        Task(priority: .userInitiated) {
            let calculatedData = compileTimeData(entriesCopy)
            let calculatedXRange = compileRange(data: calculatedData, key: {$0.x}, expanded: false)
            let calculatedYRange = compileRange(data: calculatedData, key: {$0.y}, expanded: true)
    
            await MainActor.run {
                (self.data, self.xRange, self.yRange, self.loaded) = (calculatedData, calculatedXRange, calculatedYRange, true)
            }
        }
    }
}

//Helpers

struct EmptyChartMessage: View {
    var body: some View {
        Text("No Data")
            .font(.callout)
            .italic()
    }
}

#if DEBUG

struct ChartsTemplate_PreviewWrapper: View {
    
    @Query var allEntries: [Entry]
    
    
    var body: some View {
        List{
            HStack{Spacer().frame(height: 160)}.modifier(ListModifier())
            
            HorizontalBarChart(allEntries: [], keyPath: \.castingMethod.chartsLabel, tint: .green)
                .modifier(ListModifier())
            
           // SingleChart(type: .temp_current, allEntries: allEntries)
            // SingleChart(type: .casting_method, allEntries: allEntries)
           // MultiChart(types: [.species_name,.species_water,.species_behaviour], allEntries: allEntries)
           // MultiChart(types: [.species_name,.species_water,.species_behaviour], allEntries: allEntries)
            
            //SingleChart(type: .species_name, allEntries: allEntries)
           // SingleChart(type: .species_water, allEntries: allEntries)
           // SingleChart(type: .species_behaviour, allEntries: allEntries)
            
            //SingleChart(type: .bait_name, allEntries: allEntries)
            
           // SingleChart(type: .bait_position, allEntries: allEntries)
            //SingleChart(type: .bait_type, allEntries: allEntries)
            
            
           
        }
        .listStyle(.plain)
        .background(AppColor.tone)
    }
}

#Preview{
    ChartsTemplate_PreviewWrapper()
        .superContainer()
}


#endif
