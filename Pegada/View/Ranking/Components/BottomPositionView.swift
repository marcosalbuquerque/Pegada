//
//  BottomPositionView.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import SwiftUI

struct BottomPositionView: View {

    let position: Int

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)

                Text("Seu lugar:")
                    .font(.headline)

                Text("\(position)º")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}
