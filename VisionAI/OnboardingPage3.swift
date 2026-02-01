import SwiftUI

struct OnboardingPage3: View {
    @Binding var page: Int

    private let gradient = LinearGradient(
        colors: [
            Color(hex: "#28457E"),
            Color(hex: "#75C7D3")
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()

            VStack {
                Spacer(minLength: 60)

                VStack(alignment: .leading, spacing: 12) {
                    Text("SEAMLESSLY\nSWITCH MODES")
                        .font(sfProBold(36))
                        .foregroundColor(.white)

                    Text("Your focus, your rules,\nanywhere you go.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)

                Spacer(minLength: 40)

                Image("onboarding_3")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .shadow(radius: 10)

                Spacer()

                HStack(spacing: 18) {

                    Button {
                        withAnimation(.easeInOut) {
                            page = 0
                        }
                    } label: {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color.white.opacity(0.4))
                    }

                    Button {
                        withAnimation(.easeInOut) {
                            page = 1
                        }
                    } label: {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color.white.opacity(0.4))
                    }

                    Capsule()
                        .frame(width: 35, height: 14)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.bottom, 20)

                Button {
                    
                } label: {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#2E3B6D"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(radius: 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct OnboardingPage3_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage3(page: .constant(2))
            .previewDevice("iPhone 14 Pro")
    }
}
