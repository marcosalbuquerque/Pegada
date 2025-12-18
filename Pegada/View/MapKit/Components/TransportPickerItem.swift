//
//  TransportPickerItem.swift
//  Pegada
//
//  Created by Linda Marie Ribeiro Alves Correa dos Santos on 17/12/25.
//
import SwiftUI

struct TransportModeItem: View {
    let mode: TransportMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .black : .white)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.greenHighlight)
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                Capsule()
                    .stroke(Color.greenHighlight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
