//
//  PodiumItemView.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 17/12/25.
//

import SwiftUI

struct RibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width , y: rect.height + 10))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height - 2))
        path.addLine(to: CGPoint(x: 0, y: rect.height + 10))
        path.closeSubpath()
        return path
    }
}

struct PodiumItemView: View {
    let user: RankingUser
    let scale: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: -12) {
                
                Text(user.name)
                    .font(.system(size: 18 * scale, weight: .medium, design: .default))
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 90 * scale)
                    .minimumScaleFactor(0.7)
                    .offset(y: -30 * scale)
                
                ZStack(alignment: .topLeading) {
                    Circle()
                        .fill(Color.podiumBackground)
                        .frame(width: 80 * scale, height: 80 * scale)
                        .overlay(
                            Circle()
                                .stroke(Color.podiumGray, lineWidth: 7)
                        )
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white, .greenHighlight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26 * scale, height: 26 * scale)
                        .overlay(
                            Text("\(user.position)")
                                .font(.system(size: 14 * scale, weight: .bold))
                                .foregroundColor(.darkGreenGradient) // #1D350F
                        )
                        .shadow(radius: 2)
                        .offset(x: -5, y: -5)
                }
                .zIndex(1)
                
                ZStack(alignment: .bottom) {
                    RibbonShape()
                        .fill(Color.podiumGray)
                        .frame(width: 60 * scale, height: 75 * scale)
                    
                    Text("\(user.points)")
                        .font(.system(size: 17 * scale, weight: .bold))
                        .foregroundColor(.greenHighlight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(width: 54 * scale)
                        .padding(.bottom, 15 * scale)
                }
                .offset(y: -20 * scale)
            }.padding(.top, 40)
        }
    }
}

struct TopThreeView: View {
    let users: [RankingUser]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            
            if users.count >= 2 {
                PodiumItemView(user: users[1], scale: 1.0)
            }
            
            if let first = users.first {
                PodiumItemView(user: first, scale: 1.3)
                    .offset(y: -35)
            }
            
            if users.count >= 3 {
                PodiumItemView(user: users[2], scale: 1.0)
            }
        }
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
}
