//
//  Record.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//
import Foundation
import RealmSwift

class Record: Object {
    @Persisted var count: Int = 0
    @Persisted var recordTime: String = ""
    @Persisted var displayTime: String = ""
    @Persisted var temperature: Int = 0
    @Persisted var adc1: Int = 0
    @Persisted var battery: Int = 0
    @Persisted var check: Bool = false
    @Persisted var calibrated: Bool = false
}
