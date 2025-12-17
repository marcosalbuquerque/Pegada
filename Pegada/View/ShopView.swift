//
//  ShopView.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import SwiftUI

struct ShopView: View {
    // Suponha que você receba o ID do usuário logado de algum lugar
    let currentUserId: UUID
    @StateObject private var viewModel = ShopViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header de Saldo
                if let profile = viewModel.userProfile {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Saldo Disponível")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text("\(profile.currentPoints)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.blue)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List(viewModel.coupons) { coupon in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(coupon.description)
                                    .font(.headline)
                                Text("\(coupon.price_points) pontos")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Resgatar") {
                                viewModel.buy(coupon: coupon)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled((viewModel.userProfile?.currentPoints ?? 0) < Int64(coupon.price_points))
                        }
                    }
                }
            }
            .navigationTitle("Loja")
            .task {
                await viewModel.loadData(userId: currentUserId)
            }
        }
    }
}
