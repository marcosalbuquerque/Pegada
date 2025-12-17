//
//  RankingRow.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import SwiftUI

struct RankingRow: View {

    let user: RankingUser
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 16) {

            Text("\(user.position)")
                .font(.headline)
                .frame(width: 30)
                .foregroundColor(positionColor)

            Circle()
                .fill(isCurrentUser ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(user.initials)
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .green : .primary)

                Text("\(user.points) pontos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if user.position <= 3 {
                Image(systemName: medalIcon)
                    .font(.title2)
                    .foregroundColor(positionColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrentUser ? Color.green.opacity(0.12) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCurrentUser ? Color.green : Color.clear, lineWidth: 1)
        )
    }

    private var positionColor: Color {
        switch user.position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }

    private var medalIcon: String {
        switch user.position {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return ""
        }
    }
}
