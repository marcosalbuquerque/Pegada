//
//  ImageDownloadService.swift
//  Pegada
//
//  Created by Filipi Romão on 17/12/25.
//

import Foundation
import UIKit

private func downloadImageData(url: String) async -> Data? {
    guard let url = URL(string: url) else { return nil }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    } catch {
        print("Erro ao baixar imagem: \(error.localizedDescription)")
        return nil
    }
}

func loadUiImage(url: String) async -> UIImage {
    // Tenta baixar os dados da imagem
    if let data = await downloadImageData(url: url),
       let image = UIImage(data: data) {
        return image
    }
    
    // Se falhar, retorna uma imagem vazia
    return UIImage()
}

