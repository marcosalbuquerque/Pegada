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
    private var actualProfile : ProfileEntity?
    
    

    init(context: ModelContext) {
        self.context = context
        let descriptor = FetchDescriptor<ProfileEntity>()
        
        self.actualProfile = nil
        
        do {
            actualProfile = try context.fetch(descriptor).first
        } catch {
            print(error)
        }
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
    
    func fetchLastSevenCarbonsMetrics() -> [DailyCarbonEntity] {
        guard let history = actualProfile?.WeeklyHistory, !history.isEmpty else {
            return []
        }
        
        let sortedHistory = history.sorted { first, second in
            guard let firstDate = ISO8601DateFormatter().date(from: first.day),
                  let secondDate = ISO8601DateFormatter().date(from: second.day) else {
                return false
            }
            return firstDate > secondDate
        }
        return Array(sortedHistory.prefix(7))
    }

    func deleteAll() throws {
        let descriptor = FetchDescriptor<ProfileEntity>()
        let profiles = try context.fetch(descriptor)
        profiles.forEach { context.delete($0) }
        try context.save()
    }
    
    func decrementPoints(pointsToDecrement: Int) throws {
        do {
            actualProfile?.currentPoints = (actualProfile?.currentPoints ?? 0) - Int64(pointsToDecrement)
        }
    }
    
    func incrementPoints(pointsToIncrement : Int) throws {
        do {
            actualProfile?.currentPoints = (actualProfile?.currentPoints ?? 0) + Int64(pointsToIncrement)
        }
    }
    
    func incrementCarbonStep(quantity: Double) throws {
        do {
            actualProfile?.totalSafeCarbon += quantity
            carbonDaily.value += quantity
        }
    }
    func sincWithApi(profile: UserProfileDTO) {
            do {
                guard let actualProfile = try fetchCurrentProfile() else {
                    return
                }

                actualProfile.name = profile.name
                actualProfile.email = profile.email
                actualProfile.currentPoints = Int64(profile.currentPoints)
                actualProfile.totalPoints = Int64(profile.totalPoints)
                actualProfile.totalSafeCarbon = profile.totalSafeCarbon

                try context.save()
            } catch {
                print("Erro ao sincronizar perfil:", error)
            }
        }
}

extension ProfileStore {

    func updateName(userId: UUID, name: String?) throws {

        let descriptor = FetchDescriptor<ProfileEntity>(
            predicate: #Predicate { $0.id == userId }
        )

        guard let profile = try context.fetch(descriptor).first else {
            throw NSError(domain: "ProfileStore", code: 404)
        }

        profile.name = name
        profile.updatedAt = .now

        try context.save()
    }
}


extension ProfileStore {
    // MARK: - Carbon diário
    var carbonDaily: DailyCarbonEntity {
        get {
            guard let profile = actualProfile else {
                fatalError("Perfil não inicializado")
            }

            let todayString = ISO8601DateFormatter().string(from: .now).prefix(10)

            if let daily = profile.WeeklyHistory?.first(where: { $0.day.hasPrefix(todayString) }) {
                return daily
            } else {
                let newDaily = DailyCarbonEntity(day: String(todayString), value: 0)
                if profile.WeeklyHistory == nil {
                    profile.WeeklyHistory = []
                }
                profile.WeeklyHistory?.append(newDaily)
                
                do {
                    try context.save()
                } catch {
                    print("Erro ao salvar entrada diária:", error)
                }

                return newDaily
            }
        }
        set {
            guard let profile = actualProfile else { return }

            let todayString = ISO8601DateFormatter().string(from: .now).prefix(10)

            if let index = profile.WeeklyHistory?.firstIndex(where: { $0.day.hasPrefix(todayString) }) {
                profile.WeeklyHistory?[index] = newValue
            } else {
                if profile.WeeklyHistory == nil {
                    profile.WeeklyHistory = []
                }
                profile.WeeklyHistory?.append(newValue)
            }

            do {
                try context.save()
            } catch {
                print("Erro ao atualizar entrada diária:", error)
            }
        }
    }
}

