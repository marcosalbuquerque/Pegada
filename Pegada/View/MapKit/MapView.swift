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

    @StateObject private var locationManager = LocationManager()
    private let carbonCalculator = CarbonCalculatorManager()
    @State public var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var searchText = ""
    @State public var selectedDestination: MKMapItem?
    @State public var route: MKRoute?
    @State public var routeErrorMessage: String?
    @State public var selectedMode: TransportMode = .aPe
    @State public var tripResult: TripResult? = nil

    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $camera, selection: $selectedDestination) {
                
                UserAnnotation()
                
                ForEach(LocationItem.allLocations) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        AnnotationButton(icon: location.icon) {
                            selectDestination(name: location.name, coordinate: location.coordinate)
                        }
                    }
                }
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .safeAreaInset(edge: .top){
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
                        ForEach(TransportMode.allCases) {
                            Text($0.rawValue).tag($0)
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

            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
            
        }
        .onChange(of: selectedDestination) {
            if selectedDestination != nil {
                calculateRoute()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let route {
                // 4. Se a rota existe, mostra a barra de info e os resultados
                VStack(spacing: 0) {
                    RouteInfoBar(
                        route: route,
                        mode: selectedMode,
                        onCancel: cancelRoute
                    )
                    
                    // Mostra o resultado do cálculo
                    if let result = tripResult {
                        TripResultBar(result: result) // 👈 Chamando a nova barra de resultados
                    }
                }
            } else if let message = routeErrorMessage {
                NoRouteInfoBar(message: message)
            }
        }
    }
    
    // 👈 3. Novo Método para Chamar o Cálculo
        public func finalizeRoute(route: MKRoute) {
            let result = carbonCalculator.calculateImpact(
                for: selectedMode,
                distanceMeters: route.distance
            )
            self.tripResult = result
            
            // *** Aqui você enviaria 'result' para o seu ViewModel para persistência (Supabase/Banco de Dados) ***
            print("Resultado Final:")
            print("CO2 Economizado: \(result.carbonSavedGrams) g")
            print("Pontos Ganhos: \(result.pointsEarned)")
        }
}


#Preview {
    MapView()
}
