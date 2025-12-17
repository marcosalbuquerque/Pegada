//
//  MapLogic.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit
import SwiftUI

extension MapView {
    
    // MARK: - Funções internas da View
    
    func startNavigation() {
            // Captura a distância inicial em linha reta para usar de base no progresso
            if let userLocation = locationManager.userLocation,
               let destination = selectedDestination {
                
                // Cria a location do destino
                let destCoord = destination.placemark.coordinate
                let destLocation = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
                
                // Salva a distância inicial (ex: 500m em linha reta)
                self.initialStraightLineDistance = userLocation.distance(from: destLocation)
            }
            
            withAnimation {
                isNavigating = true
                camera = .userLocation(followsHeading: true, fallback: .automatic)
            }
        }
    
    func stopNavigation() {
        withAnimation {
            isNavigating = false
            if let route {
                camera = .rect(route.polyline.boundingMapRect)
            } else {
                camera = .userLocation(fallback: .automatic)
            }
        }
    }
    
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
        
        // Exemplo de log para debug
        print("Resultado Final:")
        print("CO2 Economizado: \(result.carbonSavedGrams) g")
        print("Pontos Ganhos: \(result.pointsEarned)")
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
        tripResult = nil
        
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = destination
        request.transportType = selectedMode.mkType
        
        MKDirections(request: request).calculate { response, error in
            
            if let error {
                routeErrorMessage = "Não há uma rota disponível para este tipo de transporte."
                print("MapKit error:", error.localizedDescription)
                return
            }
            
            guard
                let routes = response?.routes,
                let firstRoute = routes.first
            else {
                routeErrorMessage = "Não há uma rota disponível para este tipo de transporte."
                return
            }
            
            withAnimation {
                self.route = firstRoute
                self.camera = .rect(firstRoute.polyline.boundingMapRect)
                self.finalizeRoute(route: firstRoute)
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
        withAnimation {
            route = nil
            routeErrorMessage = nil
            selectedDestination = nil
            tripResult = nil
            camera = .userLocation(fallback: .automatic)
        }
    }
    
    // MARK: - Correção de Depreciação no Cálculo
        func getCurrentProgress() -> (points: Int, co2: Double, progress: Double) {
            guard let result = tripResult,
                  let userLocation = locationManager.userLocation,
                  let initialDist = initialStraightLineDistance else {
                // Se não tivermos a distância inicial, retornamos 0
                return (0, 0.0, 0.0)
            }
            
            // 1. Onde é o destino?
            let destCoord = selectedDestination?.placemark.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let destinationLocation = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
            
            // 2. Quanto falta AGORA em linha reta?
            let currentDistanceRemaining = userLocation.distance(from: destinationLocation)
            
            // 3. Cálculo da Porcentagem
            // Se no início faltava 1000m e agora falta 800m, andamos 20%
            // Fórmula: 1 - (RestanteAtual / RestanteInicial)
            
            var progress = 0.0
            if initialDist > 0 {
                progress = 1.0 - (currentDistanceRemaining / initialDist)
            }
            
            // Garante que fique entre 0.0 (início) e 1.0 (chegada)
            // O max(0.0) impede números negativos se o GPS oscilar para trás no início
            progress = max(0.0, min(1.0, progress))
            
            return (
                Int(Double(result.pointsEarned) * progress),
                result.carbonSavedGrams * progress,
                progress
            )
        }
}
