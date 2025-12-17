//
//  OnboardingView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import SwiftUI


struct OnboardingView: View {
    // Dados recebidos de fora
    let items: [OnboardingItem]
    
    // Estado para controlar o fim do onboarding (conectado ao AppStorage na ContentView)
    @Binding var isCompleted: Bool
    
    // Estado local para controlar a página atual
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            // Área de Swipe
            TabView(selection: $currentPage) {
                ForEach(items.indices, id: \.self) { index in
                    OnboardingCardView(item: items[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Botão de Ação Dinâmico
            Button(action: handleNextButton) {
                Text(isLastPage ? "Começar" : "Próximo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isLastPage ? Color.green : Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .animation(.easeInOut, value: currentPage)
        }
    }
    
    // Helpers
    private var isLastPage: Bool {
        currentPage == items.count - 1
    }
    
    private func handleNextButton() {
        if isLastPage {
            withAnimation {
                isCompleted.toggle()
            }
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }
}
