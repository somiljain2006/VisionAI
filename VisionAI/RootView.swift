import SwiftUI

struct RootView: View {
    @State private var showOnboarding = false
    @State private var showPermission = false

    var body: some View {
        ZStack {
            if showPermission {
                CameraPermissionView()
                    .transition(.opacity)
            } else if showOnboarding {
                OnboardingContainer(
                    onFinish: {
                        showPermission = true
                    }
                )
                .transition(.opacity)
            } else {
                SplashView {
                    showOnboarding = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showPermission)
    }
}

