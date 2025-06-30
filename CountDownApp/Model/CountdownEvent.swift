//
//  CountdownEvent.swift.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import Foundation
import GRDB

// MARK: - Модель данных CountdownEvent

struct CountdownEvent: Identifiable, Codable {
    var id: Int64? // Идентификатор для базы данных. Optional, так как он будет генерироваться GRDB.
    var name: String
    var targetDate: Date // Дата и время события
    var creationDate: Date // Дата создания события (для отслеживания)

    // MARK: - Conformance to GRDB.FetchableRecord and GRDB.PersistableRecord

    // FetchableRecord: Позволяет нам создавать CountdownEvent из строк базы данных.
    init(row: Row) throws {
        id = row["id"]
        name = row["name"]
        targetDate = row["targetDate"]
        creationDate = row["creationDate"]
    }

    // PersistableRecord: Позволяет нам сохранять, обновлять и удалять CountdownEvent в базе данных.
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
        container["targetDate"] = targetDate
        container["creationDate"] = creationDate
    }
    
    // Указываем имя таблицы в базе данных
    static let databaseTableName = "countdownEvents"
}

// MARK: - Расширение для удобства создания новых событий

extension CountdownEvent {
    init(name: String, targetDate: Date) {
        self.name = name
        self.targetDate = targetDate
        self.creationDate = Date() // Автоматически устанавливаем текущую дату создания
    }
}

extension CountdownEvent: FetchableRecord, MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
