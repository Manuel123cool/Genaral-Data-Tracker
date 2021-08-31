//
//  GraphDataProviders.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 30.07.21.
//

import SwiftUI

struct GraphDataprovider: View {
    let dataEntities: [OneDataEntitiy]
    let templateGroups: [[OneEntrieData]]

    let indexes: [Int]
    let isBarGraph: Bool
    
    var body: some View {
        Group {
            if templateTyp == .quantity {
                QuantityDataProvider(dataEntities: reUsedEntities(), isBarGraph: isBarGraph)
            } else if templateTyp == .yesOrNo {
                YesNoDateProvider(dataEntities: reUsedEntities())
            } else if templateTyp == .options {
                OptionDateProvider(dataEntities: reUsedEntities(),
                                   template: templateGroups[indexes[0]][indexes[1]])
            }
        }
        .onAppear {
            UIApplication.shared.endEditing()
        }
    }
    
    var templateTyp: DataEntrieTyp {
        templateGroups[indexes[0]][indexes[1]].dataEntrieTyp
    }
    
    func reUsedEntities() -> [OneDataEntitiy] {
        let sortedEntities = sortDates(usedDataEntities: self.dataEntities)
        
        var usedDataEntities: [OneDataEntitiy] = []
        for entity in sortedEntities {
            if entity.indexRelatedTemplate == indexes {
                usedDataEntities.append(entity)
            }
        }
        return usedDataEntities
    }
}

struct QuantityDataProvider: View {
    let dataEntities: [OneDataEntitiy]
    
    @State private var selected: TimeFrame = .week
    @State private var referenceDate: Date = Date()
    
    let isBarGraph: Bool
    var body: some View {
        if dataEntities.count != 0 && allNotNull {
            VStack(spacing: 5) {
                if isBarGraph {
                    BarGraph(values: reData().0, usePerc: false)
                } else {
                    LineGraph(values: reData().0, usePerc: false)
                }
                GraphLabels(labals: reData().1, deph: deph, alternateColor: true)
                SelectForDataProv(selected: $selected, referenceDate: $referenceDate,
                                  dataEntities: dataEntities, useTimeFramePicker: true)
                Spacer()
            }
            .onChange(of: selected, perform: { newValue in
                referenceDate = Date()
            })
        } else {
            Text("No Value For Graph")
                .font(.largeTitle)
        }
    }
    
    var allNotNull: Bool {
        for entity in dataEntities {
            let value = AchiveRectQuantity.reDouble(entity.stringState)
            if  value != 0 {
                return true
            }
        }
        return false
    }
    
    var deph: Int {
        switch selected {
            case .month:
                return 2
            case .week:
                return 1
            case .year:
                return 2
        }
    }
    
    func reData() -> ([Double], [String]) {
        if selected == .week {
            return reWeek()
        } else if selected == .month {
            return reMonth()
        } else if selected == .year {
            return reYear()
        }
        
        return ([-1], [""])
    }
    
    func reWeek() -> ([Double], [String]) {
        var daysInWeek: [(day: Int, value: Double)] = []
        for entity in dataEntities {
            if reCal().isDate(referenceDate, equalTo: entity.date,
                                               toGranularity: .weekOfYear) {
                let components = reCal().dateComponents([.weekday], from: entity.date)
                let dayOfWeek = components.weekday!
                daysInWeek.append((day: dayOfWeek, value: AchiveRectQuantity.reDouble(entity.stringState)))
            }
        }
        
        var reValues: [Double] = []
        var reLabels: [String] = []
        
        for day in 1...7 {
            var value: Double = 0
            var count: Double = 0
            for dayInWeek in daysInWeek {
                if dayInWeek.day == day {
                    value += dayInWeek.value
                    count += 1
                }
            }
            let finalValue = count == 0 ? 0 : (value / count)
            reValues.append(finalValue)
            reLabels.append(ThirdRow.reDaysString([day]))
        }
        
        return (reValues, reLabels)
    }
    
    func reMonth() -> ([Double], [String]) {
        var daysInMonth: [(day: Int, value: Double)] = []
        for entity in dataEntities {
            if reCal().isDate(referenceDate, equalTo: entity.date,
                                       toGranularity: .month) {
                let components = reCal().dateComponents([.day], from: entity.date)
                let dayOfMonth = components.day!
                daysInMonth.append((day: dayOfMonth, value: AchiveRectQuantity.reDouble(entity.stringState)))
            }
        }
        
        var reValues: [Double] = []
        var reLabels: [String] = []
        
        let rangeMonth = reCal().range(of: .day, in: .month, for: referenceDate)!
        
        for day in rangeMonth {
            var value: Double = 0
            var count: Double = 0
            for dayInMonth in daysInMonth {
                if dayInMonth.day == day {
                    value += dayInMonth.value
                    count += 1
                }
            }
            let finalValue = count == 0 ? 0 : (value / count)
            reValues.append(finalValue)
            reLabels.append(String(day))
        }
        
        return (reValues, reLabels)
    }
    
    func reYear() -> ([Double], [String]) {
        var monthsInYear: [(month: Int, value: Double)] = []
        
        var allMonthDates: [Date] = []
        for month in 1...12 {
            let components = reCal().dateComponents([.year], from: referenceDate)
            let year = components.year!
            
            var dateComponents = DateComponents()
            dateComponents.month = month
            dateComponents.year = year
            
            let dateInMonth = reCal().date(from: dateComponents)!

            allMonthDates.append(dateInMonth)
            for (_, entity) in dataEntities.enumerated() {
                if reCal().isDate(dateInMonth, equalTo: entity.date,
                                           toGranularity: .month) {
                    monthsInYear.append((month: month, value: AchiveRectQuantity.reDouble(entity.stringState)))
                }
            }
        }
        
        var reValues: [Double] = []
        var reLabels: [String] = []
    
        for month in 1...12 {
            var value: Double = 0
            var count: Double = 0
            for dayInMonth in monthsInYear {
                if dayInMonth.month == month {
                    value += dayInMonth.value
                    count += 1
                }
            }
            let finalValue = count == 0 ? 0 : (value / count)
            reValues.append(finalValue)
            reLabels.append(QuantityDataProvider.reMonthString(month))
        }
        
        return (reValues, reLabels)
    }
    
    static func reMonthString(_ month: Int) -> String {
        switch month {
            case 1:
                return "Jan"
            case 2:
                return "Feb"
            case 3:
                return "Mar"
            case 4:
                return "Apr"
            case 5:
                return "May"
            case 6:
                return "Jun"
            case 7:
                return "Jul"
            case 8:
                return "Aug"
            case 9:
                return "Sep"
            case 10:
                return "Oct"
            case 11:
                return "Nov"
            case 12:
                return "Dec"
            default:
                return "Wrong Date"
        }
    }
}

enum TimeFrame {
    case week, month, year
}

struct LeftRightAction: View {
    let action: (Bool) -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: {action(true)}, label: {
                Image(systemName: "chevron.left.square.fill")
                    .font(.system(size: PercSize.width(10)))
                    .foregroundColor(.black)
            })
            Button(action: {action(false)}, label: {
                Image(systemName: "chevron.right.square.fill")
                    .font(.system(size: PercSize.width(10)))
                    .foregroundColor(.black)
            })
        }
    }
}

struct SelectForDataProv: View {
    @Binding var selected: TimeFrame
    @Binding var referenceDate: Date
    let dataEntities: [OneDataEntitiy]

    let useTimeFramePicker: Bool
    
    var body: some View {
        VStack(spacing: 10){
            if useTimeFramePicker {
                timeFramePicker
            }
            changeReferenceDate
            if isCurrentTimeFrame {
                startDateView
            } else {
                Text(currentTimeFrame)
            }
        }

    }
    
    var isCurrentTimeFrame: Bool {
        let nowDate = Date()
        if !reCal().isDate(nowDate, equalTo: referenceDate,
                                           toGranularity: .weekOfYear) && selected == .week {
            return true
        } else if !reCal().isDate(nowDate, equalTo: referenceDate,
                                           toGranularity: .month) && selected == .month {
            return true
        } else if !reCal().isDate(nowDate, equalTo: referenceDate,
                                           toGranularity: .year) && selected == .year {
            return true
        }
        return false
    }
    
    var currentTimeFrame: String {
        switch selected {
            case .week:
                return "Current Week"
            case .month:
                return "Current Month"
            case .year:
                return "Current Year"
        }
    }
    
    var startDateView: some View {
        Text("Start: \(dateFormatterFun().string(from: startDate))")
    }

    var changeReferenceDate: some View {
        LeftRightAction(action: setDateAction)
    }
    
    func setDateAction(later: Bool) {
        if later {
            if !noValueInDir(earlier: !later) {
                setDate(later: true)
            }
        } else {
            if !noValueInDir(earlier: !later) {
                setDate(later: false)
            }
        }
    }
    
    var timeFramePicker: some View {
        Picker(selection: $selected, label: Text(""), content: {
            Text("week").tag(TimeFrame.week)
            Text("month").tag(TimeFrame.month)
            Text("year").tag(TimeFrame.year)
        })
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: PercSize.width(100) - 30)
    }
    
    var startDate: Date {
        var components = DateComponents()

        let yearFetch = reCal().dateComponents([.year], from: referenceDate)
        let year = yearFetch.year!
        
        let day = reCal().ordinality(of: .day, in: .year, for: referenceDate)!
        
        components.hour = 0
        components.minute = 1
        components.year = year
        switch selected {
            case .week:
                let dayFetch = reCal().dateComponents([.weekday], from: referenceDate)
                let dayOfWeek = dayFetch.weekday!
                
                components.day = day - (dayOfWeek - 1)
            case .month:
                let dayFetch = reCal().dateComponents([.day], from: referenceDate)
                let dayOfMonth = dayFetch.day!
                components.day = day - (dayOfMonth - 1)
            case .year:
                components.day = 1
        }
        return reCal().date(from: components)!
    }
    
    var endDate: Date {
        var components = DateComponents()
        
        let yearFetch = reCal().dateComponents([.year], from: referenceDate)
        let year = yearFetch.year!
        
        let day = reCal().ordinality(of: .day, in: .year, for: referenceDate)!
        
        components.year = year
        components.hour = 23
        components.minute = 59
        switch selected {
            case .week:
                let dayFetch = reCal().dateComponents([.weekday], from: referenceDate)
                let dayOfWeek = dayFetch.weekday!
                components.day = day + (7 - dayOfWeek)
            case .month:
                let monthLength = reCal().range(of: .day, in: .month, for: referenceDate)?.count

                let dayFetch = reCal().dateComponents([.day], from: referenceDate)
                let dayOfMonth = dayFetch.day!
                
                components.day = day + (monthLength! - dayOfMonth)
            case .year:
                let isLeap = reCal().range(of: .day, in: .year, for: referenceDate)!.count == 366

                components.day = isLeap ? 366 : 365
        }
        
        return reCal().date(from: components)!
    }
    
    func noValueInDir(earlier: Bool) -> Bool {
        if earlier {
            for entitiy in dataEntities {
                if entitiy.date > endDate {
                    return false
                }
            }
        } else {
            for entitiy in dataEntities {
                if entitiy.date < startDate {
                    return false
                }
            }
        }
        return true
    }
    
    func setDate(later: Bool) {
        var components = DateComponents()
        
        let day = reCal().ordinality(of: .day, in: .year, for: referenceDate)!
        
        let monthFetch = reCal().dateComponents([.month], from: referenceDate)
        let month = monthFetch.month!
        
        let yearFetch = reCal().dateComponents([.year], from: referenceDate)
        let year = yearFetch.year!

        let hour = reCal().component(.hour, from: Date())
        let minute = reCal().component(.minute, from: Date())

        let minusOrPlus: Int
        if later {
            minusOrPlus = -1
        } else {
            minusOrPlus = 1
        }
        
        var resultYear = year
        var resultMonth = month
        var resultDay = day
        
        switch selected {
            case .week:
                resultDay += 7 * minusOrPlus
            case .month:
                resultMonth += minusOrPlus
            case .year:
                resultYear += minusOrPlus
        }
        
        components.year = resultYear
        components.hour = hour
        components.minute = minute
        
        if selected == .month {
            components.month = resultMonth
        } else {
            components.day = resultDay
        }
        referenceDate = reCal().date(from: components)!
    }
}

struct YesNoDateProvider: View {
    let dataEntities: [OneDataEntitiy]
    
    @State private var referenceDate: Date = Date()
    @State private var selected: TimeFrame = .year
    @State private var yesPerc: Bool = true
    
    var body: some View {
        if dataEntities.count != 0 {
            VStack(spacing: 5) {
                BarGraph(values: reYear().0, usePerc: yesPerc ? true : false)
                GraphLabels(labals: reYear().1, deph: 2, alternateColor: true)
                SelectForDataProv(selected: $selected, referenceDate: $referenceDate,
                                  dataEntities: dataEntities, useTimeFramePicker: false)
                selectPercOrCount(yesPerc: $yesPerc, text: "Yes: ")
                Spacer()
            }
        } else {
            Text("No Value For Bar Graph")
                .font(.largeTitle)
        }
    }
    
    func reYear() -> ([Double], [String]) {
        var monthsInYear: [(month: Int, value: Bool)] = []
        
        var allMonthDates: [Date] = []
        for month in 1...12 {
            let components = reCal().dateComponents([.year], from: referenceDate)
            let year = components.year!
            
            var dateComponents = DateComponents()
            dateComponents.month = month
            dateComponents.year = year
            
            let dateInMonth = reCal().date(from: dateComponents)!

            allMonthDates.append(dateInMonth)
            for (_, entity) in dataEntities.enumerated() {
                if reCal().isDate(dateInMonth, equalTo: entity.date,
                                           toGranularity: .month) {
                    monthsInYear.append((month: month, value: entity.boolState))
                }
            }
        }
        
        var reValues: [Double] = []
        var reLabels: [String] = []
    
        for month in 1...12 {
            var value: Int = 0
            var count: Int = 0
            for dayInMonth in monthsInYear {
                if dayInMonth.month == month {
                    value += dayInMonth.value ? 1 : 0
                    count += 1
                }
            }
            let finalValue: Int
            if yesPerc {
                finalValue = count == 0 ? 0 : (value * 100 / count)
            } else {
                finalValue = count - (count - value)
            }
            reValues.append(Double(finalValue))
            reLabels.append(QuantityDataProvider.reMonthString(month))
        }
        
        return (reValues, reLabels)
    }
}

struct selectPercOrCount: View {
    @Binding var yesPerc: Bool
    let text: String
    var body: some View {
        HStack {
            Text(text)
            Picker(selection: $yesPerc, label: Text(""), content: {
                Text("perentage").tag(true)
                Text("count").tag(false)
            })
            .pickerStyle(SegmentedPickerStyle())
        }
        .frame(width: PercSize.width(100) - 30)
        .padding(.top, 5)
    }
}

struct OptionDateProvider: View {
    let dataEntities: [OneDataEntitiy]
    let template: OneEntrieData
    @State private var yesPerc: Bool = true
    
    @State private var optionGroups: [[String]] = []
    @State private var groupIndex: Int = 0
    
    var body: some View {
        if dataEntities.count != 0 {
            VStack(spacing: 5) {
                BarGraph(values: reData().0, usePerc: yesPerc ? true : false)
                GraphLabels(labals: reData().1, deph: deph, alternateColor: true)
                LeftRightAction(action: changeOptionGroupIndex)
                selectPercOrCount(yesPerc: $yesPerc, text: "")
                Spacer()
            }
            .onAppear(perform: initOptionGroups)
        } else {
            Text("No Value For Bar Graph")
                .font(.largeTitle)
        }
    }

    var deph: Int {
        guard optionGroups.count > 0 else {
            return 0
        }
        return optionGroups[groupIndex].count <= 2 ? 1 : 2
    }
    
    func reData() -> ([Double], [String]) {
        guard optionGroups.count > 0 else {
            return ([], [])
        }
        let options = optionGroups[groupIndex]
        
        var reValues: [Double] = []
        var reLabels: [String] = []
        
        for option in options {
            var count = 0
            for entity in dataEntities {
                if entity.stringState == option {
                    count += 1
                }
            }
            
            let finalValue: Int
            if yesPerc {
                finalValue = count == 0 ? 0 : (count * 100 / dataEntities.count)
            } else {
                finalValue = count
            }
            reValues.append(Double(finalValue))
            reLabels.append(option)
        }
        
        return (reValues, reLabels)
    }
    
    func initOptionGroups() {
        var count = 0
        optionGroups.append([])
        for option in template.options {
            if count == 4 {
                optionGroups.append([])
                count = 0
            }
            optionGroups[optionGroups.count - 1].append(option)
            count += 1
        }
    }
    
    func changeOptionGroupIndex(minus: Bool) {
        if minus && groupIndex - 1 >= 0 {
            groupIndex -= 1
        } else if !minus && groupIndex + 2 <= optionGroups.count {
            groupIndex += 1
        }
    }
}
