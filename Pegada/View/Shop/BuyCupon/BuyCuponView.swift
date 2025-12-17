//
//  BuyCuponView.swift
//  Pegada
//
//  Created by Filipi Romão on 17/12/25.
//

import SwiftUI

struct BuyCuponView: View {
    @ObservedObject var viewModel: ShopViewModel
    var coupon: Coupon
    var body: some View {
        Text("\(coupon.name)")
        Text("\(coupon.description)")
        Text("\(Int(coupon.price_points))")
        Button("Resgatar") {
            viewModel.buy(coupon: coupon)
        }
        .buttonStyle(.borderedProminent)
        .disabled(
            (viewModel.userProfile?.currentPoints ?? 0)
                < Int64(coupon.price_points)
        )
    }
}
