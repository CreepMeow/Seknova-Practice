//
//  Event.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//
import Foundation
import RealmSwift

class Event: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var dateTime: String = ""
    @Persisted var displayTime: String = ""
    @Persisted var eventAttribute = List<String>()
    @Persisted var eventId: Int = 0
    @Persisted var eventValue: Int = 0
    @Persisted var note: String = ""
    @Persisted var check: Bool = false
}
