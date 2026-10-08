//
//  HappenTheme.swift
//  ChaosBank
//
//  Happen Bank skin: palette sampled from the App Store screenshots, DM Sans
//  (variable, OFL) as the UI face, and the shared navigation chrome.
//

import SwiftUI
import UIKit
import CoreText

enum HappenColor {
    static let background = Color.white
    static let blue = Color(hex: 0x2626FF)
    static let blueText = Color(hex: 0x1E1ECB)
    static let violet = Color(hex: 0xA42BE3)
    static let orange = Color(hex: 0xFD4621)
    static let ink = Color(hex: 0x333333)
    static let inkSecondary = Color(hex: 0x6B6B6B)
    static let sand = Color(hex: 0xF8F3EF)
    static let sandCard = Color(hex: 0xFAF7F5)
    static let hairline = Color(hex: 0xEAE3DD)
    static let track = Color(hex: 0xE6E0DB)
    static let green = Color(hex: 0x1E8B24)
    static let progress = Color(hex: 0x2BAA3A)
    static let pillBackground = Color(hex: 0xD4F5DA)
    static let pillText = Color(hex: 0x17701F)

    static let greeting = LinearGradient(
        colors: [Color(hex: 0x4646FE), violet, orange],
        startPoint: .leading, endPoint: .trailing
    )
}

enum HappenWeight: CGFloat {
    case regular = 400, medium = 500, semibold = 600, bold = 700
}

enum HappenFont {
    private static let postScriptName = "DMSans-9ptRegular"
    private static let weightAxis = NSNumber(value: 0x7767_6874) // 'wght'
    private static let opticalSizeAxis = NSNumber(value: 0x6F70_737A) // 'opsz'

    private static let registered: Bool = {
        guard let url = Bundle.main.url(forResource: "DMSans", withExtension: "ttf") else { return false }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        return UIFont(name: postScriptName, size: 12) != nil
    }()

    static func register() { _ = registered }

    static func uiFont(_ size: CGFloat, _ weight: HappenWeight) -> UIFont {
        guard registered else { return .systemFont(ofSize: size, weight: systemWeight(weight)) }
        let variations: [NSNumber: NSNumber] = [
            weightAxis: NSNumber(value: Double(weight.rawValue)),
            opticalSizeAxis: NSNumber(value: Double(min(max(size, 9), 40))),
        ]
        let descriptor = UIFontDescriptor(name: postScriptName, size: size).addingAttributes([
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): variations,
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func systemWeight(_ weight: HappenWeight) -> UIFont.Weight {
        switch weight {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

extension Font {
    static func happen(_ size: CGFloat, _ weight: HappenWeight = .regular) -> Font {
        Font(HappenFont.uiFont(size, weight) as CTFont)
    }
}

enum HappenFormat {
    private static let usd: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    static func usd(_ value: Decimal) -> String {
        usd.string(from: value as NSDecimalNumber) ?? "$0.00"
    }

    static func signedUSD(_ value: Decimal) -> String {
        (value < 0 ? "-" : "+") + usd(abs(value))
    }
}

extension View {
    /// White, light-scheme nav and tab bars for Happen screens; the rest of the
    /// app keeps its dark chrome.
    func happenChrome() -> some View {
        toolbarBackground(HappenColor.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(HappenColor.background, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
    }
}
