//
//  ShareViewModel.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import Combine
import UIKit
import SwiftUI
import MapKit

@MainActor
final class ShareViewModel: ObservableObject {
    
    // 1. Gera a imagem final (Combina tudo)
    func generateShareImage(mapImage: UIImage?, points: Int, carbon: Double) -> UIImage {
        let shareView = ImageShare(
            mapImage: mapImage,
            carbonSaved: carbon,
            pointsEarned: points
        )
        
        let renderer = ImageRenderer(content: shareView)
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage ?? UIImage()
    }
    
    // 2. Gera a imagem do MAPA separadamente (Snapshot)
    func generateMapSnapshot(for route: MKRoute?) async -> UIImage? {
        guard let route = route else { return nil }
        
        let options = MKMapSnapshotter.Options()
        let rect = route.polyline.boundingMapRect
        let region = MKCoordinateRegion(rect)
        // Zoom out leve para a rota não colar na borda
        let span = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 1.4, longitudeDelta: region.span.longitudeDelta * 1.4)
        
        options.region = MKCoordinateRegion(center: region.center, span: span)
        options.size = CGSize(width: 320, height: 320) // Tamanho compatível com o card
        options.scale = UIScreen.main.scale
        options.mapType = .mutedStandard
        options.traitCollection = UITraitCollection(userInterfaceStyle: .dark) // Força modo dark

        let snapshotter = MKMapSnapshotter(options: options)

        do {
            let snapshot = try await snapshotter.start()
            let image = snapshot.image

            // 3. Desenha a linha da rota sobre a imagem do mapa
            let finalImage = UIGraphicsImageRenderer(size: options.size).image { context in
                image.draw(at: .zero)

                let path = UIBezierPath()
                let points = route.polyline.points()
                let pointCount = route.polyline.pointCount

                if pointCount > 0 {
                    let firstCoordinate = points[0].coordinate
                    let firstPoint = snapshot.point(for: firstCoordinate)
                    path.move(to: firstPoint)

                    for i in 1..<pointCount {
                        let coordinate = points[i].coordinate
                        let point = snapshot.point(for: coordinate)
                        path.addLine(to: point)
                    }
                }

                // Cor da Linha (Verde Highlight)
                let color = UIColor(red: 0.74, green: 0.89, blue: 0.35, alpha: 1.0)
                color.setStroke()
                
                path.lineWidth = 6
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.stroke()
            }
            return finalImage
        } catch {
            print("Erro ao gerar snapshot do mapa: \(error)")
            return nil
        }
    }
}
