//
//  NotificationManager.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import Foundation
import UserNotifications // Импортируем фреймворк для работы с уведомлениями

// MARK: - NotificationManager

class NotificationManager {
    static let shared = NotificationManager() // Синглтон для удобного доступа
    
    private init() {} // Приватный инициализатор для синглтона

    // MARK: - Запрос разрешения на уведомления

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено!")
            } else if let error = error {
                print("Ошибка получения разрешения на уведомления: \(error.localizedDescription)")
            } else {
                print("Разрешение на уведомления отклонено.")
            }
        }
    }

    // MARK: - Планирование уведомления

    func scheduleNotification(for event: CountdownEvent) {
        // Убедимся, что у события есть ID и что оно не в прошлом
        guard let id = event.id, event.targetDate > Date() else {
            print("Не удалось запланировать уведомление: событие не имеет ID или находится в прошлом.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Наступило событие!"
        content.body = "Время для «\(event.name)» пришло!"
        content.sound = .default // Звук по умолчанию

        // Создаем триггер, который сработает в конкретную дату и время
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.targetDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Идентификатор запроса уведомления. Важно, чтобы он был уникальным
        // и соответствовал событию, чтобы мы могли его отменить позже.
        let requestIdentifier = "countdown-event-\(id)"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)

        // Добавляем запрос в центр уведомлений
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка планирования уведомления для \(event.name): \(error.localizedDescription)")
            } else {
                print("Уведомление для «\(event.name)» запланировано на \(event.targetDate)")
            }
        }
    }

    // MARK: - Отмена уведомления

    func cancelNotification(for event: CountdownEvent) {
        guard let id = event.id else {
            print("Не удалось отменить уведомление: событие не имеет ID.")
            return
        }
        let requestIdentifier = "countdown-event-\(id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        print("Запланированное уведомление для «\(event.name)» (ID: \(id)) отменено.")
    }
}
