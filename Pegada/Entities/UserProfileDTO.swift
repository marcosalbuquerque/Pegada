//
//  UserProfileDTO.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


struct UserProfileDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let totalPoints: Int
    let currentPoints: Int
    let totalSafeCarbon: Double
}