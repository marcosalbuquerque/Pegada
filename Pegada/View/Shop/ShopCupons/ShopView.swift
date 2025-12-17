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
            ScrollView {
                VStack {
                    if let profile = viewModel.userProfile {
                        CardTotalPoints(profile: profile)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                    } else {

                        ForEach(viewModel.coupons) { coupon in
                            NavigationLink(
                                destination: BuyCuponView(
                                    viewModel: viewModel,
                                    coupon: coupon
                                ),
                                label: {
                                    CouponComponent(
                                        viewModel: viewModel,
                                        coupon: coupon
                                    )
                                    .foregroundStyle(Color(.white))

                                }
                            )

                        }
                    }

                }
            }
            .navigationTitle("Cupons")
            .scrollPosition(id: .constant(0), anchor: .top)
            .task {
                await viewModel.loadData(userId: currentUserId)
            }
        }
    }
}
