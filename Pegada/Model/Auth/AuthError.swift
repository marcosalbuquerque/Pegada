//
//  AuthError.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//
import Foundation


enum AuthError: LocalizedError {
    case invalidAppleToken
    case profileNotFound
    case profileNotSaved

    var errorDescription: String? {
        switch self {
        case .invalidAppleToken:
            return "Token da Apple inválido."
        case .profileNotFound:
            return "Perfil não encontrado no servidor."
        case .profileNotSaved:
            return "Falha ao salvar perfil localmente."
        }
    }
}
