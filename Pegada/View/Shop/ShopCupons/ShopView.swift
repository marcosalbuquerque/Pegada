//
//  ShopView.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import SwiftUI

struct ShopView: View {
    let currentUserId: UUID
    @StateObject private var viewModel = ShopViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let profile = viewModel.userProfile {
                    CardTotalPoints(profile: profile)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView{
                        ForEach(viewModel.coupons){coupon in
                            NavigationLink(destination: BuyCuponView(viewModel: viewModel, coupon: coupon), label: {
                                CouponComponent(viewModel: viewModel, coupon: coupon)
                                    .foregroundStyle(Color(.white))
                                    
                            })
    
                        }
                    }

                }
            }
            .navigationTitle("Cupons")
            .task {
                await viewModel.loadData(userId: currentUserId)
            }
        }
    }
}
