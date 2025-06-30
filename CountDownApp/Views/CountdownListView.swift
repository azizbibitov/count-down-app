//
//  CountdownListView.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI
import GRDB

// MARK: - CountdownListView

struct CountdownListView: View {
    @State private var events: [CountdownEvent] = []
    @State private var showingAddEditSheet = false
    @State private var eventToEdit: CountdownEvent?

    var body: some View {
        NavigationView {
            List {
                if events.isEmpty {
                    // ИСПРАВЛЕНИЕ: Используем более универсальный способ для ContentUnavailableView
                    // или просто VStack, если нужен более старый iOS
                    ContentUnavailableView { // Используем замыкание для содержимого
                        Label("Нет событий", systemImage: "timer")
                    } description: { // description теперь отдельное замыкание
                        Text("Нажмите '+' чтобы добавить новое событие обратного отсчета.")
                    }
                    // Если у тебя iOS < 17, используй это вместо ContentUnavailableView:
                    /*
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "timer")
                            .font(.largeTitle)
                            .padding(.bottom, 5)
                        Text("Нет событий")
                            .font(.headline)
                        Text("Нажмите '+' чтобы добавить новое событие обратного отсчета.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Чтобы занимал все доступное пространство
                     */

                } else {
                    ForEach(events) { event in
                        NavigationLink(destination: CountdownDetailView(event: event)) {
                            CountdownListRow(event: event)
                                .contextMenu {
                                    Button("Редактировать") {
                                        eventToEdit = event
                                        showingAddEditSheet = true
                                    }
                                    Button("Удалить", role: .destructive) {
                                        deleteEvent(event)
                                    }
                                }
                        }
                    }
                    .onDelete(perform: deleteEvents)
                }
            }
            .navigationTitle("Мои Отсчеты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        eventToEdit = nil
                        showingAddEditSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddEditSheet) {
                AddEditCountdownView(eventToEdit: $eventToEdit) { newOrUpdatedEvent in
                    loadEvents()
                }
            }
            .onAppear(perform: loadEvents)
        }
    }

    // MARK: - Методы работы с данными

    private func loadEvents() {
        do {
            events = try DatabaseManager.shared.fetchAllEvents()
        } catch {
            print("Ошибка загрузки событий: \(error)")
        }
    }

    private func deleteEvent(_ event: CountdownEvent) {
        do {
            // Отменяем запланированное уведомление ---
            NotificationManager.shared.cancelNotification(for: event)
            
            try DatabaseManager.shared.delete(event: event)
            loadEvents()
            // TODO: Отменить запланированное уведомление для этого события
        } catch {
            print("Ошибка удаления события: \(error)")
        }
    }
    
    private func deleteEvents(at offsets: IndexSet) {
        let eventsToDelete = offsets.map { self.events[$0] }
        
        for event in eventsToDelete {
            deleteEvent(event)
        }
    }
}

// MARK: - Предварительный просмотр

struct CountdownListView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownListView()
    }
}
