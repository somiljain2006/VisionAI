import SwiftUI

struct PomodoroTimerBadge: View {
    let timeText: String
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isRunning ? "timer" : "stopwatch")
                .font(.system(size: 14, weight: .semibold))
            Text(timeText)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterialDark)
                .cornerRadius(12)
        )
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
    }
}
