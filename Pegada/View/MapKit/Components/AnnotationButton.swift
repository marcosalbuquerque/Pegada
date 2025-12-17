//
//  AnnotationButton.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import SwiftUI

struct AnnotationButton: View {
    let icon: IconType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                switch icon {
                case .system(let name):
                    Image(systemName: name)
                        .resizable()
                case .asset(let resource):
                    Image(resource)
                        .resizable()
                }
            }
            .frame(width: 40, height: 40)
            .foregroundStyle(.blue)
            .background(.white)
            .clipShape(Circle())
            .shadow(radius: 3)
        }
    }
}
