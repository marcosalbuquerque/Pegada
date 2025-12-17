//
//  Saudation.swift
//  Pegada
//
//  Created by Linda Marie Ribeiro Alves Correa dos Santos on 17/12/25.
//
import SwiftUI

enum PeriodoDoDia {
    case manha, tarde, noite

    var texto: String {
        switch self {
        case .manha: return "Bom dia"
        case .tarde: return "Boa tarde"
        case .noite: return "Boa noite"
        }
    }
}

func periodoAtual() -> PeriodoDoDia {
    let hora = Calendar.current.component(.hour, from: Date())

    if hora >= 5 && hora < 12 {
        return .manha
    } else if hora < 18 {
        return .tarde
    } else {
        return .noite
    }
}
