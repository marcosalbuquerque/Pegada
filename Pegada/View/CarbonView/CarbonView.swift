//
//  CarbonView.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import SwiftUI

struct CarbonView: View {
    
    // Instancia o ViewModel para o ciclo de vida da View
    @StateObject var viewModel = CarbonViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            // meio de transporte
            Picker("Meio de Transporte", selection: $viewModel.selectedMode) {
                ForEach(TransportMode.allCases.filter { $0 != .car }) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.menu)
            
            // distancia
            TextField("Distância percorrida (km)", text: $viewModel.distanceInput)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            
            Button("Calcular Impacto / Finalizar") {
                viewModel.finalizeActivity()
            }
            .buttonStyle(.borderedProminent)
            
            Divider()
            
            if let result = viewModel.result {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trajeto Concluído!")
                        .font(.headline)
                    Text("Modo: \(result.transportMode.rawValue)")
                    Text("Distância: \(String(format: "%.2f", result.distance)) km")
                    
                    // Resultado do Carbono
                    Text("🌎 Carbono Economizado: \(String(format: "%.0f", result.carbonSavedGrams)) g de CO₂")
                        .foregroundColor(.green)
                    
                    // Resultado dos Pontos
                    Text("💰 Pontos Ganhos: \(result.pointsEarned)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Registro de Atividade")
    }
}
