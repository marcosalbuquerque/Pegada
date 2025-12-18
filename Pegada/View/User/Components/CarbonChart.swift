//
//  CarbonChart.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 17/12/25.
//

import SwiftUI
import Charts

struct CarbonChart: View {
    let data: [DailyCarbonEntity]
    
    let totalSafeCarbon: Double
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color.greenHighlight)
                    Text("Total de Carbono Evitado")
                        .font(.headline)
                        .foregroundColor(Color.greenHighlight)
                }
            
            Spacer()
            
            // Se estiver vazio, mostra mensagem, senão mostra o gráfico
            if data.isEmpty {
                Text("Sem dados recentes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    
                // Mesmo sem gráfico, mostra o total acumulado se for maior que zero
                if totalSafeCarbon > 0 {
                    VStack(alignment: .leading) {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(Color.greenHighlight)
                                .frame(width: 24)

                            Text("Total Acumulado")
                                .font(.headline)
                                .foregroundColor(Color.greenHighlight)
                        }
                        Spacer()
                        Text("\(String(format: "%.2f kg", totalSafeCarbon))")
                            .font(.title3.bold())
                            .foregroundColor(Color.allWhite)
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.backGroundIcon)
                    .cornerRadius(12)
                }
            } else {
                ProfileStatRow(
                    icon: "leaf.fill",
                    title: "Total de Carbono Evitado",
                    // Use formatação %.2f para ver casas decimais (ex: 0.05 kg)
                    value: String(format: "%.2f kg", totalSafeCarbon)
                )
                
                Chart(data) { item in
                    BarMark(
                        x: .value("Dia", item.day),
                        y: .value("Kg", item.value)
                    )
                    .foregroundStyle(Color.darkGreenGradient)
                    .cornerRadius(4)
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.backGroundIcon)
        .cornerRadius(12)
    }
}
