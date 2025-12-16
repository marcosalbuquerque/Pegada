//
//  Profile.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//
import Foundation

struct Profile: Decodable, Identifiable {
    let id: UUID
    let name: String?
    let email: String?
    let isActive: Bool
    let totalPoints: Int64
    let currentPoints: Int64
    let totalSafeCarbon: Double
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case isActive
        case totalPoints
        case currentPoints
        case totalSafeCarbon
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
