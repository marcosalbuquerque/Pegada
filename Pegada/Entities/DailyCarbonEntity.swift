//
//  DailyCarbonDTO.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import SwiftData
import Foundation
@Model
final class DailyCarbonEntity {
    
    @Attribute(.unique)
    var id: String
    var day: String
    var value: Double
    
    init(day: String, value: Double) {
        self.id = day
        self.day = day
        self.value = value
    }
    
    // Construtor auxiliar para converter do DTO
    convenience init(from dto: DailyCarbonDTO) {
        self.init(day: dto.day, value: dto.value)
    }
}

