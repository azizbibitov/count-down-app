//
//  DatabaseManager.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import Foundation
import GRDB

// MARK: - DatabaseManager

class DatabaseManager {
    static let shared = DatabaseManager() // Синглтон для доступа к менеджеру из любого места приложения
    private var dbQueue: DatabaseQueue! // Очередь для работы с базой данных
    
    private init() { // Приватный инициализатор для синглтона
        do {
            try setupDatabase()
        } catch {
            print("Ошибка инициализации базы данных: \(error)")
        }
    }
    
    private func setupDatabase() throws {
        // Получаем путь к папке документов приложения
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
        let databaseURL = appSupportURL.appendingPathComponent("countdownEvents.sqlite")
        
        // Инициализируем очередь базы данных
        dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        // Выполняем миграцию базы данных (создаем таблицу, если ее нет)
        try migrator.migrate(dbQueue)
        print("База данных успешно инициализирована по пути: \(databaseURL.path)")
    }
    
    // MARK: - Миграции базы данных
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Первая миграция: создание таблицы countdownEvents
        migrator.eraseDatabaseOnSchemaChange = true // Удалять базу данных при изменении схемы (полезно при разработке)
        // В продакшене лучше использовать инкрементальные миграции
        migrator.registerMigration("createCountdownEvent") { db in
            try db.create(table: CountdownEvent.databaseTableName) { table in
                table.column("id", .integer).primaryKey().notNull() // Автоинкрементный Primary Key
                table.column("name", .text).notNull()
                table.column("targetDate", .date).notNull()
                table.column("creationDate", .date).notNull()
            }
        }
        return migrator
    }
    
    // MARK: - CRUD Операции
    
    // Получение всех событий
    func fetchAllEvents() throws -> [CountdownEvent] {
        try dbQueue.read { db in
            try CountdownEvent.fetchAll(db)
        }
    }
    
    
    // Сохранение/Обновление события
    func save(event: inout CountdownEvent) throws {
        try dbQueue.write { db in
            try event.save(db) // Этот метод теперь доступен благодаря MutablePersistableRecord
        }
    }
    
    // Удаление события
    func delete(event: CountdownEvent) throws {
        try dbQueue.write { db in
            _ = try event.delete(db) // Этот метод теперь доступен
        }
    }
    
    // Получение события по ID (полезно для редактирования)
    func fetchEvent(id: Int64) throws -> CountdownEvent? {
        try dbQueue.read { db in
            try CountdownEvent.fetchOne(db, key: id)
        }
    }
}
