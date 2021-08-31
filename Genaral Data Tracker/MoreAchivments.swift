//
//  MoreDrawAchivements.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 25.07.21.
//

import SwiftUI

struct AchiveRectYesNo: View {
    let dataEntities: [OneDataEntitiy]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FirstRowBool(dataEntities: dataEntities)
            SecondRowBool(dataEntities: dataEntities)
        }
    }
}

struct FirstRowBool: View {
    let dataEntities: [OneDataEntitiy]

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            yesCount
            Spacer()
            noCount
            Spacer()
            yesStreak
            Spacer()
        }
    }
    
    var yesCount: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reYesCount())
                .font(DrawAchivements.reFont(stringNum: reYesCount()))
            Text("Yes Count")
        }
        .achivRect()
    }
    
    var noCount: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reNoCount())
                .font(DrawAchivements.reFont(stringNum: reNoCount()))
            Text("No Count")
        }
        .achivRect()
    }
    
    var yesStreak: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(bestYesStreak())
                .font(DrawAchivements.reFont(stringNum: bestYesStreak()))
            Text("Best Yes Streak")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    func bestYesStreak() -> String {
        let sortedEntries = sortDates(usedDataEntities: dataEntities)
        
        var streaks: [Int] = [0]
        for dataEntity in sortedEntries {
            if dataEntity.boolState == true {
                streaks[streaks.count - 1] += 1
            } else {
                streaks.append(0)
            }
        }
        
        var best = 0
        for streak in streaks {
            if streak > best {
                best = streak
            }
        }
        return best == 0 ? "No Value" : String(best)
    }
    
    func reYesCount() -> String {
        var count = 0
        for dataEntity in dataEntities {
            if dataEntity.boolState == true {
                count += 1
            }
        }
        return String(count)
    }
    
    func reNoCount() -> String {
        var count = 0
        for dataEntity in dataEntities {
            if dataEntity.boolState == false {
                count += 1
            }
        }
        return String(count)
    }
}

struct SecondRowBool: View {
    let dataEntities: [OneDataEntitiy]

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            currentYesStreak
            Spacer()
            yesPercentage
            Spacer()
            entrieCount
            Spacer()
        }
    }
    
    var currentYesStreak: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reCurrentYesestreak())
                .font(DrawAchivements.reFont(stringNum: reCurrentYesestreak()))
            Text("Current Yes Streak")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var yesPercentage: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(reYesPerc())
                .font(DrawAchivements.reFont(stringNum: reYesPerc()))
            Text("Yes Percentage")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var entrieCount: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(entrieCunt)
                .font(DrawAchivements.reFont(stringNum: entrieCunt))
            Text("Overall Entries Count")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    var entrieCunt: String {
        String(dataEntities.count)
    }
    
    func reCurrentYesestreak() -> String {
        let sortedEntries = sortDates(usedDataEntities: dataEntities)

        var count = 0
        for dataEntity in sortedEntries {
            if dataEntity.boolState == true {
                count += 1
            } else {
                break
            }
        }
        return count == 0 ? "No Value" : String(count)
    }
    
    func reYesPerc() -> String {
        if dataEntities.count == 0 {
            return "No Value"
        }
        var count = 0
        for dataEntity in dataEntities {
            if dataEntity.boolState == true {
                count += 1
            }
        }
        let percString = String(count * 100 / dataEntities.count)
        return count == 0 ? "" : percString
    }
}

struct AchiveRectOptions: View {
    let dataEntities: [OneDataEntitiy]
    @Binding var template: OneEntrieData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<rowLength, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<reColumnLength(row), id: \.self) { column in
                            onePercOption(row * 3 + column)
                                .padding(.leading, PercSize.width(2.5))
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    var rowLength: Int {
        return Int(template.options.count / 3) + 1
    }
    
    func reColumnLength(_ row: Int) -> Int {
        let countBefore = row * 3
        if row == Int(template.options.count / 3) {
            return template.options.count - countBefore
        }
        return 3
    }
    
    func onePercOption(_ index: Int) -> some View {
        return VStack(alignment: .center, spacing: 5) {
            Text(reOptionPerc(index) + "%")
                .font(DrawAchivements.reFont(stringNum: reOptionPerc(index) + "%"))
            Text("Perentage Of Option: \(template.options[index])")
                .multilineTextAlignment(.center)
        }
        .achivRect()
    }
    
    func reOptionPerc(_ index: Int) -> String {
        if dataEntities.count == 0 {
            return ""
        }
        var count = 0
        for dataEntity in dataEntities {
            if dataEntity.stringState ==  template.options[index] {
                count += 1
            }
        }
        let percString = String(count * 100 / dataEntities.count)
        return count == 0 ? "" : percString
    }
}
