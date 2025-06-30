//
//  CountdownDetailView.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI

// MARK: - CountdownDetailView

struct CountdownDetailView: View {
    let event: CountdownEvent // Событие, для которого мы показываем отсчет
    
    // @State для хранения оставшегося времени, будет обновляться каждую секунду
    @State private var remainingTime: TimeInterval = 0
    
    // TimerPublisher для обновления UI каждую секунду
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) { // Вертикальный стек для размещения элементов
            Spacer() // Отталкивает содержимое вниз
            
            Text(event.name)
                .font(.largeTitle) // Крупный заголовок для названия события
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Отображение оставшегося времени
            Text(formattedRemainingTime)
                .font(.system(size: 60, weight: .bold, design: .rounded)) // Очень крупный шрифт
                .minimumScaleFactor(0.5) // Позволяет тексту уменьшаться, если он слишком длинный
                .lineLimit(1)
                .foregroundColor(remainingTime <= 0 ? .red : .accentColor) // Красный, если время вышло
                .padding(.horizontal)
            
            Text("осталось")
                .font(.title2)
                .foregroundColor(.gray)
            
            Spacer() // Отталкивает содержимое вверх
        }
        .navigationTitle("Отсчет") // Заголовок экрана
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupTimer) // Запускаем таймер при появлении
        .onReceive(timer) { _ in // Обрабатываем каждое срабатывание таймера
            updateRemainingTime()
        }
    }

    // MARK: - Методы

    private func setupTimer() {
        updateRemainingTime() // Инициализируем время сразу при появлении
    }

    private func updateRemainingTime() {
        let now = Date()
        // Вычисляем разницу во времени в секундах
        let newRemainingTime = event.targetDate.timeIntervalSince(now)
        
        // Обновляем @State переменную, что вызовет перерисовку UI
        remainingTime = max(0, newRemainingTime) // Гарантируем, что время не уйдет в минус
    }

    // Вычисляемое свойство для форматирования оставшегося времени
    private var formattedRemainingTime: String {
        guard remainingTime > 0 else {
            return "Время вышло!"
        }

        let days = Int(remainingTime / (3600 * 24))
        let hours = Int((remainingTime.truncatingRemainder(dividingBy: (3600 * 24))) / 3600)
        let minutes = Int((remainingTime.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(remainingTime.truncatingRemainder(dividingBy: 60))

        if days > 0 {
            return String(format: "%d д %02d ч %02d м", days, hours, minutes)
        } else if hours > 0 {
            return String(format: "%02d ч %02d м %02d с", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%02d м %02d с", minutes, seconds)
        } else {
            return String(format: "%02d с", seconds)
        }
    }
}

// MARK: - Предварительный просмотр

struct CountdownDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Пример события для предварительного просмотра (через 5 дней и 10 часов)
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            .addingTimeInterval(3600 * 10)
        let sampleEvent = CountdownEvent(name: "Долгожданный Отпуск", targetDate: futureDate)
        
        NavigationView { // Для правильного отображения NavigationTitle
            CountdownDetailView(event: sampleEvent)
        }
    }
}
