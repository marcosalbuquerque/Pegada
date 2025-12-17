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
        print("🔄 [VM] loadData iniciado para user:", userId)

        self.isLoading = true
        defer {
            self.isLoading = false
            print("🔄 [VM] loadData finalizado")
        }

        do {
            self.coupons = try await dataService.fetchCoupons()
            self.userProfile = try self.profileStore.fetchCurrentProfile()

        } catch {
            self.errorMessage = "Erro ao carregar dados"
            print("❌ [VM] Erro loadData:", error)
        }
    }

    func buy(coupon: Coupon) {
        print("🛒 [VM] Tentativa de compra do cupom:", coupon.id)

        guard let profile = userProfile else {
            print("❌ [VM] Perfil não carregado")
            return
        }

        guard profile.currentPoints >= Int64(coupon.price_points) else {
            print("❌ [VM] Saldo insuficiente")
            self.errorMessage = "Saldo insuficiente"
            return
        }

        Task {
            self.isLoading = true
            defer {
                self.isLoading = false
                 
                print("🔄 [VM] Fluxo de compra finalizado")
            }

            do {
                print("🚀 [VM] Chamando API de resgate...")
                try await transactionService.redeemCoupon(
                    userId: profile.id,
                    couponId: coupon.id
                )

                print("🔁 [VM] Recarregando perfil...")
                self.userProfile = try self.profileStore.fetchCurrentProfile()

                self.successMessage = "Cupom comprado com sucesso"
                print("✅ [VM] Compra concluída")

            } catch {
                self.errorMessage = "Falha na transação"
                print("❌ [VM] Erro na compra:", error)
            }
        }
    }

    private func fetchUserProfile(userId: UUID) async throws -> Profile {
        print("📥 [Supabase] Buscando perfil:", userId)

        let profile: Profile = try await SupabaseClientProvider.shared
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value

        print("👤 [Supabase] Perfil recebido. Pontos:", profile.currentPoints)

        return profile
    }
}
