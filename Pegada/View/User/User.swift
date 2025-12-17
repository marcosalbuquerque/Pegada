//
//  ProfileView.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import SwiftUI
import SwiftData

struct User: View {

    // MARK: - ViewModel
    @StateObject private var vm: UserViewModel

    // MARK: - Local State
    @State private var editedName: String = ""
    @State private var isEditing: Bool = false
    
    let mockDailyCarbon: [DailyCarbonEntity] = [
        DailyCarbonEntity(day: "Mon", value: 2.5),
        DailyCarbonEntity(day: "Tue", value: 3.0),
        DailyCarbonEntity(day: "Wed", value: 1.8),
        DailyCarbonEntity(day: "Thur", value: 2.2),
        DailyCarbonEntity(day: "Fri", value: 2.9),
        DailyCarbonEntity(day: "Sat", value: 3.1),
        DailyCarbonEntity(day: "Sun", value: 2.7)
    ]
    
    let totalCarbonMock : Double


    // MARK: - Init
    init(currentUserId: UUID, modelContext: ModelContext, userService: UserService) {
        _vm = StateObject(
            wrappedValue: UserViewModel(
                modelContext: modelContext,
                userId: currentUserId,
                userService: userService
            )
        )
        
        totalCarbonMock = mockDailyCarbon.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack{
                    Divider()
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.backGroundPerfil)
                    
                    if let profile = vm.profile {
                        VStack(spacing: 24) {

                            // Avatar
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.green.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(initials(from: profile.name ?? " "))
                                            .font(.largeTitle.bold())
                                            .foregroundColor(.green)
                                    )

                                if isEditing {
                                    TextField("Nome", text: $editedName)
                                        .textFieldStyle(.roundedBorder)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(profile.name ?? " ")
                                        .font(.title2.bold())
                                }

                                Text(profile.email ?? " ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // Stats
                            VStack(spacing: 16) {
                                
                                //TODO: Pegar os dados corretamente pela viewModel
                                CarbonChart(data: mockDailyCarbon, totalSafeCarbon: totalCarbonMock)

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
                            }

                            // Actions
                            VStack(spacing: 12) {
                                Button {
                                    if isEditing {
                                        Task {
                                            await vm.updateUserName(editedName)
                                            isEditing = false
                                        }
                                    } else {
                                        editedName = profile.name ?? " "
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
