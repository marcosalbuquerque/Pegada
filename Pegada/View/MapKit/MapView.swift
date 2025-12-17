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
    let carbonCalculator = CarbonCalculatorManager()
    
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
}

#Preview {
    MapView()
}
