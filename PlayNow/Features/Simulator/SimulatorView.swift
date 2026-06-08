import SwiftUI

struct SimulatorView: View {
    @StateObject private var viewModel = SimulatorViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                balanceCard
                matchSection
                Text("Place a virtual bet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppPalette.accentDark)
                pickRow
                stakeField
                simulateButton
                if let result = viewModel.lastResult {
                    LastResultCard(item: result)
                }
                if !viewModel.history.isEmpty {
                    Text("History")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppPalette.accentDark)
                    ForEach(viewModel.history.prefix(15)) { item in
                        HistoryRow(item: item)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(AppPalette.background.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Text("Simulator")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(AppPalette.textPrimary)
            Spacer()
            Button(action: { viewModel.resetBalance() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(AppPalette.accentDark)
                    .frame(width: 38, height: 38)
                    .background(AppPalette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var balanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Virtual balance")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("\(viewModel.balance) W")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)
                Text("Risk-free training currency")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "wallet.pass")
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 18))
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

    private var matchSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Choose a match")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppPalette.accentDark)
                Spacer()
                Button(action: { viewModel.reroll() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 14))
                        Text("Reroll")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppPalette.accentDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppPalette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            VStack(spacing: 8) {
                ForEach(Array(viewModel.matches.enumerated()), id: \.element.id) { index, match in
                    MatchCard(match: match, selected: index == viewModel.selectedIndex)
                        .onTapGesture { viewModel.selectedIndex = index }
                }
            }
        }
    }

    private var pickRow: some View {
        HStack(spacing: 8) {
            pickButton("Home", odds: viewModel.match.oddsHome(), value: .home)
            pickButton("Draw", odds: viewModel.match.oddsDraw(), value: .draw)
            pickButton("Away", odds: viewModel.match.oddsAway(), value: .away)
        }
    }

    private func pickButton(_ label: String, odds: Double, value: SimPick) -> some View {
        let selected = viewModel.pick == value
        return VStack(spacing: 2) {
            Text(label)
            Text(String(format: "%.2f", odds))
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(selected ? .white : AppPalette.accentDark)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(selected ? AppPalette.accent : AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture { viewModel.pick = value }
    }

    private var stakeField: some View {
        TextField("Stake (W)", text: $viewModel.stakeText)
            .keyboardType(.numberPad)
            .font(.system(size: 15))
            .padding(14)
            .background(AppPalette.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppPalette.accentSoft, lineWidth: 1)
            )
            .onChange(of: viewModel.stakeText) { value in
                let filtered = String(value.filter { $0.isNumber }.prefix(6))
                if filtered != value { viewModel.stakeText = filtered }
            }
    }

    private var simulateButton: some View {
        Button(action: { viewModel.simulate() }) {
            Text(viewModel.rolling ? "Simulating..." : "Simulate match")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.canSimulate ? AppPalette.accent : AppPalette.accent.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canSimulate)
    }
}

private struct MatchCard: View {
    let match: SimMatch
    let selected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(match.home) vs \(match.away)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppPalette.textPrimary)
                Text("Strength \(match.homeStrength) — \(match.awayStrength)")
                    .font(.system(size: 11))
                    .foregroundColor(AppPalette.textMuted)
            }
            Spacer()
            Text("\(odds(match.oddsHome())) • \(odds(match.oddsDraw())) • \(odds(match.oddsAway()))")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppPalette.accentDark)
        }
        .padding(14)
        .background(selected ? AppPalette.accentSoft : AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func odds(_ value: Double) -> String { String(format: "%.2f", value) }
}

private struct LastResultCard: View {
    let item: SimHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.won ? "WIN! +\(item.payoff) W" : "Lost \(item.stake) W")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(item.won ? AppPalette.green : AppPalette.red)
            Text(item.description)
                .font(.system(size: 12))
                .foregroundColor(AppPalette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background((item.won ? AppPalette.green : AppPalette.red).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct HistoryRow: View {
    let item: SimHistoryItem

    var body: some View {
        HStack {
            Circle()
                .fill(item.won ? AppPalette.green : AppPalette.red)
                .frame(width: 8, height: 8)
            Text(item.description)
                .font(.system(size: 12))
                .foregroundColor(AppPalette.textPrimary)
                .lineLimit(1)
            Spacer()
            Text(item.won ? "+\(item.payoff)" : "-\(item.stake)")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(item.won ? AppPalette.green : AppPalette.red)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
