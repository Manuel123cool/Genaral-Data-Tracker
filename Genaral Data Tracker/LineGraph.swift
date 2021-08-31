//
//  LineGraph.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 06.08.21.
//

import SwiftUI

struct LineGraph: View {
    @Environment(\.colorScheme) var colorScheme

    let values: [Double]
    let usePerc: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                if values.count != 0 && LineGraph.allNotNull(values) {
                    allLines
                    TypIndication(values: values, usePerc: usePerc)
                }
            }
            .frame(width: PercSize.width(100), height: PercSize.heigth(50), alignment: .bottomTrailing)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 20))
        }
    }
    
    static func allNotNull(_ values: [Double]) -> Bool {
        for value in values {
            if  value != 0 {
                return true
            }
        }
        return false
    }
    
    var valueAsIndex: [Int] {
        var reIndexes: [Int] = []
        for (index, _) in values.enumerated() {
            reIndexes.append(index)
        }
        return reIndexes
    }
    
    var color: Color {
        if colorScheme == .dark {
            return .white
        } else {
            return .black
        }
    }
    
    var allLines: some View {
        Path { path in
            path.move(to: CGPoint(x: getX(0), y: getY(0)))
            path.addLines(reLines())
        }
        .stroke(color, style:
                    StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .foregroundColor(color)
    }
    
    func reLines() -> [CGPoint] {
        var rePoints: [CGPoint] = []
        for index in valueAsIndex {
            let currentPoint = CGPoint(x: getX(index), y: getY(index))
            rePoints.append(currentPoint)
        }
        return rePoints
    }
    
    func getX(_ index: Int) -> CGFloat {
        let oneBarWidth = PercSize.width(Float(85) / Float(values.count))
        let addPlus = PercSize.width(Float(15)) + CGFloat(5)
        let makeMiddle = (oneBarWidth - 5) / 2
        let x = oneBarWidth * CGFloat(index) + makeMiddle + addPlus
        return x
    }
    
    func getY(_ index: Int) -> CGFloat {
        let y = PercSize.heigth(50) - TypIndication.reBarHeight(values[index], values)
        return y
    }
}

struct TypIndication: View {
    let values: [Double]
    let usePerc: Bool
    
    var body: some View {
        typIndicatorLines
        sideValueVBar
    }
    
    var typIndicatorLines: some View {
        ForEach(1...reLengthAndNumTyp().length, id: \.self) { index in
            Rectangle()
                .frame(width: PercSize.width(100), height: 0.5)
                .foregroundColor(.black)
                .offset(x: 0, y: -TypIndication.reBarHeight(numFromIndex(index), values))
        }
    }
    
    var sideValueVBar: some View {
        ZStack(alignment: .bottomLeading) {
            ForEach(1...reLengthAndNumTyp().length, id: \.self) { index in
                Text(sideValueBarValue(index))
                    .offset(x: 10, y: -TypIndication.reBarHeight(numFromIndex(index), values) + 20)
            }
        }
        .frame(width: PercSize.width(100), height: PercSize.heigth(50), alignment: .bottomLeading)
    }
    
    func reLengthAndNumTyp() -> (length: Int, typ: Double) {
        var numberTypVar: (value: Double, typ: Double) = (value: -1, -1)
        for value in values {
            if value > numberTypVar.value {
                numberTypVar.typ = numberTyp(value)
                numberTypVar.value = value
            }
        }
        var length = Int(numberTypVar.value / numberTypVar.typ)
        
        if length <= 2 {
            numberTypVar.typ /= 2
            length = Int(numberTypVar.value / numberTypVar.typ)
        }
        return (length: length, typ: numberTypVar.typ)
    }
    
    func numFromIndex(_ index: Int) -> Double {
        let indexVar = reLengthAndNumTyp().length - index
        let value = reLengthAndNumTyp().typ * Double(indexVar + 1)
        return BarGraph.discacrdTooLongFloat(value)
    }
    
    func sideValueBarValue(_ index: Int) -> String {
        let extend = usePerc ? "%" : ""
        return "\(DrawAchivements.reIntOrDouble(numberPar: numFromIndex(index)))" + extend
    }
    
    static func highestValue(_ values: [Double]) -> Double {
        var highest: Double = 0
        for value in values {
            if value > highest {
                highest = value
            }
        }
        return highest
    }
    
    func numberTyp(_ number: Double) -> Double {
        var testNumber: Double = 0.0000000001
        while number > testNumber {
            testNumber *= 10
        }
        
        return testNumber / 10.0
    }
    
    static func reBarHeight(_ value: Double, _ values: [Double]) -> CGFloat {
        return PercSize.heigth(Float(value /  TypIndication.highestValue(values)) *
                                Float(100) / Float(2))
    }
}
