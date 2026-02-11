import SwiftUI
import AVFoundation
import Combine

final class PomodoroTimer: ObservableObject {
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var isRunning: Bool = false

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    func start(seconds: Int) {
        stop()
        guard seconds > 0 else { return }
        remainingSeconds = seconds
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.stop()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset(seconds: Int, startImmediately: Bool = false) {
        stop()
        remainingSeconds = max(0, seconds)
        if startImmediately && seconds > 0 {
            start(seconds: seconds)
        }
    }

    func formattedTime() -> String {
        let min = remainingSeconds / 60
        let sec = remainingSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }

    deinit {
        stop()
    }
}
