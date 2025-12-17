//
//  ProfileView.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import SwiftUI

import SwiftUI

struct User: View {

    // MARK: - ViewModel
    @StateObject private var vm: UserViewModel

    // MARK: - Local State
    @State private var editedName: String = ""
    @State private var isEditing: Bool = false

    // MARK: - Init
    init(currentUserId: String) {
        let service = UserService(
            baseURL: "https://pegada-backend-production.up.railway.app/api"
        )

        _vm = StateObject(
            wrappedValue: UserViewModel(
                userService: service,
                userId: currentUserId
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile = vm.profile {
                    VStack(spacing: 24) {

                        // Avatar
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.green.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(initials(from: profile.name))
                                        .font(.largeTitle.bold())
                                        .foregroundColor(.green)
                                )

                            if isEditing {
                                TextField("Nome", text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(profile.name)
                                    .font(.title2.bold())
                            }

                            Text(profile.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Stats
                        VStack(spacing: 16) {
                            ProfileStatRow(
                                icon: "star.fill",
                                title: "Pontos Totais",
                                value: "\(profile.totalPoints)"
                            )

                            ProfileStatRow(
                                icon: "bolt.fill",
                                title: "Pontos Atuais",
                                value: "\(profile.currentPoints)"
                            )

                            ProfileStatRow(
                                icon: "leaf.fill",
                                title: "Carbono Evitado",
                                value: "\(profile.totalSafeCarbon) kg"
                            )
                        }

                        // Actions
                        VStack(spacing: 12) {
                            Button {
                                if isEditing {
                                    vm.updateUserName(editedName)
                                    isEditing = false
                                } else {
                                    editedName = profile.name
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
                            .disabled(vm.isLoading)

                            if isEditing {
                                Button {
                                    isEditing = false
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

                if vm.isLoading {
                    ProgressView("Carregando perfil...")
                        .padding()
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Perfil")
            .onAppear {
                vm.loadUserProfile()
            }
        }
    }

    // MARK: - Helpers
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first ?? "?"
        let last = parts.last?.first ?? "?"
        return "\(first)\(last)"
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

