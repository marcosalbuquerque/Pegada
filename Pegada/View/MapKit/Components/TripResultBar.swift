//
//  TripResultBar.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 16/12/25.
//

import SwiftUI

struct TripResultBar: View {
    
    let result: TripResult
    
    var body: some View {
        HStack {
            Group {
                // Carbono Economizado
                Label("\(Int(result.carbonSavedGrams)) g CO₂", systemImage: "leaf.fill")
                    .foregroundColor(.green)
                
                // Pontos Ganhos
                Label("\(result.pointsEarned) Pontos", systemImage: "sparkles")
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

