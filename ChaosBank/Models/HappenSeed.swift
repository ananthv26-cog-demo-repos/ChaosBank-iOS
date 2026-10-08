//
//  HappenSeed.swift
//  ChaosBank
//
//  Synthetic data for the Happen Bank skin (mirrors the public App Store
//  screenshots). Not real customer data.
//

import Foundation

nonisolated struct HappenDepositAccount: Identifiable, Hashable, Sendable {
    enum Kind: Sendable { case checking, savings }

    let id: String
    let kind: Kind
    let product: String
    let mask: String
    let balance: Decimal
    let earnsLevelUpRate: Bool

    var maskedNumber: String { "...\(mask)" }
}

nonisolated struct HappenActivity: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let date: String
    let amount: Decimal
    let runningBalance: Decimal
}

nonisolated struct HappenLoan: Identifiable, Hashable, Sendable {
    let id: String
    let product: String
    let mask: String
    let balance: Decimal
    let nextPayment: Decimal
    let dueDate: String
}

nonisolated struct HappenDepositGoal: Sendable {
    let month: String
    let asOf: String
    let total: Decimal
    let target: Decimal
    let message: String
    let detail: String

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, NSDecimalNumber(decimal: total / target).doubleValue)
    }
}

nonisolated enum HappenSeed {
    static let firstName = "Ryan"

    static let checking = HappenDepositAccount(
        id: "checking-1234", kind: .checking, product: "LevelUp Checking", mask: "1234",
        balance: Decimal(string: "3767.00")!, earnsLevelUpRate: false
    )

    static let savings = HappenDepositAccount(
        id: "savings-7890", kind: .savings, product: "LevelUp Savings", mask: "7890",
        balance: Decimal(string: "15709.25")!, earnsLevelUpRate: true
    )

    static let depositAccounts = [checking, savings]

    static let loans = [
        HappenLoan(
            id: "loan-4421", product: "Personal Loan", mask: "4421",
            balance: Decimal(string: "18240.32")!, nextPayment: Decimal(string: "612.18")!,
            dueDate: "Jul 15"
        ),
    ]

    static let savingsGoal = HappenDepositGoal(
        month: "June", asOf: "5/24/26",
        total: Decimal(string: "305.25")!, target: Decimal(250),
        message: "You'll earn the LevelUp Rate in July. Nice job!",
        detail: "Deposit $250 or more each month to earn the LevelUp Rate the following month."
    )

    static func activity(for account: HappenDepositAccount) -> [HappenActivity] {
        switch account.kind {
        case .savings: savingsActivity
        case .checking: checkingActivity
        }
    }

    private static func row(_ id: String, _ title: String, _ date: String, _ amount: String, _ balance: String) -> HappenActivity {
        HappenActivity(id: id, title: title, date: date,
                       amount: Decimal(string: amount)!, runningBalance: Decimal(string: balance)!)
    }

    static let savingsActivity = [
        row("s1", "External Transfer from Wells Fargo", "Jun 15, 2026", "205.25", "15709.25"),
        row("s2", "Mobile Deposit", "Jun 4, 2026", "100.00", "15504.00"),
        row("s3", "Interest Earned", "Jun 1, 2026", "52.36", "15404.00"),
        row("s4", "External Transfer from Wells Fargo", "May 15, 2026", "200.00", "15351.64"),
        row("s5", "Mobile Deposit", "May 4, 2026", "100.00", "15151.64"),
        row("s6", "Interest Earned", "May 1, 2026", "49.87", "15051.64"),
        row("s7", "External Transfer from Wells Fargo", "Apr 15, 2026", "200.00", "15001.77"),
    ]

    static let checkingActivity = [
        row("c1", "Debit Card Purchase - Whole Foods", "Jun 16, 2026", "-84.12", "3767.00"),
        row("c2", "Direct Deposit - Payroll", "Jun 14, 2026", "2450.00", "3851.12"),
        row("c3", "Transfer to LevelUp Savings", "Jun 14, 2026", "-205.25", "1401.12"),
        row("c4", "Happen Personal Loan Payment", "Jun 12, 2026", "-612.18", "1606.37"),
        row("c5", "Debit Card Purchase - Shell", "Jun 10, 2026", "-46.20", "2218.55"),
    ]
}
