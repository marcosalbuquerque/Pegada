//
//  MapLogic.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit
import SwiftUI
import SwiftData

extension MapView {
    
    // Instância do Service
    var userService: UserService {
        UserService(baseURL: "https://pegada-backend-production.up.railway.app/api")
    }
    
    // MARK: - Início e Fim da Navegação
    
    func startNavigation() {
        guard let userLocation = locationManager.userLocation,
              let destination = selectedDestination else { return }
        
        self.startTime = Date()
        
        let destCoord = destination.placemark.coordinate
        let destLocation = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
        self.initialStraightLineDistance = userLocation.distance(from: destLocation)
        
        withAnimation {
            isNavigating = true
            camera = .userLocation(followsHeading: true, fallback: .automatic)
        }
    }
    
    func stopNavigation() {
        withAnimation {
            isNavigating = false
            startTime = nil
            route = nil
            selectedDestination = nil
            tripResult = nil
            camera = .userLocation(fallback: .automatic)
            finalStats = nil
        }
    }
    
    // MARK: - Tratamento de Cancelamento Manual
    func handleManualCancellation() {
        let currentStatus = getCurrentProgress()
        
        finalStats = (points: currentStatus.points, carbon: currentStatus.co2)
        
        // AQUI: Envia ao backend e depois chama o sincWithApi
        sendStatsToBackend(points: Int64(currentStatus.points), carbon: currentStatus.co2)
        
        isNavigating = false
        showSuccessAlert = true
    }
    
    // MARK: - Lógica Estilo Uber
    
    func updateNavigationLogic() {
        guard let userLocation = locationManager.userLocation,
              let destination = selectedDestination else { return }
        
        let destLocation = CLLocation(
            latitude: destination.placemark.coordinate.latitude,
            longitude: destination.placemark.coordinate.longitude
        )
        
        let distanceToDestination = userLocation.distance(from: destLocation)
        
        // Se estiver a menos de 30 metros, finaliza
        if distanceToDestination < 30 {
            attemptToFinishTrip()
        }
    }
    
    func attemptToFinishTrip() {
        guard let start = startTime, let result = tripResult else { return }
        
        let now = Date()
        let timeElapsed = now.timeIntervalSince(start)
        
        if timeElapsed < 5 { return }
        
        let distanceMeters = route?.distance ?? 0
        let averageSpeedKmh = (distanceMeters / timeElapsed) * 3.6
        
        print("Velocidade Média Detectada: \(String(format: "%.1f", averageSpeedKmh)) km/h")
        
        let speedLimit: Double
        switch selectedMode {
        case .aPe: speedLimit = 15.0
        case .bicicleta: speedLimit = 40.0
        case .patinete: speedLimit = 35.0
        default: speedLimit = 200.0
        }
        
        if averageSpeedKmh > speedLimit {
            isNavigating = false
            showSpeedLimitAlert = true
            return
        }
        
        let finalPoints = Int64(result.pointsEarned)
        let finalCarbon = result.carbonSavedGrams
        
        finalStats = (points: Int(finalPoints), carbon: finalCarbon)
        
        // AQUI: Envia ao backend e depois chama o sincWithApi
        sendStatsToBackend(points: finalPoints, carbon: finalCarbon)
        
        isNavigating = false
        showSuccessAlert = true
    }
    
    // MARK: - Função de Envio e Sincronização
    
    func sendStatsToBackend(points: Int64, carbon: Double) {
            
            let store = ProfileStore(context: modelContext)
            
            guard let profileEntity = try? store.fetchCurrentProfile() else {
                print("❌ Erro: Nenhum usuário encontrado logado no dispositivo.")
                return
            }
            
            // 1. ATUALIZAÇÃO IMEDIATA (Otimista)
            // O usuário vê os pontos ganhos na hora, sem esperar a internet
            store.addLocalRewards(points: points, carbon: carbon)
            
            let userId = profileEntity.id
            print("👤 Enviando pontos para o UserID: \(userId)")
            
            Task {
                do {
                    // 2. Envia para o servidor (Backup/Sincronização)
                    try await userService.sendUserStats(
                        userId: userId,
                        points: points,
                        safeCarbon: carbon
                    )
                    print("✅ Backend notificado com sucesso.")
                    
                    // 3. (Opcional) Sincroniza dados completos
                    // Damos um pequeno delay para garantir que o backend processou a soma
                    try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 segundo
                    
                    userService.fetchUserProfile(userId: userId.uuidString.lowercased()) { result in
                        switch result {
                        case .success(let userDTO):
                            Task { @MainActor in
                                store.sincWithApi(profile: userDTO)
                            }
                        case .failure(let error):
                            print("⚠️ Falha leve na sincronização final (mas o local já está ok): \(error)")
                        }
                    }
                    
                } catch {
                    print("❌ Erro de API (mas os pontos locais estão salvos): \(error)")
                    // Como já salvamos localmente no passo 1, o usuário não "perde" visualmente os pontos
                    // TODO: Implementar lógica de retry offline se necessário
                }
            }
        }
    
    // MARK: - Funções Auxiliares de Rota
    
    func formatDistance(_ distance: CLLocationDistance) -> String {
        return distance < 1000
        ? "\(Int(distance)) m"
        : String(format: "%.1f km", distance / 1000)
    }
    
    public func finalizeRoute(route: MKRoute) {
        let result = carbonCalculator.calculateImpact(
            for: selectedMode,
            distanceMeters: route.distance
        )
        self.tripResult = result
    }
    
    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        MKLocalSearch(request: request).start { response, _ in
            selectedDestination = response?.mapItems.first
        }
    }
    
    func calculateRoute() {
        guard let destination = selectedDestination else { return }
        route = nil
        routeErrorMessage = nil
        
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = destination
        request.transportType = selectedMode.mkType
        
        MKDirections(request: request).calculate { response, error in
            if let error {
                routeErrorMessage = "Rota indisponível."
                return
            }
            guard let firstRoute = response?.routes.first else { return }
            
            withAnimation {
                self.route = firstRoute
                if !isNavigating {
                    self.finalizeRoute(route: firstRoute)
                    self.camera = .rect(firstRoute.polyline.boundingMapRect)
                }
            }
        }
    }
    
    func clearRoute() {
        searchText = ""
        selectedDestination = nil
        route = nil
        tripResult = nil
        camera = .userLocation(fallback: .automatic)
    }
    
    func selectDestination(name: String, coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let item = MKMapItem(location: location, address: nil)
        item.name = name
        selectedDestination = item
    }
    
    func cancelRoute() {
        stopNavigation()
    }
    
    func getCurrentProgress() -> (points: Int, co2: Double, progress: Double) {
        guard let result = tripResult,
              let userLocation = locationManager.userLocation,
              let initialDist = initialStraightLineDistance else {
            return (0, 0.0, 0.0)
        }
        
        let destCoord = selectedDestination?.placemark.coordinate ?? CLLocationCoordinate2D()
        let destinationLocation = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
        
        let currentDistanceRemaining = userLocation.distance(from: destinationLocation)
        
        var progress = 0.0
        if initialDist > 0 {
            progress = 1.0 - (currentDistanceRemaining / initialDist)
        }
        progress = max(0.0, min(1.0, progress))
        
        return (
            Int(Double(result.pointsEarned) * progress),
            result.carbonSavedGrams * progress,
            progress
        )
    }
}
