//
//  MapView.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    
    @StateObject var locationManager = LocationManager()
    @State var initialStraightLineDistance: CLLocationDistance?
    private let carbonCalculator = CarbonCalculatorManager()
    
    // Variáveis de Estado acessadas pela Extension
    @State public var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var searchText = ""
    @State public var selectedDestination: MKMapItem?
    @State public var route: MKRoute?
    @State public var routeErrorMessage: String?
    @State public var selectedMode: TransportMode = .aPe // Certifique-se que o enum tem case .aPe
    @State public var isNavigating: Bool = false
    @State public var tripResult: TripResult? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MAPA
            Map(position: $camera, selection: $selectedDestination) {
                
                UserAnnotation()
                
                if !isNavigating {
                    ForEach(LocationItem.allLocations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            AnnotationButton(icon: location.icon) {
                                selectDestination(name: location.name, coordinate: location.coordinate)
                            }
                        }
                    }
                }
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            // CONTROLES DO MAPA
            .mapControls {
                if !isNavigating {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
            
            // OVERLAY SUPERIOR (Busca e Filtro)
            .safeAreaInset(edge: .top) {
                if !isNavigating {
                    VStack(spacing: 12) {
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            TextField("Pesquisar local...", text: $searchText)
                                .onSubmit { performSearch() }
                            
                            if !searchText.isEmpty {
                                Button("", systemImage: "xmark.circle.fill") {
                                    clearRoute()
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        
                        Picker("Transporte", selection: $selectedMode) {
                            ForEach(TransportMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .onChange(of: selectedMode) {
                            if selectedDestination != nil {
                                calculateRoute()
                            }
                        }
                    }
                    .padding()
                }
            }
            
            .safeAreaInset(edge: .bottom) {
                if isNavigating, let route = route, let result = tripResult {
                    
                    // --- MODO: NAVEGAÇÃO ATIVA ---
                    // Usamos o componente separado aqui
                    NavigationStatusView(
                        destinationName: selectedDestination?.name ?? "Destino",
                        route: route,
                        tripResult: result,
                        currentProgress: getCurrentProgress(), // Função auxiliar que calcula %
                        formatDistance: formatDistance,
                        onStop: stopNavigation
                    )
                    
                } else if let route = route, let result = tripResult {
                    
                    // --- MODO: PREVIEW DA ROTA ---
                    // Se a RouteInfoBar já mostra os resultados, não precisa repetir o TripResultBar
                    VStack(spacing: 0) {
                        RouteInfoBar(
                            route: route,
                            mode: selectedMode,
                            onCancel: cancelRoute,
                            onStartNavigation: startNavigation,
                            result: result
                        )
                    }
                    
                } else if let message = routeErrorMessage {
                    NoRouteInfoBar(message: message)
                }
            }
        }
        .onChange(of: selectedDestination) {
            if selectedDestination != nil {
                calculateRoute()
            }
        }
    }
    
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
}

#Preview {
    MapView()
}
