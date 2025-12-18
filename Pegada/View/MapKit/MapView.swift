//
//  MapView.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import UIKit

struct MapView: View {
    
    // MARK: - Environment & StateObjects
    @Environment(\.modelContext) var modelContext
    
    @StateObject private var shareViewModel = ShareViewModel()
    @StateObject var locationManager = LocationManager()
    
    let carbonCalculator = CarbonCalculatorManager()
    
    // MARK: - Map States
    @State public var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var selectedDestination: MKMapItem?
    @State public var searchText = ""
    @State var initialStraightLineDistance: CLLocationDistance?
    
    // Route States
    @State public var route: MKRoute?
    @State public var routeErrorMessage: String?
    @State public var selectedMode: TransportMode = .aPe
    @State public var isNavigating: Bool = false
    @State public var tripResult: TripResult? = nil
    
    // Logic States
    @State public var startTime: Date?
    
    // MARK: - Popup & Alert States
    @State public var showSuccessAlert = false
    
    // REVERTIDO: Voltamos para apenas Points e Carbon (removido distance/time)
    @State public var finalStats: (points: Int, carbon: Double)?
    
    @State public var showSpeedLimitAlert = false
    
    // MARK: - Share Sheet States
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage? = nil
    
    // MARK: - Subviews
    @ViewBuilder
    private var mapContent: some View {
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
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .mapControls {
            if !isNavigating {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
        }
        .onAppear { locationManager.requestLocationPermission() }
        .onChange(of: locationManager.userLocation) {
            if isNavigating { updateNavigationLogic() }
        }
    }

    @ViewBuilder
    private var topOverlay: some View {
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
                        Button("", systemImage: "xmark.circle.fill") { clearRoute() }
                    }
                }
                .padding()
                .clipShape(Capsule())
                .background(.ultraThinMaterial)
                .cornerRadius(200)
                .overlay(Capsule().stroke(Color.greenHighlight, lineWidth: 1.5))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TransportMode.allCases) { mode in
                            TransportModeItem(mode: mode, isSelected: selectedMode == mode) {
                                selectedMode = mode
                                if selectedDestination != nil { calculateRoute() }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var bottomOverlay: some View {
        if isNavigating, let route, let result = tripResult {
            NavigationStatusView(
                destinationName: selectedDestination?.name ?? "Destino",
                route: route,
                tripResult: result,
                currentProgress: getCurrentProgress(),
                formatDistance: formatDistance,
                onStop: handleManualCancellation
            )
        } else if let route, let result = tripResult {
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

    @ViewBuilder
    private var finishPopup: some View {
        if showSuccessAlert, let stats = finalStats {
            TripFinishPopup(
                points: stats.points,
                carbon: stats.carbon,
                onShare: handleShare,
                onClose: {
                    withAnimation { showSuccessAlert = false }
                    stopNavigation()
                }
            )
            .zIndex(100)
        }
    }

    private func handleShare() {
        // Tarefa Assíncrona para gerar imagem
        Task {
            // 1. Gera Snapshot do Mapa
            let mapSnapshot = await shareViewModel.generateMapSnapshot(for: self.route)
            
            // 2. Gera a imagem final (sem pedir distância/tempo)
            self.imageToShare = shareViewModel.generateShareImage(
                mapImage: mapSnapshot,
                points: finalStats?.points ?? 0,
                carbon: finalStats?.carbon ?? 0.0
            )
            
            // 3. Abre o Sheet
            self.showShareSheet = true
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            mapContent
                .safeAreaInset(edge: .top) { topOverlay }
                .safeAreaInset(edge: .bottom) { bottomOverlay }
            finishPopup
        }
        .onChange(of: selectedDestination) { if selectedDestination != nil { calculateRoute() } }
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ActivityViewFallback(items: [image, "Acabei de economizar CO2 com o app Pegada! 🌿 #Sustentabilidade"])
                    .presentationDetents([.medium, .large])
            } else {
                ProgressView("Gerando imagem...")
                    .presentationDetents([.medium])
            }
        }
        .alert("Viagem Cancelada", isPresented: $showSpeedLimitAlert) {
            Button("Entendi") { stopNavigation() }
        } message: {
            Text("Detectamos uma velocidade muito alta para o modo \(selectedMode.rawValue). A viagem foi invalidada.")
        }
    }
    
    // Helper simples para UIActivityViewController
    private struct ActivityViewFallback: UIViewControllerRepresentable {
        let items: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
