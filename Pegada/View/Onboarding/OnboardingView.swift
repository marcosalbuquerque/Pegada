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
    
    // Estado para controlar o fim do onboarding
    @Binding var isCompleted: Bool
    
    // Estado local para controlar a página atual
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // 1. Fundo Global (Estética Dark)
            Color.headerDark
                .ignoresSafeArea()
            
            VStack {
                // Área de Swipe
                TabView(selection: $currentPage) {
                    ForEach(items.indices, id: \.self) { index in
                        OnboardingCardView(item: items[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Botão de Ação Estilizado (Igual ao Cupom)
                Button(action: handleNextButton) {
                    Text(isLastPage ? "Começar Jornada" : "Próximo")
                        .font(.headline.bold())
                        .foregroundColor(.black) // Contraste com o verde
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Use a cor de destaque do seu app (ex: greenHighlight ou similar)
                        .background(Color(red: 0.74, green: 0.89, blue: 0.35))
                        .cornerRadius(25) // Arredondamento estilo 'Pílula'
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50) // Espaço extra para safe area
                .animation(.easeInOut, value: currentPage)
            }
        }
        .onAppear {
            // Hack para garantir que os 'pontinhos' da paginação apareçam bem no fundo escuro
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(red: 0.74, green: 0.89, blue: 0.35, alpha: 1)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        }
    }
    
    // Helpers
    private var isLastPage: Bool {
        currentPage == items.count - 1
    }
    
    private func handleNextButton() {
        if isLastPage {
            withAnimation {
                isCompleted = true
            }
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }
}
