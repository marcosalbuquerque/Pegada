//
//  RouteResumeCard.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 17/12/25.
//

import SwiftUI

// 1. Modelo de Dados para centralizar tudo
struct RouteSummary {
    let distance: String
    let pace: String
    let duration: String // Ex: "1h30"
    let result: TripResult // Puxa os dados calculados no mapa
    
    var co2SavedText: String {
        let grams = result.carbonSavedGrams
        if grams >= 1000 {
            return String(format: "%.1f kg", grams / 1000)
        } else {
            return "\(Int(grams)) g"
        }
    }
    // Calculado automaticamente para o card de árvores
    var treesEquivalence: Int {
        // Exemplo: cada 1500g de CO2 = 1 árvore (ajuste conforme sua regra)
        Int(result.carbonSavedGrams / 1500)
    }
}

struct RouteResumeCard: View {
    // 2. Único lugar para mudar os valores
    let summary: RouteSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                MetricBox(title: "Distância", value: summary.distance, unit: "km")
                MetricBox(title: "Pace", value: summary.pace, unit: "/km")
                // Chamada de tempo (ele usa o init especial)
                                MetricBox(title: "Tempo", time: summary.duration)
            }
            
            Text("Impacto")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            ImpactCard(
                co2: summary.co2SavedText, // ex: "4.675 G"
                trees: summary.treesEquivalence,
                mode: summary.result.mode, // Puxa .aPe, .bicicleta, etc.
                points: summary.result.pointsEarned
            )
            
            HStack(spacing: 16) {
                ActionButton(title: "Copiar", systemImage: "doc.on.doc") {
                    // Lógica para copiar
                }
                
                ActionButton(title: "Salvar", systemImage: "square.and.arrow.down") {
                    // Lógica para salvar imagem
                }
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

#Preview {
    let mockResult = TripResult(
        distanceKm: 4.2,
        mode: .aPe,
        carbonSavedGrams: 4675,
        pointsEarned: 103
    )
    
    let mockSummary = RouteSummary(
        distance: "4.2",
        pace: "4:30",
        duration: "1h30",
        result: mockResult
    )
    
    RouteResumeCard(summary: mockSummary)
}

///// Calcula o Pace (min/km) a partir de uma rota e do modo de transporte
//    func calculatePace(route: MKRoute) -> String {
//        let adjustedTimeSeconds = route.expectedTravelTime * selectedMode.timeMultiplier
//        let distanceKm = route.distance / 1000.0
//
//        guard distanceKm > 0 else { return "0:00" }
//
//        // Pace total em minutos decimais (ex: 4.5 para 4:30)
//        let paceDecimal = (adjustedTimeSeconds / 60.0) / distanceKm
//
//        let minutes = Int(paceDecimal)
//        let seconds = Int((paceDecimal - Double(minutes)) * 60)
//
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    /// Formata o tempo para o padrão "1h30" ou "45min" exigido pelo TimeValueView
//    func formatDuration(route: MKRoute) -> String {
//        let adjustedTime = route.expectedTravelTime * selectedMode.timeMultiplier
//        let totalMinutes = Int(adjustedTime / 60)
//
//        if totalMinutes < 60 {
//            return "\(totalMinutes)min"
//        } else {
//            let h = totalMinutes / 60
//            let m = totalMinutes % 60
//            // Retorna no formato "1h30" (o TimeValueView faz o parse pelo 'h')
//            return m == 0 ? "\(h)h" : "\(h)h\(m)"
//        }
//    }
//
//    /// Função para gerar o objeto final que o Card de Resumo vai usar
//    func createSummary() -> RouteSummary? {
//        guard let route = self.route, let result = self.tripResult else { return nil }
//
//        return RouteSummary(
//            distance: String(format: "%.1f", route.distance / 1000),
//            pace: calculatePace(route: route),
//            duration: formatDuration(route: route),
//            result: result
//        )
//    }
//// Adicione isso ao MapView
//@State private var finalSummary: RouteSummary?
//
//// No local onde você finaliza a viagem:
//func finishTrip() {
//    self.finalSummary = createSummary()
//    // Aqui você pode disparar um .sheet ou mudar um @State para mostrar o RouteResumeCard
//}
