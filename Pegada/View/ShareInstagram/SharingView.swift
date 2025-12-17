//
//  ContentView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//


import SwiftUI

struct SharingView: View {
    @State private var showShareSheet = false
    @StateObject private var viewModel = ShareViewModel()
        
    var body: some View {
        VStack {
            
            Text("Instagram Share")
                .font(.title.weight(.bold))
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(20)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            
            let shareImage = viewModel.generateShareImage()
            ActivityViewRepresentable(activityItems: [
                shareImage,
                "Hello let's connect :"
            ])
            
        }
    }
}
