import SwiftUI

struct StudyFocusView: View {

    private let bgColor = Color(hex: "#2D3135")
    private let accent = Color(hex: "#8B8CFB")
    private let buttonColor = Color(hex: "#6C63FF")

    @State private var selectedMinutes: Int = 25
    @State private var customMinutes: Int = 25
    @State private var isUsingCustomTime: Bool = false
    @State private var selectedSeconds: Int = 0
    @State private var customSeconds: Int = 0
    
    private let pickerRowHeight: CGFloat = 80
    private let pickerWidth: CGFloat = 120

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 44, height: 44)
                            )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, -20)
                
                Spacer()
            }
            .zIndex(100)
            
            VStack(spacing: 28) {

                Spacer(minLength: 60)
                
                Text(breakText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accent)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Capsule().fill(accent.opacity(0.15)))
                    .animation(.easeInOut, value: selectedMinutes)

                ZStack {
                    HStack(spacing: -10) {
                        MinuteWheelPicker(range: 25...60, selection: $customMinutes, rowHeight: pickerRowHeight)
                            .frame(width: pickerWidth, height: 180)
                            .clipped()
                            .contentShape(Rectangle())
                            .onChange(of: customMinutes) { _, newValue in
                                let clamped = min(max(newValue, 25), 60)
                                if clamped != selectedMinutes {
                                    selectedMinutes = clamped
                                }
                                if clamped != customMinutes {
                                    customMinutes = clamped
                                }
                                isUsingCustomTime = true
                            }

                        Text(":")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                            .offset(y: -4)
                            .zIndex(10)

                        MinuteWheelPicker(range: 0...59, selection: $customSeconds, rowHeight: pickerRowHeight)
                            .frame(width: pickerWidth, height: 180)
                            .clipped()
                            .contentShape(Rectangle())
                            .onChange(of: customSeconds) { _, newValue in
                                selectedSeconds = newValue
                                isUsingCustomTime = true
                            }
                    }
                    .frame(width: 280, height: 180)
                    .mask(Circle().frame(width: 250, height: 250))
                    .overlay(
                        VStack {
                            LinearGradient(
                                colors: [bgColor, bgColor.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 50)
                            Spacer()
                            LinearGradient(
                                colors: [bgColor.opacity(0.0), bgColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 50)
                        }
                        .allowsHitTesting(false)
                    )

                    Circle()
                        .stroke(accent.opacity(0.35), lineWidth: 10)
                        .frame(width: 280, height: 280)
                }
                
                Text("“The successful warrior is the average person, with laser-like focus.”")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)

                HStack(spacing: 14) {
                    durationChip(25)
                    durationChip(45)
                    durationChip(60)
                }

                Spacer(minLength: 160)
            }

            VStack {
                Spacer()
                Button {
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                        Text("Start detection")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(buttonColor)
                    .cornerRadius(16)
                    .shadow(radius: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }
        }
        .onAppear {
            selectedMinutes = min(max(selectedMinutes, 25), 60)
            customMinutes = selectedMinutes
        }
    }

    private var breakText: String {
        let breakMin = breakMinutes(for: selectedMinutes)
        return "\(breakMin) min break"
    }

    private func durationChip(_ minutes: Int) -> some View {
        Button {
            selectedMinutes = minutes
            selectedSeconds = 0
            customMinutes = minutes
            customSeconds = 0
            isUsingCustomTime = false
        } label: {
            Text("\(minutes)m")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(selectedMinutes == minutes ? accent : .white.opacity(0.6))
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(selectedMinutes == minutes ? accent.opacity(0.15) : Color.white.opacity(0.08))
                )
        }
    }
    
    private func breakMinutes(for focusMinutes: Int) -> Int {
        let raw = 0.2857 * Double(focusMinutes) - 2.14
        return max(5, Int(floor(raw)))
    }
}
