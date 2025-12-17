//
//  NavigationStatusView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 16/12/25.
//


import SwiftUI
import MapKit

struct NavigationStatusView: View {
    
    let destinationName: String
    let route: MKRoute
    let tripResult: TripResult
    
    // Recebe os valores calculados em tempo real
    let currentProgress: (points: Int, co2: Double, progress: Double)
    let formatDistance: (CLLocationDistance) -> String
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            // 1. Cabeçalho (Destino e Botão Parar)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Em viagem para")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(destinationName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // Mostra distância total (ou poderia mostrar restante se calculado)
                    Text("Total: \(formatDistance(route.distance))")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.blue)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                Button(action: onStop) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.red)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            
            // 2. Barra de Progresso Visual
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Fundo da barra
                        Capsule()
                            .frame(height: 8)
                            .foregroundStyle(.gray.opacity(0.2))
                        
                        // Barra preenchida
                        Capsule()
                            .frame(width: geo.size.width * currentProgress.progress, height: 8)
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                            )
                            .animation(.linear, value: currentProgress.progress)
                    }
                }
                .frame(height: 8)
                
                // 3. Métricas (CO2 e Pontos)
                HStack {
                    // Carbono
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(Int(currentProgress.co2))g")
                                .font(.body.bold())
                                .contentTransition(.numericText(value: currentProgress.co2)) // Animação bonita dos números
                            
                            Text("/ \(Int(tripResult.carbonSavedGrams))g")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Divisor vertical pequeno
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 1, height: 20)
                    
                    Spacer()
                    
                    // Pontos
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(currentProgress.points)")
                                .font(.body.bold())
                                .contentTransition(.numericText(value: Double(currentProgress.points)))
                            
                            Text("/ \(tripResult.pointsEarned) pts")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .cornerRadius(12)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
    }
}
