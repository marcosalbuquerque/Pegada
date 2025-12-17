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
                        .stroke(
                            .greenHighlight,
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                }
            }.preferredColorScheme(.dark)
            
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            Color.greenHighlight.opacity(0.15)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            
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
                            
                            HStack{
                                Text("\(periodoAtual().texto), Epsilon")
                                    .font(.largeTitle)
                                    .bold()
                                
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.greenHighlight)
                                
                                TextField("Pesquisar local...", text: $searchText)
                                    .onSubmit { performSearch() }
                                
                                if !searchText.isEmpty {
                                    Button("", systemImage: "xmark.circle.fill") {
                                        clearRoute()
                                    }
                                }
                            }
                            .padding()
                            .clipShape(Capsule())
                            .background(.ultraThinMaterial)
                            .cornerRadius(200)
                            .overlay(
                                Capsule()
                                    .stroke(Color.greenHighlight, lineWidth: 1.5)
                                
                            )
                            
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(TransportMode.allCases) { mode in
                                        TransportModeItem(
                                            mode: mode,
                                            isSelected: selectedMode == mode
                                        ) {
                                            selectedMode = mode
                                            if selectedDestination != nil {
                                                calculateRoute()
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
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
