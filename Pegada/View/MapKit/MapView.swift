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

    @State public var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var searchText = ""
    @State public var selectedDestination: MKMapItem?
    @State public var route: MKRoute?
    @State public var routeErrorMessage: String?
    @State public var selectedMode: TransportMode = .aPe

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
                RouteInfoBar(
                    route: route,
                    mode: selectedMode,
                    onCancel: cancelRoute
                )
            } else if let message = routeErrorMessage {
                NoRouteInfoBar(message: message)
            }
        }

    }
}


#Preview {
    MapView()
}
