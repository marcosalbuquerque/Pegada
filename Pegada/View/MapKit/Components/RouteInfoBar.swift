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

    var body: some View {
        HStack(spacing: 12) {
            
            Label(timeText, systemImage: "clock")
            Label(distanceText, systemImage: "map")

            Spacer()

            Image(systemName: mode.icon)

            Button {
                onCancel()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
            }
            .accessibilityLabel("Cancelar rota")
        }
        .padding()
        .background(.thinMaterial)
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
