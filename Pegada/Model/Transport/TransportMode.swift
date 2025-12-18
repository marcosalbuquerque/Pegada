//
//  TransportMode.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit

enum TransportMode: String, CaseIterable, Identifiable {
    case aPe = "A pé"
    case bicicleta = "Bicicleta"
    case patinete = "Patinete"
    case transportePublico = "Transporte"
    
    var emissionFactor: Double {
        switch self {
        case .aPe, .bicicleta, .patinete:
            return 0.0 // Caminhada, Bicicleta, Patinete = 0 gCO2/km
        case .transportePublico:
            return 100.0 // Usando 100.0 (Ônibus) como valor conservador para T.Público
        }
    }

    var id: String { rawValue }

    var mkType: MKDirectionsTransportType {
        switch self {
        case .transportePublico:
            return .transit
        default:
            return .walking
        }
    }

    var timeMultiplier: Double {
        switch self {
        case .aPe:
            return 1.0
        case .bicicleta, .patinete:
            return 1.0 / 3.0
        case .transportePublico:
            return 1.0
        }
    }
    
    // Propriedade para imagens customizadas do Assets
    var assetName: String {
        switch self {
        case .aPe: return "pe"
        case .bicicleta: return "bike"
        case .patinete: return "patinete"
        case .transportePublico: return "onibus"
        }
    }

    var icon: String {
        switch self {
        case .aPe: return "figure.walk"
        case .bicicleta: return "bicycle"
        case .patinete: return "scooter"
        case .transportePublico: return "bus.fill"
        }
    }
}

struct TripResult {
    let distanceKm: Double
    let mode: TransportMode
    let carbonSavedGrams: Double
    let pointsEarned: Int
    
}
