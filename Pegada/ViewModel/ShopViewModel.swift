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

@MainActor
final class ShopViewModel: ObservableObject {
    
    @Published var coupons: [Coupon] = []
    @Published var userProfile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Serviço antigo para ler dados (Supabase)
    private let dataService = CouponService()
    // Novo serviço para transações (Railway API)
    private let transactionService = CouponAPIService()
    
    // Função para carregar dados iniciais
    func loadData(userId: UUID) async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            // Carrega cupons
            self.coupons = try await dataService.fetchCoupons()
            
            // Carrega perfil
            self.userProfile = try await fetchUserProfile(userId: userId)
        } catch {
            self.errorMessage = "Erro ao carregar: \(error.localizedDescription)"
        }
    }
    
    // Função de Compra
    func buy(coupon: Coupon) {
        guard let profile = userProfile else { return }
        
        // Pré-validação visual
        guard profile.currentPoints >= Int64(coupon.price) else {
            self.errorMessage = "Saldo insuficiente."
            return
        }

        Task {
            self.isLoading = true
            do {
                // 1. Chama a API do Railway para processar a compra
                try await transactionService.redeemCoupon(userId: profile.id, couponId: coupon.id)
                
                // 2. Se não deu erro, recarrega o perfil para atualizar o saldo na tela
                self.userProfile = try await fetchUserProfile(userId: profile.id)
                
                self.successMessage = "Cupom '\(coupon.description)' comprado!"
            } catch {
                self.errorMessage = "Falha na transação. Tente novamente."
                print("Erro API: \(error)")
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Auxiliar
    private func fetchUserProfile(userId: UUID) async throws -> Profile {
        return try await SupabaseClientProvider.shared
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute() 
            .value
    }
}
