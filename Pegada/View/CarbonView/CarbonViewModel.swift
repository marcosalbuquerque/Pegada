//
//  CarbonViewModel.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import Foundation
import Combine

class CarbonViewModel: ObservableObject {
    @Published var selectedMode: TransportMode = .bicycle
    @Published var distanceInput: String = ""
    @Published var result: ActivityResult?
    
    // Manager
    private let carbonCalculator = CarbonCalculatorManager()
    
    // chama quando o usuário termina o trajeto
    func finalizeActivity() {
        guard let distance = Double(distanceInput), distance > 0 else {
            print("Distância inválida.")
            return
        }
        
        // Chama o Manager para realizar o cálculo
        let calculatedResult = carbonCalculator.calculateImpact(
            for: selectedMode,
            distanceKm: distance
        )
        
        // Atualiza o estado da View
        self.result = calculatedResult
        
        // salvar no banco de dados
    }
}
