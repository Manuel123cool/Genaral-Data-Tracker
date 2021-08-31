//
//  PercentageSize.swift
//  Data Tracker
//
//  Created by Manuel Kümpel on 07.07.21.
//

import SwiftUI

struct PercSize {
    static func width(_ percent: Float) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.width / 100 * CGFloat(percent)
    }
    
    static func heigth(_ percent: Float) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.height / 100 * CGFloat(percent)
    }
}
