import Foundation

struct StudyAlertSound: Identifiable, Equatable {
    let id: String
    let title: String
    let fileName: String?
    let fileURL: URL?     

    static func == (lhs: StudyAlertSound, rhs: StudyAlertSound) -> Bool {
        lhs.id == rhs.id
    }
}

let studyAlertSounds: [StudyAlertSound] = [
    .init(id: "bell",  title: "Soft Bell", fileName: "study_bell",  fileURL: nil),
    .init(id: "chime", title: "Chime",     fileName: "study_chime", fileURL: nil),
    .init(id: "pulse", title: "Pulse",     fileName: "study_pulse", fileURL: nil)
]
