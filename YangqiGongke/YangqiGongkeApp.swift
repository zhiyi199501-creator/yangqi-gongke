import SwiftUI
import SwiftData

@main
struct YangqiGongkeApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try StoreFactory.makeContainer()
            #if DEBUG
            ScoreEngine.selfCheck()
            #endif
        } catch {
            fatalError("无法打开本地数据：\(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
