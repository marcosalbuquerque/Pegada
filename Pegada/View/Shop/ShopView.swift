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
                    CardTotalPoints(profile: profile)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView{
                        ForEach(viewModel.coupons){coupon in
                            CouponComponent(viewModel: viewModel, coupon: coupon)
    
                        }
                    }
//                    List(viewModel.coupons) { coupon in
//                        HStack {
//                            HStack{
//                                VStack{
//                                    Text("")
//                                }.frame(width: 56, height: 56)
//                                    .background(Color.yellow.opacity(0.4))
//                                    .cornerRadius(8)
//                                Image("DividerImage")
//                            }
//                            VStack(alignment: .leading) {
//                                Text(coupon.description)
//                                    .font(.headline)
//                                Text("\(coupon.price_points) pontos")
//                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
//                            }
//                            Spacer()
//                            Button("Resgatar") {
//                                viewModel.buy(coupon: coupon)
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .disabled((viewModel.userProfile?.currentPoints ?? 0) < Int64(coupon.price_points))
//                            .padding(8)
//                        }
//                    }
                }
            }
            .navigationTitle("Loja")
            .task {
                await viewModel.loadData(userId: currentUserId)
            }
        }
    }
}
