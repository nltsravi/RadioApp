//
//  SplashView.swift
//  QSO Log appQSO Log app
//
//  Shows the app icon for 3 seconds on launch with a subtle animation.
//

import SwiftUI
import UIKit

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                AppIconImageView()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)

                Text("QSO Log")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("QSO Log loading")
    }
}

private struct AppIconImageView: View {
    var body: some View {
        if let uiImage = AppIconProvider.primaryIconImage() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Fallback if the app icon image cannot be resolved from bundle
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.accentColor)
            }
        }
    }
}

private enum AppIconProvider {
    static func primaryIconImage() -> UIImage? {
        // Attempt to read the primary icon file name(s) from Info.plist
        guard
            let info = Bundle.main.infoDictionary,
            let icons = info["CFBundleIcons"] as? [String: Any],
            let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primary["CFBundleIconFiles"] as? [String],
            let iconName = iconFiles.last
        else {
            return nil
        }
        return UIImage(named: iconName)
    }
}

#Preview {
    SplashView()
}


