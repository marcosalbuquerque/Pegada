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
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            
            Text("\(user.position)")
                .font(.headline)
                .foregroundColor(.darkGreenGradient)
                .frame(width: 30)
            
            Circle()
                .fill(Color.podiumBackground)
                .frame(width: 40, height: 40)
            
            Text(user.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(Color.greenHighlight)
                    .font(.caption)
                
                Text("\(user.points)")
                    .font(.subheadline)
                    .bold()
                    .padding(.trailing, 14)
                    .padding(.leading, 8)
                    .foregroundColor(Color.greenHighlight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 30)
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isCurrentUser ? Color.greenHighlight : Color.clear, lineWidth: 1)
        )
        .padding(.horizontal) 
    }
}

