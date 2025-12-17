import SwiftUI

struct Ranking: View {
    @StateObject private var vm: RankingViewModel
    
    init(currentUserId: UUID) {
        let service = UserService(baseURL: "https://pegada-backend-production.up.railway.app/api")
        _vm = StateObject(
            wrappedValue: RankingViewModel(
                userService: service,
                currentUserId: currentUserId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.headerDark
                    .ignoresSafeArea()
                
                if vm.ranking.isEmpty {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        
                        VStack(spacing: 0) {
                            
                            let top3 = Array(vm.ranking.prefix(3))
                            TopThreeView(users: top3)
                            
                            LazyVStack(spacing: 12) {
                                
                                let listUsers = Array(vm.ranking.dropFirst(3))
                                
                                ForEach(Array(listUsers.enumerated()), id: \.element.userId) { index, user in
                                    
                                    let rowColor = index % 2 == 0 ? Color.cardGrayBright : Color.cardGrayDark
                                    
                                    RankingRow(
                                        user: user,
                                        isCurrentUser: user.userId == vm.currentUserId,
                                        backgroundColor: rowColor
                                    )
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 100)
                        }.background(LinearGradient(
                            colors: [
                                .darkGreenGradient,
                                .backgroundGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    }
                }
                
                if let position = vm.currentUserPosition {
                    VStack {
                        Spacer()
                        BottomPositionView(position: position)
                    }
                }
            }
            .navigationTitle("Ranking")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.headerDark, for: .navigationBar)
            .onAppear {
                vm.loadRanking()
            }
        }
    }
}

#Preview {
    Ranking(currentUserId: UUID())
}
