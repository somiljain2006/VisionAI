import SwiftUI

struct WakeUpScreen: View {
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#F05650")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 10)
                
                Text("WAKE UP!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Button(action: action) {
                    Text("I'm Awake")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#5B8E55"))
                        .frame(width: 200, height: 55)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
            }
        }
    }
}
