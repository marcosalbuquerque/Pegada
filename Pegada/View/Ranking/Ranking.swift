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
                List {
                    ForEach(vm.ranking) { user in
                        RankingRow(
                            user: user,
                            isCurrentUser: user.userId == vm.currentUserId
                        )
                        .listRowSeparator(.hidden)
                    }

                    Color.clear
                        .frame(height: 80)
                }
                .listStyle(.plain)
                .navigationTitle("Ranking Pegada")
                .onAppear {
                    vm.loadRanking()
                }

                if let position = vm.currentUserPosition {
                    BottomPositionView(position: position)
                }
            }
        }
    }
}

#Preview {
    Ranking(currentUserId: UUID())
}
