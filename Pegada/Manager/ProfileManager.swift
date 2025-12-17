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

    func deleteAll() throws {
        let descriptor = FetchDescriptor<ProfileEntity>()
        let profiles = try context.fetch(descriptor)
        profiles.forEach { context.delete($0) }
        try context.save()
    }
}
