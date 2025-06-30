//
//  CountDownAppApp.swift
//  CountDownApp
//
//  Created by Aziz Bibitov on 28/06/2025.
//

import SwiftUI

@main
struct CountDownAppApp: App {
    // Инициализируем DatabaseManager, чтобы убедиться, что база данных готова
     init() {
         _ = DatabaseManager.shared
     }
     
     var body: some Scene {
         WindowGroup {
             CountdownListView()
                 .onAppear {
                     // Запрашиваем разрешение на уведомления при запуске приложения
                     NotificationManager.shared.requestAuthorization()
                 }
         }
     }
 }
