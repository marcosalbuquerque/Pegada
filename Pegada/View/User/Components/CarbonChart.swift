//
//  CarbonChart.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 17/12/25.
//

import SwiftUI
import Charts

struct CarbonChart: View {
    let data: [DailyCarbonDTO]
    @State var totalSafeCarbon: Double
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color.greenHighlight) // Aplique a cor no ícone também
                    Text("Total de Carbono Evitado")
                        .font(.headline)
                        .foregroundColor(Color.greenHighlight)
                }
            
            Spacer()
            
            if data.isEmpty {
                Text("Sem dados recentes")
                    .font(.title3.bold())
            }else {
                ProfileStatRow(
                    icon: "leaf.fill",
                    title: "Total de Carbono Evitado",
                    value: "\(totalSafeCarbon) kg"
                )
                Chart(data) { item in
                    BarMark(
                        x: .value("Dia", item.day),
                        y: .value("Kg", item.value)
                    )
                    .foregroundStyle(Color.darkGreenGradient)
                    .cornerRadius(4)
                }
                .frame(height: 150) //Altura do grafico
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
