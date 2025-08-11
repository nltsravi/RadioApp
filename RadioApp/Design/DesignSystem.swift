//
//  DesignSystem.swift
//  RadioApp
//
//  Created by Assistant on 10/08/25.
//

import SwiftUI

enum AppTheme {
    static let accent: Color = .accentColor
    static let cardBackground: Color = Color(.secondarySystemGroupedBackground)
    static let groupBackground: Color = Color(.systemGroupedBackground)
    static let separator: Color = Color.black.opacity(0.06)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.separator)
            )
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.accent)
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
            .foregroundColor(.white)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .foregroundColor(.primary)
    }
}


