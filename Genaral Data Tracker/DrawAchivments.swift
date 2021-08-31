//
//  DrawAchivements.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 20.07.21.
//

import SwiftUI
import Combine

struct DrawAchivements: View {
    let indexes: [Int]
    let dataEntities: [OneDataEntitiy]
    @Binding var template: OneEntrieData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if template.dataEntrieTyp == .quantity {
                AchiveRectQuantity(dataEntities: reUsedEntities(), template: $template)
            } else if template.dataEntrieTyp == .yesOrNo {
                AchiveRectYesNo(dataEntities: reUsedEntities())
            } else if template.dataEntrieTyp == .options {
                AchiveRectOptions(dataEntities: reUsedEntities(), template: $template)
            }
            Spacer()
        }
        .onAppear {
            UIApplication.shared.endEditing()
        }
    }
    
    func reUsedEntities() -> [OneDataEntitiy] {
        var reEntites: [OneDataEntitiy] = []
        
        for dataEntitie in dataEntities {
            if dataEntitie.indexRelatedTemplate == indexes {
                reEntites.append(dataEntitie)
            }
        }
        
        return reEntites
    }
    
    static func reFont(stringNum: String) -> Font {
        let stringLength = stringNum.count
        var minus = stringNum.contains("%") ? 2 : 1
        if stringNum.contains(".") {
            minus = 0
        }
        
        if stringLength > 8 - minus {
            return Font.title3
        } else if stringLength > 7 - minus {
            return Font.title2
        } else {
            return Font.title
        }
    }
    
    static func reIntOrDouble(numberPar: Double, oneFloatNum: Bool = false) -> String {
        let plusNum = numberPar < 0 ? numberPar * -1 : numberPar
        let isDouble = plusNum > Double(Int(plusNum))
        if oneFloatNum {
            return  isDouble ? String(format: "%.1f", numberPar) : String(Int(numberPar))
        }
        return isDouble ? String(numberPar) : String(Int(numberPar))
    }
}

extension View {
    func achivRect() -> some View {
        return self
            .frame(width: PercSize.width(30), height: PercSize.width(30), alignment: .center)
            .background(Color.orange)
            .padding(.top, PercSize.width(2.5))
    }
}

struct AchiveRectQuantity: View {
    let dataEntities: [OneDataEntitiy]
    @Binding var template: OneEntrieData
    
    @State private var higherIsBetter: Bool = false
    @State var goal: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                FirstRow(dataEntities: dataEntities, template: template, higherIsBetter: $higherIsBetter)
                SecondRow(dataEntities: dataEntities, template: template, higherIsBetter: $higherIsBetter)
                ThirdRow(dataEntities: dataEntities)
                fourthRow(dataEntities: dataEntities, template: template,
                          higherIsBetter: $higherIsBetter, goalVar: $goal)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            EnterOpitons(dataEntities: dataEntities, template: $template,
                         higherIsBetter: $higherIsBetter, goalVar: $goal)
        }
    }
    
    static func calcHighest(dataEntities: [OneDataEntitiy]) -> (String, Int) {
        if dataEntities.count == 0 {
            return ("No Value", -1)
        }
        var highest: Double = -1
        var reIndex = -1
        for (index, dataEntitie) in dataEntities.enumerated() {
            let maybeHighest = AchiveRectQuantity.reDouble(dataEntitie.stringState)
            if maybeHighest > highest {
                highest = maybeHighest
                reIndex = index
            }
        }
        return (DrawAchivements.reIntOrDouble(numberPar: highest), reIndex)
    }
    
    static func calcLowest(dataEntities: [OneDataEntitiy]) -> (String, Int) {
        if dataEntities.count == 0 {
            return ("No Value", -1)
        }
        var lowest = 100000000.0
        var reIndex = -1
        for (index, dataEntitie) in dataEntities.enumerated() {
            let maybeLowest = AchiveRectQuantity.reDouble(dataEntitie.stringState)
            if maybeLowest < lowest {
                lowest = maybeLowest
                reIndex = index
            }
        }
        return (DrawAchivements.reIntOrDouble(numberPar: lowest), reIndex)
    }
    
    static func reDouble(_ numString: String) -> Double {
        let withoutComma = numString.replacingOccurrences(of: ",", with: ".")
        return Double(withoutComma) ?? 0
    }
}

struct FirstRow: View {
    let dataEntities: [OneDataEntitiy]
    let template: OneEntrieData

    @Binding var higherIsBetter: Bool

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            highestRating
            Spacer()
            lowestRating
            Spacer()
            improvementStartToEndPerc
            Spacer()
        }
    }
    
    var improvementStartToEndPerc: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(calcImproveSinceStartPerc() + "%")
                .font(DrawAchivements.reFont(stringNum: calcImproveSinceStartPerc() + "%"))
            Text("Improvement Since Start")
                .multilineTextAlignment(.center)
            dateText()
        }
        .achivRect()
    }
    
    var highestRating: some View {
        VStack(alignment: .center, spacing: 7) {
            Text(AchiveRectQuantity.calcHighest(dataEntities: dataEntities).0)
                .font(DrawAchivements.reFont(stringNum: AchiveRectQuantity.calcHighest(dataEntities: dataEntities).0))
            Text("Highest Value")
            dateText(AchiveRectQuantity.calcHighest(dataEntities: dataEntities).1)
        }
        .achivRect()
    }
    
    var lowestRating: some View {
        VStack(alignment: .center, spacing: 7) {
            Text(AchiveRectQuantity.calcLowest(dataEntities: dataEntities).0)
                .font(DrawAchivements.reFont(stringNum: AchiveRectQuantity.calcLowest(dataEntities: dataEntities).0))
            Text("Lowest Value")
            dateText(AchiveRectQuantity.calcLowest(dataEntities: dataEntities).1)
        }
        .achivRect()
    }
    
    func dateText(_ index: Int = 0) -> some View {
        if index == -1 || index > dataEntities.count - 1 {
            return Text("No Date")
        }
        return Text("\(dataEntities[index].date, formatter: dateFormatterFun())")
    }
    
    func calcImproveSinceStartPerc() -> String {
        if dataEntities.count == 0 {
            return ""
        }
        let sortedAsDates = sortDates(usedDataEntities: dataEntities)
        
        let endValue = AchiveRectQuantity.reDouble(sortedAsDates[0].stringState)
        let startValue = AchiveRectQuantity.reDouble(
                            sortedAsDates[sortedAsDates.count - 1].stringState)
        
        if endValue == 0 || startValue == 0 {
            return ""
        }
        let currentIs100 = Int(startValue / endValue * 100)
        let startValueIs100 = Int(endValue / startValue * 100)
        
        if self.higherIsBetter || endValue == startValue {
            return String(startValueIs100)
        } else {
            return String(currentIs100)
        }
    }
}

struct SecondRow: View {
    let dataEntities: [OneDataEntitiy]
    let template: OneEntrieData

    @Binding var higherIsBetter: Bool

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            highestInDay
            Spacer()
            highestInWeek
            Spacer()
            highestInMonth
            Spacer()
        }
    }
    
    var highestInDay: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reHighest(.today))
                .font(DrawAchivements.reFont(stringNum: reHighest(.today)))
            Text("Best From Today")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var highestInWeek: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reHighest(.week))
                .font(DrawAchivements.reFont(stringNum: reHighest(.week)))
            Text("Best From Week")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var highestInMonth: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reHighest(.month))
                .font(DrawAchivements.reFont(stringNum: reHighest(.month)))
            Text("Best From Month")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    func reHighest(_ fromTimeFrame: FromTimeFrame) -> String {
        var usedDateEntities: [OneDataEntitiy] = []
        for dataEntity in dataEntities {
            let nowDate = Date()
            if !reCal().isDateInToday(dataEntity.date) && fromTimeFrame == .today {
                continue
            } else if !reCal().isDate(nowDate, equalTo: dataEntity.date,
                                               toGranularity: .weekOfYear) && fromTimeFrame == .week {
                continue
            } else if !reCal().isDate(nowDate, equalTo: dataEntity.date,
                                               toGranularity: .month) && fromTimeFrame == .month {
                continue
            }
            usedDateEntities.append(dataEntity)
        }
        usedDateEntities = sortDates(usedDataEntities: usedDateEntities)
        
        if usedDateEntities.count == 0 {
            return "No Value"
        }
        
        if !higherIsBetter {
            return AchiveRectQuantity.calcLowest(dataEntities: usedDateEntities).0
        } else {
            return AchiveRectQuantity.calcHighest(dataEntities: usedDateEntities).0
        }
    }
    
    enum FromTimeFrame {
        case today, week, month
    }
}

struct ThirdRow: View {
    let dataEntities: [OneDataEntitiy]

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            entrieCount
            Spacer()
            average
            Spacer()
            bestStreak
            Spacer()
        }
    }
    
    var entrieCount: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reEntrieCount())
                .font(DrawAchivements.reFont(stringNum: reEntrieCount()))
            Text("Overall Entries Count")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var average: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reAverage())
                .font(DrawAchivements.reFont(stringNum: reAverage()))
            Text("Overall Average")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var bestStreak: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reBestStreak())
                .multilineTextAlignment(.center)
            Text("Best Streak")
        }
        .achivRect()
    }
    
    func reBestStreak() -> String {
        let checkWeeklyResult = checkWeeklyStreak()
        let weeklyStreakSize = (checkWeeklyResult.count + 1) * checkWeeklyResult.days.count
        
        let checkPeriodicResult = checkPeriodicStreak()
        
        if checkPeriodicResult.count >= weeklyStreakSize && checkPeriodicResult.count != 0 {
            let daysStrings = checkPeriodicResult.length == 1 ? "day" : "\(checkPeriodicResult.length) days"
            return "\(checkPeriodicResult.count) times every \(daysStrings)"
        } else if weeklyStreakSize != 0 {
            return "\(checkWeeklyResult.count + 1) weeks every \(ThirdRow.reDaysString(checkWeeklyResult.days))"
        }
        return "No Value"
    }
    
    static func reDaysString(_ days: [Int]) -> String {
        let reverseDays = days.reversed()
        var daysString = ""
        for day in reverseDays {
            if daysString != "" {
                daysString += ", "
            }
            switch day {
            case 1:
                daysString += "Sun"
            case 2:
                daysString += "Mon"
            case 3:
                daysString += "Tue"
            case 4:
                daysString += "Wed"
            case 5:
                daysString += "Thu"
            case 6:
                daysString += "Fri"
            case 7:
                daysString += "Sat"
            default:
                daysString = ""
            }
        }
        return daysString
    }
    
    static func clearSameDay(_ daysFromStart: [Int], _ sortedEntries: inout [OneDataEntitiy]) -> [Int] {
        var reArray: [Int] = []
        var previousDay = -1
        var afterEqual = false
        var deleteCount = 0
        for (index, dayFromStart) in daysFromStart.enumerated() {
            if afterEqual && previousDay == dayFromStart {
                sortedEntries.remove(at: index - deleteCount)
                deleteCount += 1
                continue
            }

            afterEqual = false
            reArray.append(dayFromStart)
            previousDay = dayFromStart
            
            if daysFromStart.count < index + 2 {
                break
            }
            if dayFromStart == daysFromStart[index + 1] {
                afterEqual = true
            }
        }
        return reArray
    }
    
    func checkWeeklyStreak() ->  (count: Int, days: [Int]) {
        var sortedEntries = sortDates(usedDataEntities: dataEntities)
        let daysFromStart: [Int] = ThirdRow.clearSameDay(
            ThirdRow.reDaysFromStart(dataEntitiesPar: sortedEntries), &sortedEntries)

        var previousDate: Date = Date()
        var firstDate = true
        
        var sameWeekGroups: [[Int]] = []
        var dayCountGroups: [[Int]] = []
        
        for (index, dataEntity) in sortedEntries.enumerated()  {
            if firstDate {
                firstDate = false
                previousDate = dataEntity.date
                
                sameWeekGroups.append([])
                dayCountGroups.append([])
                continue
            }
            
            if reCal().isDate(previousDate, equalTo: dataEntity.date,
                                       toGranularity: .weekOfYear) {
                
                if sameWeekGroups[sameWeekGroups.count - 1].count == 0 {
                    let day = reCal().component(.weekday, from: previousDate)
                    sameWeekGroups[sameWeekGroups.count - 1].append(day)
                    dayCountGroups[dayCountGroups.count - 1].append(daysFromStart[index - 1])
                }
                
                let day = reCal().component(.weekday, from: dataEntity.date)
                sameWeekGroups[sameWeekGroups.count - 1].append(day)
                dayCountGroups[dayCountGroups.count - 1].append(daysFromStart[index])
            } else {
                sameWeekGroups.append([])
                dayCountGroups.append([])
            }
            previousDate = dataEntity.date
        }
        
        var streaks: [(Int, [Int])] = []
        var lastWeek: [Int] = []
        for (index, week) in sameWeekGroups.enumerated() {
            if lastWeek.count == 0 {
                lastWeek = week
                streaks.append((0, []))
                continue
            }
            
            if lastWeek == week && dayCountGroups[index][0] + 7 == dayCountGroups[index - 1][0] {
                let lastIndex = streaks.count - 1
                streaks[lastIndex] = (streaks[lastIndex].0 + 1, week)
            } else {
                streaks.append((0, []))
            }
            
            lastWeek = week
        }
        
        var bestStreak: (Int, [Int]) = (0, [])
        
        for streak in streaks {
            if streak.0 > bestStreak.0 {
                bestStreak = streak
            }
        }
        
        return bestStreak
    }
    
    static func reDaysFromStart(dataEntitiesPar: [OneDataEntitiy]) -> [Int] {
        var daysFromStart: [Int] = []
        
        var latestYear = 9000
        
        var isLeapYear: [Bool] = []
        
        for dataEntity in dataEntitiesPar {
            let components = reCal().dateComponents([.year], from: dataEntity.date)
            let year = components.year!
            if latestYear > year {
                latestYear = year
                
                if reCal().range(of: .day, in: .year, for: dataEntity.date)!.count == 366 {
                    isLeapYear.append(true)
                } else {
                    isLeapYear.append(false)
                }
            }
        }
        
        for dataEntity in dataEntitiesPar {
            if let day = reCal().ordinality(of: .day, in: .year, for: dataEntity.date) {
                let components = reCal().dateComponents([.year], from: dataEntity.date)
                let year = components.year!
                
                var dayFromStart = day
                for index in 0..<(year - latestYear) {
                    if isLeapYear[isLeapYear.count - 1 - index] {
                        dayFromStart += 366
                    } else {
                        dayFromStart += 365
                    }
                }
                daysFromStart.append(dayFromStart)
            }
        }
        
        return daysFromStart
    }
    
    static func reDifferenceBetweenDays(daysFromStart: [Int]) -> [Int] {
        var differenceBetweenDays: [Int] = []
        for (index, dayFromStart) in daysFromStart.enumerated() {
            if daysFromStart.count < index + 2 {
                break
            }
            differenceBetweenDays.append(dayFromStart - daysFromStart[index + 1])
        }
        return differenceBetweenDays
    }
    
    func checkPeriodicStreak() -> (count: Int, length: Int) {
        if dataEntities.count < 2 {
            return (count: 0, length: 0)
        }

        var sortedEntries = sortDates(usedDataEntities: dataEntities)
        let daysFromStart: [Int] = ThirdRow.clearSameDay(
            ThirdRow.reDaysFromStart(dataEntitiesPar: sortedEntries), &sortedEntries)
        
        let differenceBetweenDays = ThirdRow.reDifferenceBetweenDays(daysFromStart: daysFromStart)
        
        var streaks: [(count: Int, length: Int)] = [(count: 2, length: 0)]
        var lastDifference = -1
        for differenceBetweenDay in differenceBetweenDays {
            if lastDifference == -1 {
                lastDifference = differenceBetweenDay
                continue
            }
            if lastDifference == differenceBetweenDay {
                let latestIndex = streaks.count - 1
                streaks[latestIndex].count += 1
                streaks[latestIndex].length = differenceBetweenDay
            } else {
                streaks.append((count: 2, length: 0))
            }
            lastDifference = differenceBetweenDay
        }
        
        var bestStreak: (count: Int, length: Int) = (count: 0, length: 0)
        for streak in streaks {
            if streak.count > bestStreak.count &&  streak.length != 0 {
                bestStreak = streak
            }
        }

        return bestStreak
    }
    
    func reEntrieCount() -> String {
        return String(dataEntities.count)
    }
    
    func reAverage() -> String {
        if dataEntities.count == 0 {
            return "No Value"
        }
        var allTogether: Double = 0.0
        for dataEntity in dataEntities {
            allTogether += AchiveRectQuantity.reDouble(dataEntity.stringState)
        }
        
        return DrawAchivements.reIntOrDouble(numberPar: allTogether /
                                                Double(dataEntities.count), oneFloatNum: true)
    }
}

struct fourthRow: View {
    let dataEntities: [OneDataEntitiy]
    let template: OneEntrieData

    @Binding var higherIsBetter: Bool
    @Binding var goalVar: String
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            currentStreak
            Spacer()
            avgGrowth
            Spacer()
            pointsToReachGoal
            Spacer()
        }
    }
    
    var pointsToReachGoal: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(rePointsToReachGoal())
                .font(DrawAchivements.reFont(stringNum: rePointsToReachGoal()))
            Text("More To Reach Your Goal")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var avgGrowth: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reAverageGrowth() + "%")
                .font(DrawAchivements.reFont(stringNum: reAverageGrowth() + "%"))
            Text("Average Growth")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var currentStreak: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reCurrentStreak())
                .multilineTextAlignment(.center)
            Text("Current Streak")
        }
        .achivRect()
    }
    
    func rePointsToReachGoal() -> String {
        if goalVar == "" || dataEntities.count == 0 {
            return "No Value"
        }
        
        let latestEntity = AchiveRectQuantity.reDouble(dataEntities[dataEntities.count - 1].stringState)
        let num = BarGraph.discacrdTooLongFloat(AchiveRectQuantity.reDouble(goalVar) - latestEntity)
        let stringNum = DrawAchivements.reIntOrDouble(numberPar: num)
        return stringNum
    }
    
    func reAverageGrowth() -> String {
        if dataEntities.count < 2 {
            return ""
        }
        var sortedEntries = sortDates(usedDataEntities: dataEntities)
        
        if self.higherIsBetter {
            sortedEntries.reverse()
        }
        
        var allPercentages: Int = 0
        var previousValue: Double = -1
        for dataEntity in sortedEntries {
            let currentValue = AchiveRectQuantity.reDouble(dataEntity.stringState)
            if previousValue == -1 {
                previousValue = currentValue
                continue
            }
            
            if currentValue == 0 || previousValue == 0 {
                continue
            }
            
            allPercentages += Int(currentValue / previousValue * 100)
        
            previousValue = currentValue
        }
        
        return "\(allPercentages / (sortedEntries.count - 1))"
    }
    
    func reCurrentStreak() -> String {
        var sortedEntries = sortDates(usedDataEntities: dataEntities)
        let daysFromStart: [Int] = ThirdRow.clearSameDay(
            ThirdRow.reDaysFromStart(dataEntitiesPar: sortedEntries), &sortedEntries)

        let differenceBetweenDays = ThirdRow.reDifferenceBetweenDays(daysFromStart: daysFromStart)

        var periodicStreakCount: (Int, Int) = (2, 0)
        var previousDifference = -1
        for currentDifference in differenceBetweenDays {
            if previousDifference == -1 {
                previousDifference = currentDifference
                continue
            }
            
            if currentDifference == previousDifference {
                periodicStreakCount.0 += 1
                periodicStreakCount.1 = currentDifference
            } else {
                break
            }
            previousDifference = currentDifference
        }
        
        var weeks: [([Int], [Int])] = []
        
        var previousDate = Date()
        var firstWeek = true
        for (index, dataEntity) in sortedEntries.enumerated() {
            if firstWeek {
                firstWeek = false
                previousDate = dataEntity.date
                weeks.append(([], []))
                continue
            }
            
            if reCal().isDate(previousDate, equalTo: dataEntity.date,
                                       toGranularity: .weekOfYear) {
                if weeks[weeks.count - 1].0.count == 0 {
                    let day = reCal().component(.weekday, from: previousDate)
                    weeks[weeks.count - 1].0.append(day)
                    weeks[weeks.count - 1].1.append(daysFromStart[index - 1])
                }
                let day = reCal().component(.weekday, from: dataEntity.date)
                weeks[weeks.count - 1].0.append(day)
                weeks[weeks.count - 1].1.append(daysFromStart[index])
            } else {
                weeks.append(([], []))
            }
            previousDate = dataEntity.date
        }
    
        var weeklyStreakCount: (Int, [Int]) = (0, [])
        
        var previousFirstWeek = true
        var previousWeek: ([Int], [Int]) = ([], [])
        breakCompletly: for week in weeks {
            if previousWeek.0.count == 0 {
                previousWeek = week
                continue
            }
            
            if previousFirstWeek && previousWeek.0 != week.0 {
                for (index, _) in week.0.enumerated() {
                    if !previousWeek.0.indices.contains(index) {
                        break
                    } else if previousWeek.1[index] + 7 != week.1[index] {
                        break breakCompletly
                    }
                }
                previousFirstWeek = false
                previousWeek = week
                continue
            }
            
            if previousWeek.0 == week.0 && previousWeek.1[0] - 7 == week.1[0] {
                weeklyStreakCount.0 += 1
                weeklyStreakCount.1 = week.0
            } else {
                break breakCompletly
            }
            
            previousWeek = week
        }
        
        let periodicStreakSize = periodicStreakCount.1 != 0 ? periodicStreakCount.1 + 2 : 0
        let weeklyStreakSize = (weeklyStreakCount.0 + 1) * weeklyStreakCount.1.count
        if periodicStreakSize >= weeklyStreakSize && periodicStreakSize != 0 {
            let daysStrings = periodicStreakCount.1 == 1 ? "day" : "\(periodicStreakCount.1) days"
            return "\(periodicStreakCount.0) times every \(daysStrings)"
        } else if weeklyStreakCount.0 != 0 {
            return "\(weeklyStreakCount.0 + 1) weeks every \(ThirdRow.reDaysString(weeklyStreakCount.1))"
        }
        return "No Value"
    }
}

struct EnterOpitons: View {
    let dataEntities: [OneDataEntitiy]
    @Binding var template: OneEntrieData
    
    @Binding var higherIsBetter: Bool
    @Binding var goalVar: String

    @State private var timeAfterInit = Date()
    @State private var userSet: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                higherIsBetterView
                Spacer()
                goal
            }
            .frame(width: PercSize.width(95), height: PercSize.width(15), alignment: .center)
            .background(Color(red: 204 / 255, green: 104 / 255, blue: 10 / 255))
            .padding(.top, PercSize.width(2.5))
            Spacer()
        }
        .onAppear(perform: initHigherBetter)
        .onDisappear(perform: initForDissapear)
        .onChange(of: higherIsBetter, perform: { newValue in
            setUserSet(newValue: newValue)
        })
    }
    
    var higherIsBetterView: some View {
        HStack {
            Text("Higher is better:")
            Toggle(isOn: $higherIsBetter, label: {})
                .labelsHidden()
        }
        .padding(.leading, 5)
    }
    
    var goal: some View {
        HStack {
            Text("Goal:")
            TextField("Goal", text: $goalVar, onEditingChanged: { (_) in }, onCommit: {})
                .frame(width: PercSize.width(20))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onReceive(Just(goalVar)) { newValue in
                    filter(newValue: newValue)
                }
        }
        .padding(.trailing, 5)
    }
    
    func initForDissapear() {
        if goalVar != "" {
            template.goal = AchiveRectQuantity.reDouble(goalVar)
        } else {
            template.goal = -1
        }
        template.biggerIsBetter = higherIsBetter
        template.userSet = userSet
        UIApplication.shared.endEditing()
        
        PersistenceController.shared.changeBiggerIsBetter(id: template.id, biggerIsBetter: higherIsBetter)
        print(template.goal)
        PersistenceController.shared.changeGoal(id: template.id, goal: template.goal)
        PersistenceController.shared.changeUserSet(id: template.id, userSet: userSet)
    }
    
    func setUserSet(newValue: Bool) {
        if timeAfterInit > Date() {
            timeAfterInit = Date()
        } else {
            userSet = true
        }
    }
    
    func filter(newValue: String) {
        let filtered = DrawTemplateTextField.filterReceive(newValue: newValue)
        if filtered != newValue {
            goalVar = filtered
        }
    }
    
    func initHigherBetter() {
        if template.goal != -1 {
            goalVar = String(template.goal)
        }
        if !template.userSet {
            if dataEntities.count == 0 {
                timeAfterInit = Date().addingTimeInterval(0.1)
                higherIsBetter = true
                return
            }
            let sortedEntries = sortDates(usedDataEntities: dataEntities)
            let earliest = AchiveRectQuantity.reDouble(sortedEntries[0].stringState)
            let latest =  AchiveRectQuantity.reDouble(sortedEntries[sortedEntries.count - 1].stringState)
            timeAfterInit = Date().addingTimeInterval(0.1)
            higherIsBetter = earliest >= latest ? true : false
        } else {
            higherIsBetter = template.biggerIsBetter
            userSet = true
        }
    }
}

func dateFormatterFun() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}

func reCal() -> Calendar {
    return Calendar(identifier: .gregorian)
}
