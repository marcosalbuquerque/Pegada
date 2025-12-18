//
//  BuyCuponView.swift
//  Pegada
//
//  Created by Filipi Romão on 17/12/25.
//

import SwiftUI

struct BuyCuponView: View {
    @ObservedObject var viewModel: ShopViewModel
    @Environment(\.dismiss) var dismiss
    var coupon: Coupon
    
    @State var ShowAlert: Bool = false
    
    // Estado para armazenar a imagem carregada
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            // Fundo escuro da tela
            Color .headerDark
                .ignoresSafeArea()
            VStack {
                Spacer()
                // Card Principal
                VStack(spacing: 25) {
                    // Header do Card: Logo + Info
                    HStack(alignment: .top, spacing: 20) {
                        // Imagem carregada via URL ou Placeholder
                        Group {
                            if let uiImage = uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                // Placeholder enquanto carrega ou se falhar
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(ProgressView().tint(.white))
                            }
                        }
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text(coupon.name)
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color .greenHighlight)
                            
                            Text("\(Int(coupon.price_points)) Pontos")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Descrição Central
                    Text(coupon.description)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    HStack{
                        Circle()
                            .fill(Color .headerDark)
                            .offset(x: -17)
                            .frame(height: 40)
                        
                        // Linha Pontilhada
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [5]))
                            .frame(height: 1)
                            .foregroundColor(Color.greenHighlight)
                            .padding(.horizontal)
                        
                        Circle()
                            .fill(Color .headerDark)
                            .offset(x: 17)
                            .frame(height: 40)
                    }
                    
                    // Botão Resgatar
                    Button(action: {
                        viewModel.buy(coupon: coupon)
                        ShowAlert = true
                    }) {
                        Text("Resgatar")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.greenHighlight)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .disabled((viewModel.userProfile?.currentPoints ?? 0) < Int64(coupon.price_points))
                    .opacity((viewModel.userProfile?.currentPoints ?? 0) < Int64(coupon.price_points) ? 0.5 : 1.0)
                }
                .alert("Sucesso", isPresented: $ShowAlert){
                    Button("Ok") {
                        dismiss()
                    }
                }message: {
                    Text("O cupom foi resgatado com sucesso!")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 600) // Altura fixa para manter o aspecto do card
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.greenGradient,Color.greenGradient, Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationTitle("Cupons")
        .navigationBarTitleDisplayMode(.inline) // Mantém centralizado e elegante
        .onAppear {
            Task {
                uiImage = await loadUiImage(url: coupon.img_url)
            }
        }
    }
}

// Shape auxiliar para a linha pontilhada
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
