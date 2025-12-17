//
//  SupabaseClientProvider.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import Foundation
import Supabase


enum SupabaseConfig {
    static let url = URL(string: "https://aqalsvepdzybocajcesn.supabase.co")!
    static let anonKey = "sb_publishable_UmLM-t9cIeG1Kyd7AoGJCQ_6h0jiRGe"
}

final class SupabaseClientProvider {
    static let shared = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}

final class CouponService {

    private let client = SupabaseClientProvider.shared

    func fetchCoupons() async throws -> [Coupon] {
        print("📥 [Supabase] Buscando cupons ativos...")

        let response = try await client
            .from("cupons")
            .select("""
                id,
                description,
                price_points,
                expiration_date,
                store_id
            """)
            .eq("is_active", value: true)
            .execute()

        print("📦 [Supabase] JSON recebido:")
        print(String(data: response.data, encoding: .utf8) ?? "JSON inválido")

        let decoder = JSONDecoder()

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        decoder.dateDecodingStrategy = .formatted(formatter)

        let coupons = try decoder.decode([Coupon].self, from: response.data)

        print("✅ [Supabase] Cupons decodificados:", coupons.count)

        return coupons
    }

}
