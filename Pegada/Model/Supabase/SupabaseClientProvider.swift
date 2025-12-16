//
//  SupabaseClientProvider.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import Foundation
import Supabase


enum SupabaseConfig {
    static let url = URL(string: "https://aqalsvepdzybocajcesn.supabase.co")!
    static let anonKey = "sb_publishable_UmLM-t9cIeG1Kyd7AoGJCQ_6h0jiRGe"
}

final class SupabaseClientProvider {
    static let shared = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
