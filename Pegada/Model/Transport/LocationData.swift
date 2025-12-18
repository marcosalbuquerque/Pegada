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
        LocationItem(name: "Navalha da Corte", coordinate: CLLocationCoordinate2D(latitude: -15.798010260698556, longitude: -47.887794739172534), icon: .asset(.navalhaDaCorte)),
        LocationItem(name: "Espelunca", coordinate: CLLocationCoordinate2D(latitude: -15.799212608596351, longitude: -47.88659114627791), icon: .asset(.espelunca)),
        LocationItem(name: "ProOffices", coordinate: CLLocationCoordinate2D(latitude: -15.796073387691845, longitude: -47.89030007936166), icon: .asset(.proOffices)),
        LocationItem(name: "Nicolandia", coordinate: CLLocationCoordinate2D(latitude: -15.794217661944678, longitude: -47.8986015039493), icon: .asset(.nicolandia))

        
    ]
}
