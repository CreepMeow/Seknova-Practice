//
//  CalibrationModeData.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//
import Foundation
import RealmSwift

class CalibrationModeData: Object {
    @Persisted(primaryKey: true) var modeId: Int = 0
    @Persisted var rawData2BGBias: Int = 0
    @Persisted var bgBias: Int = 0
    @Persisted var gLow: Int = 0
    @Persisted var bgHigh: Int = 0
    @Persisted var mapRate: Int = 0
    @Persisted var thresholdRise: Int = 0
    @Persisted var thresholdFall: Int = 0
    @Persisted var riseRate: Int = 0
    @Persisted var fallenRate: Int = 0
}
