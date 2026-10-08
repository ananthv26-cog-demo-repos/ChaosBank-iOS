//
//  HappenComponents.swift
//  ChaosBank
//

import SwiftUI

/// Full-bleed warm band that separates Happen sections.
struct HappenBand: View {
    var height: CGFloat = 12
    var body: some View {
        HappenColor.sand.frame(height: height).frame(maxWidth: .infinity)
    }
}

struct HappenHairline: View {
    var body: some View {
        HappenColor.hairline.frame(height: 1).frame(maxWidth: .infinity)
    }
}

struct LevelUpPill: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 11, weight: .medium))
            Text("LevelUp Rate")
                .font(.happen(13, .medium))
        }
        .foregroundStyle(HappenColor.pillText)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(HappenColor.pillBackground, in: Capsule())
    }
}

/// Large outlined tile used for the Home quick actions.
struct HappenQuickAction<Icon: View>: View {
    let title: String
    let a11y: String
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                icon()
                    .foregroundStyle(HappenColor.blue)
                    .frame(height: 26)
                Text(title)
                    .font(.happen(15, .semibold))
                    .foregroundStyle(HappenColor.blueText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(HappenColor.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(HappenColor.blue, lineWidth: 1.25)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(a11y)
    }
}

/// Compact outlined chip used for the account-detail actions.
struct HappenActionChip<Icon: View>: View {
    let title: String
    let a11y: String
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon().foregroundStyle(HappenColor.blue)
                Text(title).font(.happen(15, .semibold)).foregroundStyle(HappenColor.blueText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(HappenColor.blue, lineWidth: 1.25)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(a11y)
    }
}

/// Happen's check-with-arrow "Deposit" glyph, composed from SF Symbols.
struct HappenDepositIcon: View {
    var size: CGFloat = 22
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "banknote")
                .font(.system(size: size, weight: .regular))
            Image(systemName: "arrow.down")
                .font(.system(size: size * 0.45, weight: .bold))
                .padding(1)
                .background(HappenColor.background, in: Circle())
                .offset(x: size * 0.18, y: size * 0.2)
        }
    }
}

/// Offline indicator for Happen screens; same gate and locator as `ChaosBankScreen`.
struct HappenOfflineBanner: View {
    @Environment(AppServices.self) private var services

    var body: some View {
        if services.offline && !Defects.isActive(.offlineBannerMissing) {
            Text("You're offline — showing cached data")
                .font(.happen(13, .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(HappenColor.orange, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .accessibilityIdentifier(A11y.Net.offlineBanner)
        }
    }
}
