import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isSetupComplete") private var isSetupComplete = false
    @AppStorage("isProfileComplete") private var isProfileComplete = false

    @State private var flow: AppFlow = .splash

    var body: some View {
        ZStack {
            switch flow {
            case .splash:
                SplashView {
                    withAnimation {
                        if isSetupComplete {
                            flow = .modeSelection
                        } else if hasSeenOnboarding {
                            if isProfileComplete {
                                flow = .permissions
                            } else {
                                flow = .profileSetup
                            }
                        } else {
                            flow = .onboarding
                        }
                    }
                }

            case .onboarding:
                OnboardingContainer {
                    hasSeenOnboarding = true
                    withAnimation {
                        if isProfileComplete {
                            flow = .permissions
                        } else {
                            flow = .profileSetup
                        }
                    }
                }

            case .profileSetup:
                ProfileSetupView {
                    withAnimation {
                        flow = .permissions
                    }
                }

            case .permissions:
                CameraPermissionView()

            case .modeSelection:
                ModeSelectionView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: flow)
    }
}
