import SwiftUI
import Combine

struct OnboardingContainer: View {
    @State private var page = 0
    let onFinish: () -> Void

    private let totalPages = 3
    @State private var isAutoSliding = true

    private let timer = Timer.publish(
        every: 3,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        TabView(selection: $page) {

            OnboardingPage1(
                page: $page,
                onFinish: onFinish
            )
            .tag(0)

            OnboardingPage2(
                page: $page,
                onFinish: onFinish
            )
            .tag(1)

            OnboardingPage3(
                page: $page,
                onFinish: onFinish
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()

        .onReceive(timer) { _ in
            guard isAutoSliding else { return }

            withAnimation(.easeInOut) {
                if page < totalPages - 1 {
                    page += 1
                } else {
                    isAutoSliding = false
                }
            }
        }
    }
}
