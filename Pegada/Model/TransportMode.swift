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

    var icon: String {
        switch self {
        case .aPe: return "figure.walk"
        case .bicicleta: return "bicycle"
        case .patinete: return "scooter"
        case .transportePublico: return "bus.fill"
        }
    }
}
