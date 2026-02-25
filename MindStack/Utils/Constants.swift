import Foundation

enum Constants {
    struct Level: Identifiable {
        let id: Int
        let name: String
        let minXp: Int
        let maxXp: Int
    }

    static let levels: [Level] = [
        .init(id: 1, name: "Genç Düşünür", minXp: 0, maxXp: 2000),
        .init(id: 2, name: "Mantık Kurucu", minXp: 2000, maxXp: 5000),
        .init(id: 3, name: "Sistem Ustası", minXp: 5000, maxXp: 12000),
        .init(id: 4, name: "Kıdemli Mimar", minXp: 12000, maxXp: 999999)
    ]
}
