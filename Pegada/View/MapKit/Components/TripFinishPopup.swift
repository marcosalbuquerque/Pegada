//
//  TripFinishPopup.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 18/12/25.
//

import SwiftUI

struct TripFinishPopup: View {
    let points: Int
    let carbon: Double
    
    // Ações para os botões
    let onShare: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Fundo escuro semitransparente para focar a atenção no popup
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // Opcional: Impedir fechar ao clicar fora para forçar a interação
                }
            
            // O Cartão do Popup
            VStack(spacing: 24) {
                
                // Ícone de Sucesso Animado
                Circle()
                    .fill(Color.greenHighlight.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.largeTitle.bold())
                            .foregroundColor(.greenHighlight)
                    )
                    .padding(.top, 10)
                
                Text("Viagem Finalizada!")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // Resumo dos Ganhos
                VStack(spacing: 12) {
                    Text("Você ganhou")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("+\(points) Pontos")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.greenHighlight)
                    
                    Text("e economizou \(Int(carbon))g de CO₂")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                
                // Botões de Ação
                VStack(spacing: 12) {
                    // Botão Principal: Compartilhar
                    Button(action: onShare) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartilhar Conquista")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.greenHighlight)
                        .cornerRadius(25)
                    }
                    
                    // Botão Secundário: Fechar
                    Button(action: onClose) {
                        Text("Fechar")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .padding(30)
            .background(Color.headerDark) // Usa a cor de fundo do seu tema
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            .padding(.horizontal, 40)
            // Animação de entrada
            .transition(.scale.combined(with: .opacity))
        }
        .zIndex(100) // Garante que fica acima do mapa
    }
}
