import Foundation

struct StudyAlertStorage {
    static let customSoundId = "custom"

    static var customSoundURL: URL? {
        get {
            guard let path = UserDefaults.standard.string(forKey: "studyCustomSoundPath") else {
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        set {
            UserDefaults.standard.set(newValue?.path, forKey: "studyCustomSoundPath")
        }
    }
}
