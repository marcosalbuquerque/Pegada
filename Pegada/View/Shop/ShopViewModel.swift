//
//  ShopViewModel.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import Foundation
import SwiftUI
import Supabase // Garanta que isso está importado
import Combine
import SwiftData

@MainActor
final class ShopViewModel: ObservableObject {

    @Published var coupons: [Coupon] = []
    @Published var userProfile: ProfileEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let dataService = CouponService()
    private let transactionService = CouponAPIService()
    
    private let userId: UUID
    private let userService: UserService
    private let profileStore: ProfileStore

    init(userId: UUID, modelContext :  ModelContext, userService: UserService) {
        self.userId = userId
        self.profileStore = ProfileStore(context: modelContext)
        self.userService = userService
    }

    func loadData(userId: UUID) async {
        self.isLoading = true
        defer {
            self.isLoading = false
        }

        do {
            self.coupons = try await dataService.fetchCoupons()
            self.userProfile = try self.profileStore.fetchCurrentProfile()

        } catch {
            self.errorMessage = "Erro ao carregar dados"
            print("Erro loadData:", error)
        }
    }

    func buy(coupon: Coupon) {
        guard let profile = userProfile else {
            return
        }

        guard profile.currentPoints >= Int64(coupon.price_points) else {
            self.errorMessage = "Saldo insuficiente"
            return
        }

        Task {
            self.isLoading = true
            defer { self.isLoading = false }

            do {
                let result = try await transactionService.redeemCoupon(
                    userId: profile.id,
                    couponId: coupon.id
                )


                self.userProfile = try self.profileStore.fetchCurrentProfile()


                self.successMessage = "Cupom comprado com sucesso"
            } catch {
                // Mostra a mensagem específica do backend
                self.errorMessage = error.localizedDescription
                print("Erro na compra:", error.localizedDescription)
            }
        }
    }

    private func fetchUserProfile(userId: UUID) async throws -> Profile {

        let profile: Profile = try await SupabaseClientProvider.shared
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        return profile
    }
}
