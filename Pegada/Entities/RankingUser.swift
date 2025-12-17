//
//  RankingUser.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import Foundation

struct RankingUser: Identifiable {
    let id = UUID()
    let position: Int
    let name: String
    let points: Int
    let userId: UUID

    var initials: String {
        let components = name.split(separator: " ")
        let first = components.first?.first ?? "?"
        let last = components.last?.first ?? "?"
        return "\(first)\(last)"
    }
}

