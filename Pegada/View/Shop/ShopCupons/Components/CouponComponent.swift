//
//  CouponComponent.swift
//  Pegada
//
//  Created by Filipi Romão on 17/12/25.
//

import SwiftUI
import UIKit

struct CouponComponent: View {
    @ObservedObject var viewModel: ShopViewModel
    @State private var uiImage: UIImage? = nil
    
    var coupon: Coupon
    
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f
    }()
    
    var body: some View {
        HStack(spacing: 20) {
            HStack {
                VStack {
                    if let image = uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        Color.yellow.opacity(0.4)
                            .frame(width: 56, height: 56)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 6)
                Image("DividerImage")
            }
//            HStack {
                
//                Circle()
//                    .foregroundStyle(Color.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coupon.name)
                        .font(.headline)
                        .foregroundStyle(.greenHighlight)
                    Text("\(Int(coupon.price_points)) pontos")
                        .font(.subheadline)
                    
                    Text(
                        "VÁLIDO ATÉ: \(CouponComponent.dateFormatter.string(from: coupon.expiration_date))"
                    )
                    .font(.footnote)
                }
//                Circle()
//                    .foregroundStyle(Color.green)
//            }
            
            
            Spacer()
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black , Color.darkGreenGradient, Color.darkGreenGradient]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .onAppear {
            Task {
                uiImage = await loadUiImage(url: coupon.img_url)
            }
        }
    }
}
