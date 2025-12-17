//
//  ProfileView.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import SwiftUI

struct User: View {

    // MARK: - Mock Profile Data
    @State private var name: String = "João Felipe"
    @State private var email: String = "joao@email.com"
    @State private var totalPoints: Int = 11040
    @State private var currentPoints: Int = 3200
    @State private var totalSafeCarbon: Double = 128.5

    @State private var isEditing: Bool = false
    @State private var isSaving: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Avatar
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(initials)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.green)
                            )

                        if isEditing {
                            TextField("Nome", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(name)
                                .font(.title2.bold())
                        }

                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Stats
                    VStack(spacing: 16) {
                        ProfileStatRow(
                            icon: "star.fill",
                            title: "Pontos Totais",
                            value: "\(totalPoints)"
                        )

                        ProfileStatRow(
                            icon: "bolt.fill",
                            title: "Pontos Atuais",
                            value: "\(currentPoints)"
                        )

                        ProfileStatRow(
                            icon: "leaf.fill",
                            title: "Carbono Evitado",
                            value: "\(totalSafeCarbon) kg"
                        )
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            if isEditing {
                                saveProfile()
                            } else {
                                isEditing = true
                            }
                        } label: {
                            Text(isEditing ? "Salvar Perfil" : "Editar Perfil")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        if isEditing {
                            Button {
                                cancelEdit()
                            } label: {
                                Text("Cancelar")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Perfil")
        }
    }

    // MARK: - Helpers
    private var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first ?? "?"
        let last = parts.last?.first ?? "?"
        return "\(first)\(last)"
    }

    private func saveProfile() {
        isSaving = true

        // 🔌 Aqui depois você chama:
        // UserService.updateUserName(...)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            isEditing = false
        }
    }

    private func cancelEdit() {
        // 🔁 Resetaria os dados vindo do backend
        isEditing = false
    }
}

struct ProfileStatRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)

            Text(title)
                .font(.headline)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}


#Preview {
    User()
}
