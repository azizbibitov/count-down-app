//
//  CountdownListRow.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI

// MARK: - CountdownListRow

struct CountdownListRow: View {
    let event: CountdownEvent // Принимаем объект CountdownEvent для отображения

    var body: some View {
        HStack { // Горизонтальный стек для расположения элементов
            VStack(alignment: .leading) { // Вертикальный стек для названия и даты
                Text(event.name)
                    .font(.headline) // Крупнее шрифт для названия
                Text("Когда: \(event.targetDate, formatter: DateFormatter.eventDateFormatter)")
                    .font(.subheadline) // Меньше шрифт для даты
                    .foregroundStyle(.gray) // Серый цвет текста
            }
            Spacer() // Отталкивает содержимое влево
            // Здесь мы могли бы добавить маленький индикатор оставшегося времени,
            // но пока оставим это для экрана детализации.
        }
        .padding(.vertical, 4) // Небольшой вертикальный отступ для каждой строки
    }
}

// MARK: - Расширение DateFormatter для удобства форматирования даты

extension DateFormatter {
    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Например, "28 июня 2025 г."
        formatter.timeStyle = .short // Например, "17:30"
        formatter.locale = Locale.current // Используем текущую локаль пользователя
        return formatter
    }()
}

// MARK: - Предварительный просмотр

struct CountdownListRow_Previews: PreviewProvider {
    static var previews: some View {
        // Пример события для предварительного просмотра
        let sampleEvent = CountdownEvent(name: "День рождения", targetDate: Date().addingTimeInterval(3600 * 24 * 30)) // Через 30 дней
        
        CountdownListRow(event: sampleEvent)
            .previewLayout(.sizeThatFits) // Подгоняем размер под содержимое
            .padding()
    }
}
