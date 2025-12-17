//
//  ProfileEntity.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import SwiftData
import Foundation

@Model
final class ProfileEntity {

    @Attribute(.unique)
    var id: UUID

    var name: String?
    var email: String?
    var isActive: Bool
    var totalPoints: Int64
    var currentPoints: Int64
    var totalSafeCarbon: Double
    var createdAt: Date
    var updatedAt: Date

    init(from profile: Profile) {
        self.id = profile.id
        self.name = profile.name
        self.email = profile.email
        self.isActive = profile.isActive
        self.totalPoints = profile.totalPoints
        self.currentPoints = profile.currentPoints
        self.totalSafeCarbon = profile.totalSafeCarbon
        self.createdAt = ISO8601DateFormatter().date(from: profile.createdAt) ?? .now
        self.updatedAt = ISO8601DateFormatter().date(from: profile.updatedAt) ?? .now
    }
}
