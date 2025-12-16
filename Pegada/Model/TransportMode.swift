//
//  TransportMode.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import Foundation

enum TransportMode: String, CaseIterable, Identifiable {
    case car = "Carro" // Modal de Referência
    case bus = "Ônibus Urbano"
    case metro = "Metrô/Trem Urbano"
    case bicycle = "Bicicleta"
    case walking = "Caminhada"

    var id: String { self.rawValue }

    // MARK: Fatores de Emissão (gCO2/passageiro-km)
    var emissionFactor: Double {
        switch self {
        case .car:
            return 180.0
        case .bus:
            return 100.0
        case .metro:
            return 6.0
        case .bicycle, .walking:
            return 0.0
        }
    }
}

struct ActivityResult {
    let distance: Double // Distância percorrida em km
    let transportMode: TransportMode
    let carbonSavedGrams: Double
    let pointsEarned: Int // Pontos devem ser um número inteiro, se possível
}
