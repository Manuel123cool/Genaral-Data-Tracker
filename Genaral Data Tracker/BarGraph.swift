//
//  BlockGraph.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 28.07.21.
//

import SwiftUI

struct BarGraph: View {
    let values: [Double]
    let usePerc: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                if values.count != 0 && LineGraph.allNotNull(values) {
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(0..<values.count, id: \.self) { index in
                            barView(index)
                        }
                    }
                    TypIndication(values: values, usePerc: usePerc)
                }
            }
            .frame(width: PercSize.width(100), height: PercSize.heigth(50), alignment: .bottomTrailing)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 20))
        }
    }
    
    static func discacrdTooLongFloat(_ num: Double) -> Double {
        let factor: Double = 100000000
        return Double(Int(num * factor)) / Double(factor)
    }
    
    func barView(_ index: Int) -> some View {
        let barWidth = PercSize.width(Float(85) / Float(values.count)) - 5
        let barHeight = TypIndication.reBarHeight(values[index], values)

        return Rectangle()
            .frame(width: barWidth, height: barHeight)
            .colorByIndex(index, range: 0..<values.count)
    }
}

extension View {
    func colorByIndex(_ index: Int, range: Range<Int>) -> some View {
        if GraphLabels.isOrange(index, range: range) == 0 {
            return self.foregroundColor(Color.gray)
        } else if GraphLabels.isOrange(index, range: range) == 1 {
            return self.foregroundColor(Color.orange)
        } else {
            return self.foregroundColor(Color.blue)
        }
    }
}

struct GraphLabels: View {
    let labals: [String]
    let deph: Int
    let alternateColor: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<labals.count, id: \.self) { index in
                label(index)
            }
        }
        .frame(width: PercSize.width(100), height: PercSize.heigth(12.5), alignment: .topLeading)
        .padding(.leading, PercSize.width(25))
    }
    
    func label(_ index: Int) -> some View {
        if alternateColor {
            return Text(labals[index])
                .offset(x: textWidth * CGFloat(index), y: reYOffset(index))
                .colorByIndex(index, range: 0..<labals.count)
        } else {
            return Text(labals[index])
                .offset(x: textWidth * CGFloat(index), y: reYOffset(index))
                .colorByIndex(0, range: 0..<labals.count)
        }
    }
    
    static func isOrange(_ index: Int, range: Range<Int>) -> Int {
        var colorInt: Int = 0
        for indexLoop in range {
            if indexLoop == index {
                return colorInt
            }
            
            colorInt -= 1
            if colorInt == -1 {
                colorInt = 2
            }
        }
        return -1
    }
    
    var textWidth: CGFloat {
        PercSize.width(Float(85) / Float(labals.count))
    }
    
    func reYOffset(_ index: Int) -> CGFloat {
        let oneOffsetVal: Double = 25
        
        var countDeph = 0
        for indexCount in 0..<labals.count {
            if indexCount == index {
                return CGFloat(oneOffsetVal * Double(countDeph))
            }
            
            if countDeph == deph - 1 {
                countDeph = 0
            } else {
                countDeph += 1
            }
        }
        return 0.0
    }
}
