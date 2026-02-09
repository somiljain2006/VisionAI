import SwiftUI
import AVFoundation

struct DriverStartUI: View {
    var onStart: () -> Void = {}
    
    private let cameraSize: CGFloat = 220
    private let borderWidth: CGFloat = 2

    var body: some View {
        VStack {
            Spacer().frame(height: 180)

            ZStack {
                Image("camera-background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: cameraSize, height: cameraSize)
                    .clipShape(Circle())
                    .offset(x: 1)
                
                Circle()
                    .inset(by: 24)
                    .stroke(Color.white, lineWidth: borderWidth)

                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
            }
            .padding(.top, 40)

            Text("Ready to Start")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 8)

            Spacer()
            Spacer().frame(height: 100)
        }
    }
}
