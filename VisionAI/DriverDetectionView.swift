import SwiftUI
import AVFoundation

struct DriverDetectionView: View {
    
    @StateObject private var detector = EyeDetector()
    
    private let bgColor = Color(hex: "#2D3135")
    private let buttonColor = Color(hex: "#49494A")
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            if detector.isRunning && !detector.eyesOpen {
                Color.red.opacity(0.3)
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: detector.eyesOpen)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        print("Profile tapped")
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, -50)
                }

                Spacer()
                
                ZStack {
                    Image("camera-background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .scaleEffect(1.3)
                        .clipped()
                    
                    if detector.isRunning {
                        CameraPreview(session: detector.session)
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .id("CameraFeed")
                    }

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 130, height: 130)

                    Circle()
                        .stroke(
                            detector.isRunning
                                ? (detector.eyesOpen ? Color.green : Color.red)
                                : Color.white,
                            lineWidth: 3
                        )
                        .frame(width: 130, height: 130)

                    if !detector.isRunning {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }
                .clipShape(Circle())
                .shadow(radius: 10)

                if detector.isRunning {
                    Text(detector.eyesOpen ? "Eyes Open" : "Drowsiness Detected!")
                        .font(.headline)
                        .foregroundColor(detector.eyesOpen ? .green : .red)
                        .padding(.top, 20)
                }

                Spacer()

                Button {
                    if detector.isRunning {
                        detector.stop()
                    } else {
                        detector.start()
                    }
                } label: {
                    Text(detector.isRunning ? "Stop Detection" : "Start Detection")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(detector.isRunning ? Color.red.opacity(0.8) : buttonColor)
                        .cornerRadius(16)
                        .shadow(radius: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onReceive(detector.$closedDuration) { duration in
            if duration > 1.5 {
                print("🚨 WAKE UP! Eyes closed for \(duration)")
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        guard let session = session else { return view }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = context.coordinator.previewLayer {
            layer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

extension EyeDetector {
    func getSession() -> AVCaptureSession? {
        return self.value(forKey: "session") as? AVCaptureSession
    }
}
