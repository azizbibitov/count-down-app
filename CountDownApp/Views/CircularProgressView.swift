//
//  CircularProgressView.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 30/06/2025.
//

import SwiftUI

// MARK: - CircularProgressView

struct CircularProgressView: View {
    let progress: Double // Прогресс от 0.0 до 1.0
    let lineWidth: CGFloat // Толщина линии прогресса
    let accentColor: Color // Цвет прогресса
    let backgroundColor: Color // Цвет фона круга

    var body: some View {
        ZStack {
            Circle() // Фон круга
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle() // Индикатор прогресса
                .trim(from: 0.0, to: progress) // Обрезаем круг до нужного прогресса
                .stroke(accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)) // Закругленные концы
                .rotationEffect(Angle(degrees: -90)) // Начинаем с верхней точки (12 часов)
                .animation(.linear, value: progress) // Анимация изменения прогресса
        }
    }
}

// MARK: - Предварительный просмотр

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            CircularProgressView(progress: 0.25, lineWidth: 10, accentColor: .blue, backgroundColor: .gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .previewDisplayName("25% Прогресс")

            CircularProgressView(progress: 0.75, lineWidth: 10, accentColor: .green, backgroundColor: .gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .previewDisplayName("75% Прогресс")

            CircularProgressView(progress: 1.0, lineWidth: 10, accentColor: .red, backgroundColor: .gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .previewDisplayName("100% Прогресс")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
