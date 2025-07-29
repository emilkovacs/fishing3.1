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
    case temp_current, temp_low, temp_high, temp_feels
    
    case humidity
    case pressure
    case cloudCover
    case windSpeed, windGust
    case rainAmount, rainChance
    case uvIndex, visibility
    
    case waterTemp, waterVisibility, catchDepth
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
    
    //Q: Where to annotate the numbers?
    
    let allEntries: [Entry]
    let keyPath: KeyPath<Entry, String?>
    let tint: Color
    
    @State private var data: [LabeledData] = []
    @State private var yRange: ClosedRange<Int> = 0...1
    @State private var loaded = false
    
    @State private var selectedY: String?
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
                .frame(height: 140)
                
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
            
            HStack{
                VStack(alignment: .leading) {
                    Text("Wind speed")
                        .font(.callout)
                        .fontWeight(.medium)
                    Text("Amount of catches by wind speed.")
                        .font(.caption)
                        .foregroundStyle(AppColor.half)
                }
                Spacer()
            }
            .padding(.bottom,12)

            
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
                .frame(height: 140)
                .chartXSelection(value: $selectedX)
                .chartXScale(domain: xRange)
                .chartYScale(domain: yRange)
                
                
            } else {
                ProgressView("Loading Chart…")
                    .frame(height: 140)
            }
        }
        .padding(.bottom,48)
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

#if DEBUG

struct ChartsTemplate_PreviewWrapper: View {
    
    @Query var allEntries: [Entry]
    
    
    var body: some View {
        List{
            HStack{Spacer().frame(height: 160)}.modifier(ListModifier())
            
            LineChart(allEntries: allEntries, keyPath: \.weight,tint: .blue)
                .modifier(ListModifier())
            
            LineChart(allEntries: allEntries, keyPath: \.length,tint: .orange)
                .modifier(ListModifier())
                
            TimeLineChart(allEntries: allEntries, tint: .blue)
                .modifier(ListModifier())
                .padding(.bottom,128)
            
            VerticalBarChart(allEntries: allEntries, keyPath: \.species?.name, tint: .pink)
                .modifier(ListModifier())
                .padding(.bottom,128)
            HorizontalBarChart(allEntries: allEntries, keyPath: \.species?.name, tint: .yellow)
                .modifier(ListModifier())
                .padding(.bottom,128)
            
            HorizontalBarChart(allEntries: allEntries, keyPath: \.bait?.name,tint: .green)
                .modifier(ListModifier())
                .padding(.bottom,128)
            

            
            LineChart(allEntries: allEntries, keyPath: \.weather?.wind_speed,tint: .purple)
                .modifier(ListModifier())
                .padding(.bottom,128)
            
           
        }
        .listStyle(.plain)
        .background(AppColor.tone)
    }
}

#Preview{
    ChartsTemplate_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}


#endif
