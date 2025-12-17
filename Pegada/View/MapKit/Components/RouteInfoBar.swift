//
//  RouteInfoBar.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit
import SwiftUI

struct RouteInfoBar: View {

    let route: MKRoute
    let mode: TransportMode
    let onCancel: () -> Void
    let onStartNavigation: () -> Void
    let result: TripResult

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                
                VStack(alignment: .leading) {
                    Label(timeText, systemImage: "clock")
                        .font(.headline)
                        .foregroundStyle(.green)
                    Label(distanceText, systemImage: "map")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: mode.icon)
                    .font(.title2)

                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
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
                .cornerRadius(8)
            }
            
            
            Button(action: onStartNavigation) {
                Text("Iniciar")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }

    private var timeText: String {
        let adjustedTime = route.expectedTravelTime * mode.timeMultiplier
        let minutes = Int(adjustedTime / 60)

        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "\(h) h" : "\(h) h \(m) min"
        }
    }

    private var distanceText: String {
        route.distance < 1000
        ? "\(Int(route.distance)) m"
        : String(format: "%.1f km", route.distance / 1000)
    }
}
