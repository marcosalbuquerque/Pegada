//
//  CouponModel.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import Foundation

struct Coupon: Identifiable, Decodable {
    let id: Int
    let description: String
    let price_points: Double
    let expiration_date: Date
    let store_id: Int
    let name: String
    let img_url: String
}


struct Store: Decodable {
    let id: UUID
    let name: String
}


