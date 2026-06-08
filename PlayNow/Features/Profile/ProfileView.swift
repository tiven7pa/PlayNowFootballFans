import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var editing = false
    @State private var editingName = ""
    @State private var resetDialog = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Profile")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(AppPalette.textPrimary)

                profileCard
                favoriteLeagueCard
                resetCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .onAppear { viewModel.refresh() }
        .alert("Display name", isPresented: $editing) {
            TextField("Display name", text: $editingName)
            Button("Save") { viewModel.saveName(editingName) }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Reset simulator?", isPresented: $resetDialog) {
            Button("Reset", role: .destructive) { viewModel.resetBalance() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your virtual balance will return to \(AppPreferences.defaultBalance) W.")
        }
    }

    private var profileCard: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.displayName)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                Text("Balance: \(viewModel.balance) W")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
            Button(action: {
                editingName = viewModel.displayName
                editing = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppPalette.accent, AppPalette.blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var favoriteLeagueCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            cardHeader(icon: "soccerball", title: "Favorite league")
            Text(viewModel.favoriteLeague?.name ?? "Premier League")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppPalette.textPrimary)
            VStack(spacing: 6) {
                ForEach(FootballCatalog.popularLeagues) { league in
                    let selected = league.id == viewModel.favoriteLeagueId
                    HStack {
                        Text(league.name)
                            .font(.system(size: 13, weight: selected ? .semibold : .regular))
                            .foregroundColor(selected ? AppPalette.accentDark : AppPalette.textPrimary)
                        Spacer()
                        Text(league.country)
                            .font(.system(size: 11))
                            .foregroundColor(AppPalette.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(selected ? AppPalette.accentSoft : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture { viewModel.selectLeague(league.id) }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var resetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            cardHeader(icon: "arrow.clockwise", title: "Reset simulator")
            Text("Bring your virtual balance back to \(AppPreferences.defaultBalance) W and clear history.")
                .font(.system(size: 12))
                .foregroundColor(AppPalette.textSecondary)
            Button(action: { resetDialog = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    Text("Reset balance")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppPalette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func cardHeader(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppPalette.accentDark)
                .frame(width: 36, height: 36)
                .background(AppPalette.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 11))
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppPalette.accentDark)
        }
    }
}
