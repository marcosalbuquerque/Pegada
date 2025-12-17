//
//  ShareViewModel.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//


import Combine
import UIKit
import SwiftUI

@MainActor
final class ShareViewModel: ObservableObject {
    
    func generateShareImage() -> UIImage {
        let shareView = ImageShare()
        let renderer = ImageRenderer(content: shareView)
        renderer.isOpaque = false

        if let uiImage = renderer.uiImage {
            return uiImage
        }

        let fallback = UIImage(named: "test_share") ?? UIImage()
        return  fallback
    }
}
