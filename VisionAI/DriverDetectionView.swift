import SwiftUI
import AVFoundation

struct DriverDetectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var detector = EyeDetector()
    
    private let bgColor = Color(hex: "#2D3135")
    private let buttonColor = Color(hex: "#49494A")
    
    var body: some View {
            ZStack {
                if detector.isRunning {
                    CameraPreview(session: detector.session)
                        .ignoresSafeArea()
                } else {
                    bgColor.ignoresSafeArea()
                }
                
                VStack {
                    HStack {
                        if detector.isRunning {
                            if detector.closedDuration <= 5.0 {
                                Image("eyes-wide")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .padding(.leading, 18)
                                    .shadow(radius: 2)
                                    .transition(.opacity)
                            }
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.leading, 24)
                                    .padding(.top, 20)
                                    .shadow(radius: 2)
                            }
                        }
                        
                        Spacer()
                        
                        if !detector.isRunning {
                            Image("person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .padding(.trailing, 24)
                                .shadow(radius: 2)
                                .padding(.top, 25)
                        }
                    }
                    .padding(.top, -10)
                    .offset(y: -5)
                    
                    Spacer()
                    
                    if !detector.isRunning {
                        ZStack {
                            Image("camera-background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 220, height: 220)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.white)
                                )
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 175, height: 175)
                                .shadow(color: .white.opacity(0.5), radius: 10)
                                .offset(x: -1.5)
                        }
                        .padding(.bottom, 10)
                    }
                    
                    if !detector.isRunning {
                        Text("Ready to Start")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    Button(action: toggleDetection) {
                        Text(detector.isRunning ? "Stop Detection" : "Start Detection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(detector.isRunning ? Color.red.opacity(0.9) : buttonColor)
                            .cornerRadius(14)
                            .shadow(radius: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
                
                if detector.isRunning && detector.closedDuration > 5.0 {
                    WakeUpScreen {
                        print("User confirmed they are awake")
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onReceive(detector.$closedDuration) { duration in
                if duration > 5.00 {
                    print("🚨 Eyes closed for \(duration)s — TRIGGER ALARM HERE")
                }
            }
        }
    
    private func toggleDetection() {
        withAnimation {
            if detector.isRunning {
                detector.stop()
            } else {
                detector.start()
            }
        }
    }
    
    private func resetDetection() {
        detector.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                detector.start()
            }
        }
    }
}
