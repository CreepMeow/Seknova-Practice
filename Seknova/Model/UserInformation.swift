//
//  UserInformation.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//

import Foundation
import RealmSwift

final class UserInformation: Object {
    @Persisted(primaryKey: true) var userId: String = ""
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var birthday: String = ""
    @Persisted var email: String = ""
    @Persisted var phone: String = ""
    @Persisted var address: String = ""
    @Persisted var gender: String = ""
    @Persisted var height: Int = 0
    @Persisted var weight: Int = 0
    @Persisted var race: String = ""
    @Persisted var liquor: String = ""
    @Persisted var smoke: Bool = false
    @Persisted var check: Bool = false
    @Persisted var phoneVerified: Bool = false
}
