//
//  ImageShare.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import SwiftUI

struct ImageShare: View {
    
    var body: some View {
        ZStack{
            Color.clear
            
            VStack{
                Text("n joguei carbono pro ar caralho")
                    .font(.title2.weight(.semibold))
                    .padding(.bottom,4)
            }
            .frame(width:300, height: 300)
            .background(Color.white)
            .cornerRadius(60)
         
        }
        .frame(width: 720, height: 1280)
    }
}

struct ActivityViewRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
