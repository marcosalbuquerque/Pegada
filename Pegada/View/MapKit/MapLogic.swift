//
//  MapLogic.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit
import SwiftUI

extension MapView {

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

}
