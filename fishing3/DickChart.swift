//
//  DickChart.swift
//  fishing3
//
//  Created by Emil Kovács on 25. 7. 2025..
//

import SwiftUI
import SwiftData
import Charts


struct DickChart2: View {
    var sunrise: Date
    var sunset: Date
    var moonrise: Date
    var moonset: Date
    var catchTime: Date
    
    // MARK: - Helpers
    private func normalizedTime(from date: Date, relativeTo ref: Date) -> Int? {
        guard Calendar.current.isDate(date, inSameDayAs: ref) else { return nil }
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = comps.hour, let minute = comps.minute else { return nil }
        return hour * 60 + minute
    }
    
    private func clampToDay(_ minutes: Int) -> Int {
        max(0, min(1440, minutes))
    }
    
    private func computeMajorTransits(moonrise: Date, moonset: Date) -> (upper: Date, lower: Date) {
        var rise = moonrise.timeIntervalSinceReferenceDate
        var set = moonset.timeIntervalSinceReferenceDate
        
        if set < rise { set += 24 * 3600 } // handle cross-midnight
        
        let mid = (rise + set) / 2
        let upper = Date(timeIntervalSinceReferenceDate: mid)
        let lower = upper.addingTimeInterval(12 * 3600 + 25 * 60) // +12h25m
        
        return (upper, lower)
    }
    
    // MARK: - Computed Properties
    private var lineData: [ChartData] {
        guard
            let nSunrise = normalizedTime(from: sunrise, relativeTo: catchTime),
            let nSunset = normalizedTime(from: sunset, relativeTo: catchTime)
        else {
            return [
                ChartData(x: 0, y: -2),
                ChartData(x: 720, y: 0),
                ChartData(x: 1440, y: -2)
            ]
        }
        
        return [
            ChartData(x: 0, y: -2),
            ChartData(x: nSunrise, y: 0),
            ChartData(x: 720, y: 5),
            ChartData(x: nSunset, y: 0),
            ChartData(x: 1440, y: -2)
        ]
    }
    
    private var nMoonrise: Int? { normalizedTime(from: moonrise, relativeTo: catchTime) }
    private var nMoonset: Int? { normalizedTime(from: moonset, relativeTo: catchTime) }
    
    private var majorA: Int? {
        let upper = computeMajorTransits(moonrise: moonrise, moonset: moonset).upper
        guard Calendar.current.isDate(upper, inSameDayAs: catchTime) else { return nil }
        return normalizedTime(from: upper, relativeTo: catchTime)
    }
    
    private var majorB: Int? {
        let lower = computeMajorTransits(moonrise: moonrise, moonset: moonset).lower
        guard Calendar.current.isDate(lower, inSameDayAs: catchTime) else { return nil }
        return normalizedTime(from: lower, relativeTo: catchTime)
    }
    
    // MARK: - View
    var body: some View {
        Chart {
            // Daylight curve
            ForEach(lineData) { ld in
                LineMark(x: .value("", ld.x), y: .value("", ld.y))
            }
            .foregroundStyle(.white.opacity(0.3))
            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
            .interpolationMethod(.cardinal)
            
            // Catch marker
            if let catchX = normalizedTime(from: catchTime, relativeTo: catchTime) {
                RuleMark(x: .value("Catch", catchX))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            // Major A (Overhead)
            if let major = majorA {
                RectangleMark(
                    xStart: .value("", clampToDay(major - 60)),
                    xEnd: .value("", clampToDay(major + 60)),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.green.opacity(0.5))
            }
            
            // Major B (Underfoot)
            if let major = majorB {
                RectangleMark(
                    xStart: .value("", clampToDay(major - 60)),
                    xEnd: .value("", clampToDay(major + 60)),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.red.opacity(0.5))
            }
            
            
            
            // Minor A (Moonrise)
            if let rise = nMoonrise {
                RectangleMark(
                    xStart: .value("", clampToDay(rise - 30)),
                    xEnd: .value("", clampToDay(rise + 30)),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.blue.opacity(0.2))
            }
            
            // Minor B (Moonset)
            if let set = nMoonset {
                RectangleMark(
                    xStart: .value("", clampToDay(set - 30)),
                    xEnd: .value("", clampToDay(set + 30)),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.blue.opacity(0.2))
            }
        }
        .frame(height: 120)
    }
}

// MARK: - Supporting Struct
struct ChartData: Identifiable {
    let id = UUID()
    let x: Int
    let y: Double
}



struct DickChart: View {
    
    var catchTime: Date
    var weather: EntryWeather
    
    var lineData:[ChartData] {
        
        let nSunrise = normalizedTime(from: weather.sunrise)
        let nSunset = normalizedTime(from: weather.sunset)
        let midPoint = nSunset - nSunrise
        
        print("rise: \(nSunrise),\(midPoint),set \(nSunset)")
        
        return [
            ChartData(x: 0, y: -2),
            ChartData(x: nSunrise,y:0),
            ChartData(x: 720, y: 5),
            ChartData(x: nSunset,y:0),
            ChartData(x: 1440, y: -2)
        ]
    }
    
    var nMoonrise: Int {
        normalizedTime(from: weather.moonrise)
    }
    
    var nMoonset: Int {
        normalizedTime(from: weather.moonset)
    }
    
    var majorA: Int? {
        let rise = weather.moonrise.timeIntervalSinceReferenceDate
        let set = weather.moonset.timeIntervalSinceReferenceDate
        let mid  = (rise + set) / 2
        let midDate = Date(timeIntervalSinceReferenceDate: mid)
        
        let valid = Calendar.current.isDate(midDate, inSameDayAs: catchTime)
        
        if valid {
            return normalizedTime(from: midDate)
        } else {
            return nil
        }
    }
    
    var majorB: Int? {
        let rise = weather.moonrise.timeIntervalSinceReferenceDate
        var set = weather.moonset.timeIntervalSinceReferenceDate
        
        if set < rise {
            set += 24 * 3600
        }
        
        let mid  = (rise + set) / 2
        let midDate = Date(timeIntervalSinceReferenceDate: mid)
        
        // Add 12h 25m for underfoot transit
        let underfootDate = midDate.addingTimeInterval(12 * 3600 + 25 * 60)
        
        let valid = Calendar.current.isDate(underfootDate, inSameDayAs: catchTime)
        if valid {
            return normalizedTime(from: underfootDate)
        } else {
            return nil
        }
    }
    
    
    var catchData: ChartData {
        let nSunrise = normalizedTime(from: weather.sunrise)
        let nSunset = normalizedTime(from: weather.sunset)
        let normCatch = normalizedTime(from: catchTime)
        let x = catmullRomInterpolate(p0: ChartData(x: 0, y: -2), p1: ChartData(x: nSunrise,y:0), p2:  ChartData(x: 720, y: 5), p3: ChartData(x: nSunset,y:0), t: Double(normCatch))
        
        return ChartData(x: normCatch, y: x)
        
    }
    
    var body: some View {
        Chart{
            
            
            RuleMark(x: .value("Catch",  normalizedTime(from: catchTime) ))
                .foregroundStyle(.white.opacity(0.5))
            
            
            if let major = majorB {
                RectangleMark(
                    xStart: .value("", major - 60),
                    xEnd: .value("", major + 60),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.red.opacity(0.5))
            }
            
            if let major = majorA {
                RectangleMark(
                    xStart: .value("", major - 60),
                    xEnd: .value("", major + 60),
                    yStart: .value("MinY", -5),
                    yEnd: .value("MaxY", 10)
                )
                .foregroundStyle(.green.opacity(0.5))
            }
            
            
            RectangleMark(
                xStart: .value("", nMoonrise - 30),
                xEnd: .value("", nMoonrise + 30),
                yStart: .value("MinY", -5),
                yEnd: .value("MaxY", 10)
            )
            .foregroundStyle(.blue.opacity(0.2))
            
            RectangleMark(
                xStart: .value("", nMoonset - 30),
                xEnd: .value("", nMoonset + 30),
                yStart: .value("MinY", -5),
                yEnd: .value("MaxY", 10)
            )
            .foregroundStyle(.blue.opacity(0.2))
            
            ForEach(lineData){ ld in
                LineMark(x: .value("", ld.x), y:.value("", ld.y))
                    
            }
            .foregroundStyle(
                LinearGradient(colors: [Color.clear,Color.white,Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .lineStyle(StrokeStyle(lineWidth: 4,lineCap: .round))
            .interpolationMethod(.cardinal)
        

            
        }
        .frame(height: 120)
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
            }
        }
        .chartXAxis{
            AxisMarks{
                AxisGridLine()
                AxisValueLabel()
            }
        }

    }
    
    private func normalizedTime(from date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        
        return (hour * 60) + minute
    }
    
    func catmullRomInterpolate(p0: ChartData, p1: ChartData, p2: ChartData, p3: ChartData, t: Double) -> Double {
        let t2 = t * t
        let t3 = t2 * t

        return 0.5 * (
            (2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * t2 +
            (-p0.y + 3*p1.y - 3*p2.y + p3.y) * t3
        )
    }
}


//MARK: - PREVIEW
struct DickChart_PreviewWrapper: View {
    
    @Query var entries: [Entry]
    
    
    var body: some View {
        ZStack{
            ScrollView{
                HStack{Spacer().frame(height: 124)}
                
                let firstWeather = entries[1].weather
                
                
                DickChart(catchTime: entries[8].timestamp,weather: firstWeather!)
                    .padding()
                
               // DickChart2(catchTime: entries[8].timestamp,weather: firstWeather!)
                DickChart2(
                    sunrise: Calendar.current.date(bySettingHour: 5, minute: 14, second: 0, of: .now)!,
                    sunset: Calendar.current.date(bySettingHour: 20, minute: 18, second: 0, of: .now)!,
                    moonrise: Calendar.current.date(bySettingHour: 16, minute: 56, second: 0, of: .now)!,
                    moonset: Calendar.current.date(bySettingHour: 17, minute: 51, second: 0, of: .now.addingTimeInterval(86400))!,
                    catchTime: Date.now
                )
                .padding()
                
                
                HStack{Spacer().frame(height: 124)}
            }
        }
        .background(AppColor.tone)
    }
}
#Preview {
    DickChart_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
        
}
