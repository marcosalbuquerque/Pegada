//
//  ProfileStore.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//
import SwiftData
import Combine
import Foundation

@MainActor
final class ProfileStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(profile: Profile) throws {
        let entity = ProfileEntity(from: profile)
        context.insert(entity)
        try context.save()
    }

    func fetchCurrentProfile() throws -> ProfileEntity? {
        let descriptor = FetchDescriptor<ProfileEntity>()
        return try context.fetch(descriptor).first
    }

    // --- FUNÇÃO DE SOMA E HISTÓRICO ---
    func addLocalRewards(points: Int64, carbon: Double) {
        do {
            // 1. Pega o perfil
            guard let profile = try fetchCurrentProfile() else {
                print("❌ Perfil não encontrado para salvar rewards.")
                return
            }
            
            // 2. Atualiza totais (Carbon vem em gramas, converte apenas se necessário no total)
            // OBS: No ProfileEntity o totalSafeCarbon geralmente é em Kg.
            // Se o 'carbon' chega em gramas da rota, divida por 1000.
            let carbonInKg = carbon / 1000.0
            
            profile.currentPoints += points
            profile.totalPoints += points
            profile.totalSafeCarbon += carbonInKg // Soma em Kg
            profile.updatedAt = Date()
            
            // 3. Garante que a lista de histórico existe
            if profile.WeeklyHistory == nil {
                profile.WeeklyHistory = []
            }
            
            // 4. Formata o dia (Ex: "Qua")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.dateFormat = "EEE"
            let todayString = dateFormatter.string(from: Date()).capitalized.replacingOccurrences(of: ".", with: "")
            
            // 5. Atualiza ou cria a barra do dia
            if let index = profile.WeeklyHistory?.firstIndex(where: { $0.day == todayString }) {
                print("🔄 Atualizando dia existente: \(todayString)")
                profile.WeeklyHistory?[index].value += carbonInKg
            } else {
                print("🆕 Criando novo dia: \(todayString) com \(carbonInKg) kg")
                let newEntry = DailyCarbonEntity(day: todayString, value: carbonInKg)
                context.insert(newEntry) // Importante inserir no contexto
                profile.WeeklyHistory?.append(newEntry)
            }
            
            // 6. Salva tudo
            try context.save()
            print("✅ Sucesso! Pontos: \(points), Carbono Add: \(carbonInKg)kg")
            
        } catch {
            print("❌ Falha ao salvar pontos locais: \(error)")
        }
    }

    func deleteAll() throws {
        let descriptor = FetchDescriptor<ProfileEntity>()
        let profiles = try context.fetch(descriptor)
        profiles.forEach { context.delete($0) }
        try context.save()
    }
    
    func sincWithApi(profile: UserProfileDTO) {
        do {
            guard let actualProfile = try fetchCurrentProfile() else { return }

            actualProfile.name = profile.name
            actualProfile.email = profile.email
            actualProfile.currentPoints = Int64(profile.currentPoints)
            actualProfile.totalPoints = Int64(profile.totalPoints)
            actualProfile.totalSafeCarbon = profile.totalSafeCarbon
            
            try context.save()
        } catch {
            print("❌ Erro sync:", error)
        }
    }
}

// Extensão necessária para o ViewModel
extension ProfileStore {
    func updateName(userId: UUID, name: String?) throws {
        let descriptor = FetchDescriptor<ProfileEntity>(
            predicate: #Predicate { $0.id == userId }
        )
        guard let profile = try context.fetch(descriptor).first else { return }
        profile.name = name
        profile.updatedAt = .now
        try context.save()
    }
}
