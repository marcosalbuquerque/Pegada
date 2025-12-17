//
//  CouponModel.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import Foundation

struct Coupon: Identifiable, Decodable {
    let id: UUID
    let description: String
    let price: Int
    let expiration_date: Date
    let loja_id: UUID
}

struct Store: Decodable {
    let id: UUID
    let name: String
}


