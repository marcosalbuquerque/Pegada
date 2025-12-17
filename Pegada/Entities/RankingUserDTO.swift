//
//  RankingUserDTO.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


struct RankingUserDTO: Identifiable, Decodable {
    let id: String
    let name: String
    let totalSafeCarbon: Double
}
