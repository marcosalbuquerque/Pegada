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

struct BottomPositionView: View {

    let position: Int

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)

                Text("Seu lugar:")
                    .font(.headline)

                Text("\(position)º")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}


// MARK: - Ranking Row
struct RankingRow: View {

    let user: RankingUser
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 16) {

            Text("\(user.position)")
                .font(.headline)
                .frame(width: 30)
                .foregroundColor(positionColor)

            Circle()
                .fill(isCurrentUser ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(user.initials)
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .green : .primary)

                Text("\(user.points) pontos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if user.position <= 3 {
                Image(systemName: medalIcon)
                    .font(.title2)
                    .foregroundColor(positionColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrentUser ? Color.green.opacity(0.12) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCurrentUser ? Color.green : Color.clear, lineWidth: 1)
        )
    }

    private var positionColor: Color {
        switch user.position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }

    private var medalIcon: String {
        switch user.position {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return ""
        }
    }
}

// MARK: - Preview
#Preview {
    Ranking(currentUserId: UUID())
}
