import SwiftUI

func sfProBold(_ size: CGFloat) -> Font {
    if UIFont(name: "SFProDisplay-Bold", size: size) != nil {
        return .custom("SFProDisplay-Bold", size: size)
    }
    return .system(size: size, weight: .bold)
}
