//
//  CountdownDetailView.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI

// MARK: - CountdownDetailView

struct CountdownDetailView: View {
    let event: CountdownEvent
    
    @State private var remainingTime: TimeInterval = 0
    // Общее время от создания до целевой даты
    @State private var totalDuration: TimeInterval = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(event.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // --- НОВОЕ: Круговой индикатор прогресса и текст времени ---
            if remainingTime <= 0 {
                Text("Время вышло!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            } else {
                VStack {
                    // Вычисляем progress: сколько % времени УЖЕ ПРОШЛО
                    // Это inverseProgress, так как remainingTime - это сколько осталось.
                    // progress = (totalDuration - remainingTime) / totalDuration
                    let currentProgress = (totalDuration - remainingTime) / totalDuration
                    
                    CircularProgressView(
                        progress: currentProgress,
                        lineWidth: 20, // Толщина линии прогресса
                        accentColor: progressColor, // Цвет будет зависеть от оставшегося времени
                        backgroundColor: .gray.opacity(0.3)
                    )
                    .frame(width: 250, height: 250) // Размер круга
                    .overlay( // Накладываем текст на круг
                        VStack {
                            Text(formattedTimeRemainingString) // Основной текст таймера
                                .font(.system(size: 45, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            Text("осталось")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    )
                }
            }
            // --- КОНЕЦ НОВОГО БЛОКА ---

            Spacer()
        }
        .navigationTitle("Отсчет")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupTimer)
        .onReceive(timer) { _ in
            updateRemainingTime()
        }
    }

    // MARK: - Вычисляемые свойства и методы

    private var progressColor: Color {
        // Меняем цвет в зависимости от оставшегося времени
        if remainingTime < 3600 * 24 { // Меньше 24 часов
            return .red
        } else if remainingTime < 3600 * 24 * 7 { // Меньше 7 дней
            return .orange
        } else {
            return .accentColor // По умолчанию
        }
    }

    private var formattedTimeRemainingString: String {
        guard remainingTime > 0 else { return "" } // Если время вышло, текст будет пустой, отобразится "Время вышло!"
        
        let days = Int(remainingTime / (3600 * 24))
        let hours = Int((remainingTime.truncatingRemainder(dividingBy: (3600 * 24))) / 3600)
        let minutes = Int((remainingTime.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(remainingTime.truncatingRemainder(dividingBy: 60))

        if days > 0 {
            return String(format: "%d дн\n%02d ч %02d м", days, hours, minutes)
        } else if hours > 0 {
            return String(format: "%02d ч %02d м\n%02d с", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%02d м %02d с", minutes, seconds)
        } else {
            return String(format: "%02d с", seconds)
        }
    }

    private func setupTimer() {
        // Вычисляем общую продолжительность отсчета ОДИН РАЗ
        totalDuration = event.targetDate.timeIntervalSince(event.creationDate)
        // Убеждаемся, что totalDuration не отрицательна, если вдруг creationDate оказалась позже targetDate
        if totalDuration < 0 { totalDuration = 0 }

        updateRemainingTime()
    }

    private func updateRemainingTime() {
        let now = Date()
        let newRemainingTime = event.targetDate.timeIntervalSince(now)
        remainingTime = max(0, newRemainingTime)
    }
}

