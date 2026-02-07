import SwiftUI

struct ProfileSetupView: View {

    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("isProfileComplete") private var isProfileComplete = false

    let onFinish: () -> Void

    @State private var showValidationError = false

    private let bgColor = Color(hex: "#2D3135")
    private let buttonColor = Color(hex: "#49494A")
    private let fieldBorder = Color.white.opacity(0.08)
    private let placeholderColor = Color.white.opacity(0.35)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack {

                Spacer(minLength: 90)

                VStack(spacing: 12) {
                    Text("Focus on what\nmatters.")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("stay aware , stay intentional")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 35)

                VStack(spacing: 16) {
                    inputField(
                        placeholder: "Name",
                        text: $userName,
                        keyboard: .default
                    )

                    inputField(
                        placeholder: "Email",
                        text: $userEmail,
                        keyboard: .emailAddress
                    )

                    if showValidationError {
                        Text("Name is required")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                Button(action: submit) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(buttonColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            if isProfileComplete {
                DispatchQueue.main.async {
                    onFinish()
                }
            }
        }
    }

    private func inputField(
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        TextField("", text: text)
            .keyboardType(keyboard)
            .autocapitalization(placeholder == "Email" ? .none : .words)
            .disableAutocorrection(true)
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(fieldBorder, lineWidth: 1)
            )
            .placeholder(when: text.wrappedValue.isEmpty) {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.horizontal, 18)
            }
    }

    private func submit() {
        guard !userName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showValidationError = true
            return
        }

        showValidationError = false
        isProfileComplete = true

        withAnimation {
            onFinish()
        }
    }
}
