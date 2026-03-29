import SwiftUI
import AVFoundation
import Vision
import Combine

@MainActor
final class EyeDetector: NSObject, ObservableObject {
    @Published var isRunning: Bool = false
    @Published var eyesOpen: Bool = true
    @Published var closedDuration: TimeInterval = 0
    @Published var isStarting: Bool = false
    @Published var totalTripDuration: TimeInterval = 0
    @Published var isPaused: Bool = false
    
    @Published private(set) var alertsCount: Int = 0
    @Published private(set) var lastSessionDuration: TimeInterval = 0
    @Published private(set) var lastSessionAlerts: Int = 0

    var onEyesClosedLong: (() -> Void)?
    private let closedThreshold: TimeInterval = 2.5
    private var lastFaceSeen: Date?

    nonisolated(unsafe) var session: AVCaptureSession?
    private let videoQueue = DispatchQueue(label: "vision.video.queue")
    private var lastClosedStart: Date?
    private var lastFrameTime: Date?
    private var sessionStart: Date?
    private var alertedWhileClosed: Bool = false
    
    override init() {
        super.init()
    }
    
    func start() {
        DispatchQueue.main.async {
            guard !self.isRunning else { return }
            self.isStarting = true
            self.isRunning = true
            self.alertsCount = 0
            self.sessionStart = Date()
        }
        checkPermissionAndStart()
    }

    func stop() {
        let duration: TimeInterval
        if let start = sessionStart {
            duration = Date().timeIntervalSince(start)
        } else {
            duration = 0
        }

        DispatchQueue.main.async {
            self.lastSessionDuration = duration
            self.totalTripDuration += duration
            self.lastSessionAlerts = self.alertsCount

            self.lastClosedStart = nil
            self.closedDuration = 0
            self.eyesOpen = true
            self.isStarting = false
            self.isRunning = false
            self.alertedWhileClosed = false
            self.sessionStart = nil
        }

        if let session = session, session.isRunning {
            session.stopRunning()
        }
        session = nil
    }
    
    func resetTrip() {
        totalTripDuration = 0
        lastSessionDuration = 0
    }

    func registerAlert() {
        alertsCount += 1
    }
    
    private func checkPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSessionAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.setupSessionAndStart() }
                }
            }
        default:
            break
        }
    }

    private func setupSessionAndStart() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            print("❌ cannot create front camera input")
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: videoQueue)
        output.alwaysDiscardsLateVideoFrames = true

        guard session.canAddOutput(output) else {
            print("❌ can't add video output")
            return
        }
        session.addOutput(output)

        if let conn = output.connection(with: .video) {
            if #available(iOS 17.0, *) {
                if conn.isVideoRotationAngleSupported(0) {
                    conn.videoRotationAngle = 0
                }
            } else {
                if conn.isVideoOrientationSupported {
                    conn.videoOrientation = .portrait
                }
            }
        }

        session.commitConfiguration()
        self.session = session

        videoQueue.async { [weak self] in
            self?.session?.startRunning()
            DispatchQueue.main.async {
                self?.isStarting = false
            }
        }
    }

    func handleNoFace() {
        guard !isPaused else { return }
        self.eyesOpen = false
        
        if self.lastClosedStart == nil {
            self.lastClosedStart = Date()
        } else {
            self.closedDuration = Date().timeIntervalSince(self.lastClosedStart!)
            
            if self.closedDuration >= self.closedThreshold && !self.alertedWhileClosed {
                self.alertedWhileClosed = true
                self.onEyesClosedLong?()
            }
        }
    }
    
    func pauseProcessing() {
        isPaused = true
    }

    func resumeProcessing() {
        isPaused = false
    }
    
    func acknowledgeAlertAndReset() {
        alertedWhileClosed = true
        lastClosedStart = nil
        closedDuration = 0
    }
    
    // Moved to be accessed by background thread safely
    nonisolated private func startCaptureSession(_ session: AVCaptureSession) {
        session.startRunning()
    }
    
    // Updates UI State using the calculated openness number
    func updateEyeState(hasFace: Bool, avgOp: CGFloat?) {
        guard !isPaused else { return }
        
        if !hasFace {
            handleNoFace()
            return
        }
        
        guard let avg = avgOp else {
            self.eyesOpen = false
            if self.lastClosedStart == nil {
                self.lastClosedStart = Date()
            } else {
                self.closedDuration = Date().timeIntervalSince(self.lastClosedStart!)
                if self.closedDuration >= self.closedThreshold && !self.alertedWhileClosed {
                    self.alertedWhileClosed = true
                    self.onEyesClosedLong?()
                }
            }
            return
        }

        let threshold: CGFloat = 0.18
        if avg > threshold {
            self.eyesOpen = true
            self.lastClosedStart = nil
            self.closedDuration = 0
            self.alertedWhileClosed = false
        } else {
            if self.lastClosedStart == nil {
                self.lastClosedStart = Date()
            }
            self.closedDuration = Date().timeIntervalSince(self.lastClosedStart!)
            self.eyesOpen = false
            if self.closedDuration >= self.closedThreshold && !self.alertedWhileClosed {
                self.alertedWhileClosed = true
                self.onEyesClosedLong?()
            }
        }
    }
}

extension EyeDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )

        try? handler.perform([request])
        let faceResult = request.results?.first as? VNFaceObservation
        
        let hasFace = faceResult != nil
        let avgOp = calculateOpenness(from: faceResult)
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard self.isRunning else { return }
            
            if hasFace {
                self.lastFaceSeen = Date()
            }
            self.updateEyeState(hasFace: hasFace, avgOp: avgOp)
        }
    }

    nonisolated private func calculateOpenness(from face: VNFaceObservation?) -> CGFloat? {
        guard let face = face, let landmarks = face.landmarks else { return nil }

        func openness(for eye: VNFaceLandmarkRegion2D?, boundingBox: CGRect) -> CGFloat? {
            guard let eye = eye, eye.pointCount > 5 else { return nil }
            let pts = (0..<eye.pointCount).map { i in eye.normalizedPoints[i] }
            let ys = pts.map { $0.y }
            let xs = pts.map { $0.x }
            guard let minY = ys.min(), let maxY = ys.max(), let minX = xs.min(), let maxX = xs.max() else { return nil }

            let vertical = maxY - minY
            let horizontal = maxX - minX
            guard horizontal > 0.0001 else { return nil }
            return vertical / horizontal
        }

        let leftOp = openness(for: landmarks.leftEye, boundingBox: face.boundingBox)
        let rightOp = openness(for: landmarks.rightEye, boundingBox: face.boundingBox)

        if let l = leftOp, let r = rightOp {
            return (l + r) / 2.0
        } else {
            return leftOp ?? rightOp
        }
    }
}
