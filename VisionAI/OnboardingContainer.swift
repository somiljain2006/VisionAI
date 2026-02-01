import SwiftUI

struct OnboardingContainer: View {
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            OnboardingPage1(page: $page).tag(0)
            OnboardingPage2(page: $page).tag(1)
            OnboardingPage3(page: $page).tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
