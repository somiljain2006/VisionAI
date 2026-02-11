import Foundation

struct StudyAlertSound: Identifiable, Equatable {
    let id: String
    let title: String
    let fileName: String
}

let studyAlertSounds: [StudyAlertSound] = [
    .init(id: "bell", title: "Soft Bell", fileName: "study_bell"),
    .init(id: "chime", title: "Chime", fileName: "study_chime"),
    .init(id: "pulse", title: "Pulse", fileName: "study_pulse")
]
