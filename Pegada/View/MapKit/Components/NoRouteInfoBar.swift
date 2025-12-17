//
//  NoRouteInfoBar.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import SwiftUI

struct NoRouteInfoBar: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
    }
}
