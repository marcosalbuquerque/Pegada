//
//  CarbonCalculatorManager.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import Foundation

class CarbonCalculatorManager {
    
    // MARK: Constantes de Cálculo
    private let referenceEmissionFactor: Double = 180.0 // Fator do Carro (gCO2/km)
    private let pointsConversionFactor: Double = 45.0   // 1 Ponto a cada 45 gCO2 economizado
    
    /**
     - Parameters:
        - mode: O modal de transporte escolhido pelo usuário.
        - distanceMeters: A distância percorrida em metros.
     */
    
    func calculateImpact(for mode: TransportMode, distanceMeters: Double) -> TripResult {
        
        // Distância para Quilômetros
        let distanceKm = distanceMeters / 1000.0
        
        // Fatores de Emissão
        let chosenEmissionFactor = mode.emissionFactor
        
        // Fórmula: (Fator Carro - Fator Meio Escolhido) * Distância (km)
        let carbonSavingPerKm = referenceEmissionFactor - chosenEmissionFactor
        let totalCarbonSavedGrams = carbonSavingPerKm * distanceKm
        
        // Pontos = Carbono Total Economizado / Fator de Conversão (45 g/Ponto)
        var totalPointsEarned = 0.0
        
        if totalCarbonSavedGrams > 0 {
            totalPointsEarned = totalCarbonSavedGrams / pointsConversionFactor
        }
        
        let roundedPoints = Int(floor(totalPointsEarned))
        
        return TripResult(
            distanceKm: distanceKm,
            mode: mode,
            carbonSavedGrams: totalCarbonSavedGrams,
            pointsEarned: roundedPoints
        )
    }
}
