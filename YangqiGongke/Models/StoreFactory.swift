import Foundation
import SwiftData

enum StoreFactory {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([DayPractice.self])
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL(),
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func storeURL() -> URL {
        if let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupID
        ) {
            return container.appending(path: AppConstants.storeFileName)
        }
        let fallback = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: fallback, withIntermediateDirectories: true)
        return fallback.appending(path: AppConstants.storeFileName)
    }
}
