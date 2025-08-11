//
//  WaterRippleView.swift
//  QSO Log app
//

import SwiftUI

struct WaterRippleView: View {
    let key: Int
    var color: Color = .accentColor
    var duration: Double = 0.6
    
    @State private var animate = false
    
    var body: some View {
        Circle()
            .stroke(color.opacity(0.6), lineWidth: 2)
            .background(Circle().fill(color.opacity(0.15)))
            .scaleEffect(animate ? 1.35 : 0.01)
            .opacity(animate ? 0.0 : 1.0)
            .animation(.easeOut(duration: duration), value: animate)
            .onAppear { animate = true }
            .id(key)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        WaterRippleView(key: 1)
            .frame(width: 60, height: 60)
    }
}


