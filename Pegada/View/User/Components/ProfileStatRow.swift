//
//  ProfileStatRow.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import SwiftUI

struct ProfileStatRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(Color.greenHighlight)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.greenHighlight)
            }
            Spacer()
            Text(value)
                .font(.title3.bold())
                .foregroundColor(Color.allWhite)
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.backGroundIcon)
        .cornerRadius(12)
    }
}
