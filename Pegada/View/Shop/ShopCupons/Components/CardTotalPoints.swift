//
//  CardTotalPoints.swift
//  Pegada
//
//  Created by Filipi Romão on 17/12/25.
//

import SwiftUI

struct CardTotalPoints: View {
    var profile: ProfileEntity
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Image(systemName: "star.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.greenHighlight)
                    Text("Total de pontos")
                        .font(.caption)
                        .foregroundStyle(.greenHighlight)
                }
                Text("\(profile.currentPoints)")
                    .font(.system(.title3))
            }
            Spacer()
        }
        .padding()
        .background(Color(.backGroundIcon))
        .cornerRadius(12)
        .padding()

    }
}


