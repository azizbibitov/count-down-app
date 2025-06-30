//
//  AddEditCountdownView.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI

// MARK: - AddEditCountdownView

struct AddEditCountdownView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var eventToEdit: CountdownEvent?
    
    var onSave: (CountdownEvent) -> Void

    @State private var name: String = ""
    @State private var targetDate: Date = Date()
    @State private var showingAlert = false
    @State private var alertMessage: String = ""

    private var isEditing: Bool {
        eventToEdit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Детали события") {
                    TextField("Название события (напр., Моя свадьба)", text: $name)
                    DatePicker("Дата и время", selection: $targetDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                }
            }
            .navigationTitle(isEditing ? "Редактировать событие" : "Добавить событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveEvent()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            // Здесь мы используем .onAppear для вызова setupView
            .onAppear { // Изменяем синтаксис на замыкание
                setupView()
            }
            .alert("Ошибка сохранения", isPresented: $showingAlert) {
                Button("ОК") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Методы

    private func setupView() {
        if let event = eventToEdit {
            // Если редактируем, заполняем поля существующими данными
            // Присваиваем значения напрямую свойству, а не его State-обертке
            name = event.name
            targetDate = event.targetDate
        } else {
            // Если добавляем новое, устанавливаем целевую дату на завтрашний день (для удобства)
            // Присваиваем значения напрямую свойству
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }
    }

    private func saveEvent() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            alertMessage = "Пожалуйста, введите название события."
            showingAlert = true
            return
        }
        
        let now = Date()
        
        // Проверка, что целевая дата не в прошлом
        if targetDate < now {
            alertMessage = "Дата и время события не могут быть в прошлом."
            showingAlert = true
            return
        }
        
        var event: CountdownEvent // Должна быть var, чтобы можно было изменить event.id после сохранения
        if isEditing {
            guard var existingEvent = eventToEdit else { return }
            existingEvent.name = trimmedName
            existingEvent.targetDate = targetDate
            event = existingEvent
        } else {
            event = CountdownEvent(name: trimmedName, targetDate: targetDate)
        }
        
        do {
            // ОДНОКРАТНОЕ СОХРАНЕНИЕ:
            try DatabaseManager.shared.save(event: &event) // Здесь `event` должен быть `inout` или `var`
            
            // ПЛАНИРОВАНИЕ УВЕДОМЛЕНИЯ ПОСЛЕ УСПЕШНОГО СОХРАНЕНИЯ:
            // Используем event, потому что теперь у него есть id, если это была новая запись.
            NotificationManager.shared.scheduleNotification(for: event)
            
            print("Событие сохранено: \(event.name) на \(event.targetDate)")
            
            onSave(event) // Вызываем замыкание для обновления списка
            dismiss()     // Закрываем модальное окно
        } catch {
            alertMessage = "Не удалось сохранить событие: \(error.localizedDescription)"
            showingAlert = true
            print("Ошибка сохранения события: \(error)")
        }
    }
}

