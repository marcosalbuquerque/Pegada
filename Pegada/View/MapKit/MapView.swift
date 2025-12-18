//
//  MapView.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData // <--- IMPORTANTE: Adicionar

struct MapView: View {
    
    // --- ADICIONADO: Contexto do Banco de Dados ---
    @Environment(\.modelContext) var modelContext
    
    @StateObject var locationManager = LocationManager()
    @State var initialStraightLineDistance: CLLocationDistance?
    let carbonCalculator = CarbonCalculatorManager()
    
    // Variáveis de Estado
    @State public var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var searchText = ""
    @State public var selectedDestination: MKMapItem?
    @State public var route: MKRoute?
    @State public var routeErrorMessage: String?
    @State public var selectedMode: TransportMode = .aPe
    @State public var isNavigating: Bool = false
    
    @State public var tripResult: TripResult? = nil
    
    // Estados Uber/Speed
    @State public var startTime: Date?
    @State public var showSuccessAlert = false
    @State public var showSpeedLimitAlert = false
    @State public var finalStats: (points: Int, carbon: Double)?
    
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
                        .onChange(of: locationManager.userLocation) {
                if isNavigating {
                    updateNavigationLogic()
                }
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

                            }
                            
                            
                        }
                        .padding()
                    }
                }
            
            .safeAreaInset(edge: .bottom) {
                if isNavigating, let route = route, let result = tripResult {
                    NavigationStatusView(
                        destinationName: selectedDestination?.name ?? "Destino",
                        route: route,
                        tripResult: result,
                        currentProgress: getCurrentProgress(),
                        formatDistance: formatDistance,
                        onStop: handleManualCancellation
                    )
                } else if let route = route, let result = tripResult {
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
            if selectedDestination != nil { calculateRoute() }
        }
        .alert("Viagem Finalizada", isPresented: $showSuccessAlert) {
            Button("OK") {
                stopNavigation()
                
            }
        } message: {
            if let stats = finalStats {
                Text("Resumo da rota:\n+ \(stats.points) Pontos\nCarbono evitado: \(Int(stats.carbon))g")
            }
        }
        .alert("Viagem Cancelada", isPresented: $showSpeedLimitAlert) {
            Button("Entendi") {
                stopNavigation()
            }
        } message: {
            Text("Detectamos uma velocidade muito alta para o modo \(selectedMode.rawValue). A viagem foi invalidada.")
        }
    }
}
