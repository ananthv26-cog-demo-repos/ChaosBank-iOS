//
//  HomeView.swift
//  ChaosBank
//
//  Happen Bank home: greeting, quick actions, deposit accounts and loans.
//

import SwiftUI

struct HomeView: View {
    @State private var showTransfer = false
    @State private var showAddMoney = false
    @State private var showPay = false
    @State private var showExchange = false

    var body: some View {
        content
            .environment(\.colorScheme, .light)
            .background(HappenColor.background.ignoresSafeArea())
            .accessibilityIdentifier(A11y.Home.root)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .happenChrome()
            .navigationDestination(for: HappenDepositAccount.self) { account in
                LevelUpSavingsView(account: account)
            }
            .sheet(isPresented: $showTransfer) {
                if LaunchOptions.current.uiKit { UIKitTransferView() } else { TransferView() }
            }
            .sheet(isPresented: $showExchange) {
                if LaunchOptions.current.uiKit { UIKitExchangeView() } else { ExchangeView() }
            }
            .sheet(isPresented: $showAddMoney) { AddMoneyView() }
            .sheet(isPresented: $showPay) { NavigationStack { LoansView() } }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HappenOfflineBanner()
                header
                quickActions
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                HappenBand().padding(.top, 28)
                depositSection
                HappenBand()
                loanSection
                HappenBand()
                Text("Demo app with synthetic data. Not affiliated with Happen Bank.")
                    .font(.happen(12))
                    .foregroundStyle(HappenColor.inkSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            }
        }
        .scrollIndicators(.hidden)
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {} label: {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 25, weight: .light))
            }
            .tint(HappenColor.ink)
            .accessibilityLabel("Help")
            .accessibilityIdentifier(A11y.Home.help)

            Button {} label: {
                Image(systemName: "person")
                    .font(.system(size: 23, weight: .light))
            }
            .tint(HappenColor.ink)
            .accessibilityLabel("Profile")
            .accessibilityIdentifier(A11y.Home.profile)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("HappenMark")
                .resizable()
                .scaledToFit()
                .frame(height: 34)
                .accessibilityLabel("Happen Bank")
                .padding(.top, 8)
            Text("\(greetingPrefix), \(HappenSeed.firstName)")
                .font(.happen(26, .bold))
                .foregroundStyle(HappenColor.greeting)
                .padding(.top, 14)
                .accessibilityIdentifier(A11y.Home.greeting)
            Text("How would you like to get started?")
                .font(.happen(16))
                .foregroundStyle(HappenColor.inkSecondary)
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
    }

    private var greetingPrefix: String {
        switch Calendar.current.component(.hour, from: .now) {
        case ..<12: "Good morning"
        case ..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            HappenQuickAction(title: "Transfer", a11y: A11y.Home.quickActionTransfer, action: openTransfer) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 22, weight: .regular))
            }
            HappenQuickAction(title: "Deposit", a11y: A11y.Home.quickActionAddMoney, action: { showAddMoney = true }) {
                HappenDepositIcon()
            }
            HappenQuickAction(title: "Pay", a11y: A11y.Home.quickActionPay, action: { showPay = true }) {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 25, weight: .regular))
            }
        }
    }

    /// `quickActionTransferOpensExchange` wires Transfer to the Exchange sheet.
    private func openTransfer() {
        if Defects.isActive(.quickActionTransferOpensExchange) { showExchange = true } else { showTransfer = true }
    }

    private var depositSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Checking, Savings & CD")
            ForEach(Array(HappenSeed.depositAccounts.enumerated()), id: \.element.id) { index, account in
                if index > 0 { HappenHairline().padding(.leading, 20) }
                NavigationLink(value: account) {
                    accountRow(
                        balance: account.balance,
                        product: account.product,
                        mask: account.maskedNumber,
                        levelUp: account.earnsLevelUpRate
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11y.Home.depositAccount(account.id))
            }
        }
    }

    private var loanSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Personal Loans")
            ForEach(HappenSeed.loans) { loan in
                Button { showPay = true } label: {
                    accountRow(
                        balance: loan.balance,
                        product: loan.product,
                        mask: "...\(loan.mask)",
                        levelUp: false,
                        footnote: "Next payment \(HappenFormat.usd(loan.nextPayment)) due \(loan.dueDate)"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11y.Home.loanAccount(loan.id))
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.happen(20, .semibold))
            .foregroundStyle(HappenColor.ink)
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .accessibilityAddTraits(.isHeader)
    }

    private func accountRow(balance: Decimal, product: String, mask: String, levelUp: Bool, footnote: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                if levelUp {
                    LevelUpPill().padding(.bottom, 10)
                }
                Text(HappenFormat.usd(balance))
                    .font(.happen(30, .semibold))
                    .foregroundStyle(HappenColor.ink)
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(product).font(.happen(17))
                    Text(mask).font(.happen(15))
                }
                .foregroundStyle(HappenColor.ink)
                .padding(.top, 4)
                if let footnote {
                    Text(footnote)
                        .font(.happen(14))
                        .foregroundStyle(HappenColor.inkSecondary)
                        .padding(.top, 6)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(HappenColor.inkSecondary)
                .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .contentShape(Rectangle())
    }
}
