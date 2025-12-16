//
//  CarbonCalculatorManager.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import Foundation

class CarbonCalculatorManager {
    
    // MARK: Constantes de Cálculo
    private let referenceEmissionFactor: Double = TransportMode.car.emissionFactor // 180.0
    private let pointsFactor: Double = 45.0 // gCO2 por ponto

    /**
     - Parameters:
        - transportMode: O modal de transporte escolhido pelo usuário.
        - distanceKm: A distância percorrida em quilômetros.
     */
    
    func calculateImpact(for transportMode: TransportMode, distanceKm: Double) -> ActivityResult {
        
        // 1. Calcular o Fator de Emissão do Meio Escolhido
        let chosenEmissionFactor = transportMode.emissionFactor
        
        // 2. Calcular a Economia de Carbono por km (gCO2/km)
        let carbonSavingPerKm = referenceEmissionFactor - chosenEmissionFactor
        
        // 3. Calcular a Economia Total de Carbono (gCO2)
        let totalCarbonSavedGrams = carbonSavingPerKm * distanceKm
        
        // 4. Calcular os Pontos Ganhos
        // Pontos = Carbono Total Economizado / Fator de Conversão (45 g/Ponto)
        var totalPointsEarned = 0.0
        
        if totalCarbonSavedGrams > 0 {
            totalPointsEarned = totalCarbonSavedGrams / pointsFactor
        }
        
        // Garantir que os pontos sejam inteiros (arredondando para baixo, por exemplo)
        let roundedPoints = Int(floor(totalPointsEarned))
        
        return ActivityResult(
            distance: distanceKm,
            transportMode: transportMode,
            carbonSavedGrams: totalCarbonSavedGrams,
            pointsEarned: roundedPoints
        )
    }
}
