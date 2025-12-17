//
//  MetricBox.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 17/12/25.
//

import SwiftUI

struct MetricBox: View {
    let title: String
    let value: String
    let unit: String?
    let isTime: Bool
    
    init(title: String, value: String, unit: String) {
        self.title = title
        self.value = value
        self.unit = unit
        self.isTime = false
    }
    
    init(title: String, time: String) {
        self.title = title
        self.value = time
        self.unit = nil
        self.isTime = true
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color("DarkGreenGradient"))
            
            Divider()
                .frame(width: 40)
                .background(Color("DarkGreenGradient"))
            
            Group {
                if isTime {
                    TimeValueView(timeString: value)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(value)
                            .font(.title3)
                            .bold()
                        Text(unit ?? "")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TimeValueView: View {
    let timeString: String
    
    var body: some View {
        let components = parseTime(timeString)
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            // Horas
            Text(components.hours)
                .font(.title3)
                .bold()
            Text("h")
                .font(.caption)
                .fontWeight(.medium)
            
            if !components.minutes.isEmpty {
                // Minutos
                Text(components.minutes)
                    .font(.title3)
                    .bold()
                Text("min")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
    
    func parseTime(_ input: String) -> (hours: String, minutes: String) {
        let parts = input.lowercased().components(separatedBy: "h")
        return parts.count == 2 ? (parts[0], parts[1]) : (input, "")
    }
}
