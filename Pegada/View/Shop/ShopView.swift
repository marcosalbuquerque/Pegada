//
//  ShopView.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import SwiftUI
import SwiftData

struct ShopView: View {
    let currentUserId: UUID
    @StateObject var viewModel : ShopViewModel
    
    init(currentUserId: UUID, modelContext: ModelContext, userService : UserService) {
        self.currentUserId = currentUserId
        _viewModel = StateObject(wrappedValue: ShopViewModel(
            userId: currentUserId,
            modelContext: modelContext,
            userService: userService
        ))
    }
    
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
