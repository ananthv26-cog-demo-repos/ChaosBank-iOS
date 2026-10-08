//
//  LevelUpSavingsView.swift
//  ChaosBank
//
//  Happen Bank deposit-account detail (LevelUp Savings / Checking).
//

import SwiftUI

struct LevelUpSavingsView: View {
    let account: HappenDepositAccount

    @Environment(\.dismiss) private var dismiss
    @State private var showDetails = false
    @State private var showTransfer = false
    @State private var showAddMoney = false

    private var activity: [HappenActivity] { HappenSeed.activity(for: account) }

    var body: some View {
        content
            .environment(\.colorScheme, .light)
            .background(HappenColor.background.ignoresSafeArea())
            .accessibilityIdentifier(A11y.AccountDetail.root)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 19, weight: .regular))
                    }
                    .tint(HappenColor.ink)
                    .accessibilityLabel("Back")
                    .accessibilityIdentifier(A11y.AccountDetail.back)
                }
                ToolbarItem(placement: .principal) {
                    Text("\(account.product) \(account.maskedNumber)")
                        .font(.happen(17, .semibold))
                        .foregroundStyle(HappenColor.ink)
                        .accessibilityIdentifier(A11y.AccountDetail.title)
                }
            }
            .happenChrome()
            .sheet(isPresented: $showTransfer) {
                if LaunchOptions.current.uiKit { UIKitTransferView() } else { TransferView() }
            }
            .sheet(isPresented: $showAddMoney) { AddMoneyView() }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HappenOfflineBanner()
                balanceHeader
                if account.earnsLevelUpRate {
                    depositGoalCard(HappenSeed.savingsGoal)
                        .padding(.horizontal, 20)
                }
                actions
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                activityHeader
                ForEach(activity) { item in
                    activityRow(item)
                    HappenHairline()
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var balanceHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Available Balance")
                .font(.happen(15))
                .foregroundStyle(HappenColor.ink)
            Text(HappenFormat.usd(account.balance))
                .font(.happen(34, .semibold))
                .foregroundStyle(HappenColor.ink)
                .accessibilityIdentifier(A11y.AccountDetail.balance)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private func depositGoalCard(_ goal: HappenDepositGoal) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            LevelUpPill()
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(goal.month) Deposits")
                        .font(.happen(16, .semibold))
                        .foregroundStyle(HappenColor.ink)
                    Text("as of \(goal.asOf)")
                        .font(.happen(12))
                        .foregroundStyle(HappenColor.inkSecondary)
                }
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showDetails.toggle() }
                } label: {
                    HStack(spacing: 6) {
                        Text("Details").font(.happen(15, .semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .rotationEffect(.degrees(showDetails ? 180 : 0))
                    }
                    .foregroundStyle(HappenColor.blueText)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11y.AccountDetail.detailsToggle)
            }
            .padding(.top, 12)

            if showDetails {
                Text(goal.detail)
                    .font(.happen(13))
                    .foregroundStyle(HappenColor.inkSecondary)
                    .padding(.top, 8)
                    .transition(.opacity)
            }

            Text("\(HappenFormat.usd(goal.total)) total")
                .font(.happen(15, .semibold))
                .foregroundStyle(HappenColor.green)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 6)
            progressBar(goal.progress)
                .padding(.top, 6)
                .accessibilityIdentifier(A11y.AccountDetail.progress)

            HStack(alignment: .center, spacing: 12) {
                Text(goal.message)
                    .font(.happen(13))
                    .foregroundStyle(HappenColor.ink)
                Spacer(minLength: 0)
                Button {} label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(HappenColor.blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(HappenColor.blue, lineWidth: 1.25)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("LevelUp Rate details")
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(HappenColor.sandCard, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(HappenColor.hairline, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11y.AccountDetail.levelUpCard)
    }

    private func progressBar(_ fraction: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(HappenColor.track)
                Capsule().fill(HappenColor.progress)
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: 8)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            HappenActionChip(title: "Transfer", a11y: A11y.AccountDetail.actionTransfer, action: { showTransfer = true }) {
                Image(systemName: "arrow.left.arrow.right").font(.system(size: 15))
            }
            HappenActionChip(title: "Deposit", a11y: A11y.AccountDetail.actionDeposit, action: { showAddMoney = true }) {
                HappenDepositIcon(size: 16)
            }
            HappenActionChip(title: "More", a11y: A11y.AccountDetail.actionMore, action: {}) {
                Image(systemName: "ellipsis").font(.system(size: 15, weight: .semibold))
            }
        }
    }

    private var activityHeader: some View {
        HStack {
            Text("Details")
            Spacer()
            Text("Amount")
        }
        .font(.happen(13))
        .foregroundStyle(HappenColor.inkSecondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(HappenColor.sand)
    }

    private func activityRow(_ item: HappenActivity) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.happen(16))
                    .foregroundStyle(HappenColor.ink)
                Text(item.date)
                    .font(.happen(14))
                    .foregroundStyle(HappenColor.inkSecondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 4) {
                Text(HappenFormat.signedUSD(item.amount))
                    .font(.happen(16, .semibold))
                    .foregroundStyle(item.amount < 0 ? HappenColor.ink : HappenColor.green)
                Text(HappenFormat.usd(item.runningBalance))
                    .font(.happen(13))
                    .foregroundStyle(HappenColor.inkSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11y.AccountDetail.row(item.id))
    }
}
