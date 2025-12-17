//
//  LocationData.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import Foundation
import CoreLocation
import SwiftUI

enum IconType {
    case system(String)
    case asset(ImageResource)
}

struct LocationItem: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let icon: IconType
    
    static let allLocations: [LocationItem] = [
        LocationItem(name: "Setor Comercial Sul", coordinate: CLLocationCoordinate2D(latitude: -15.79834, longitude: -47.8865), icon: .asset(.scs)),
        LocationItem(name: "Asa Norte, Quadra 702", coordinate: CLLocationCoordinate2D(latitude: -15.782179, longitude: -47.889442), icon: .system("building.2")),
        LocationItem(name: "Asa Norte, Quadra 706", coordinate: CLLocationCoordinate2D(latitude: -15.770412, longitude: -47.889902), icon: .system("building.2")),
        LocationItem(name: "Asa Norte, Quadra 715", coordinate: CLLocationCoordinate2D(latitude: -15.743184, longitude: -47.898986), icon: .system("building.2")),
        LocationItem(name: "Asa Norte, Quadra 716", coordinate: CLLocationCoordinate2D(latitude: -15.740174, longitude: -47.900063), icon: .system("building.2")),
        LocationItem(name: "Vila Planalto", coordinate: CLLocationCoordinate2D(latitude: -15.793300, longitude: -47.849970), icon: .asset(.vila))
    ]
}
