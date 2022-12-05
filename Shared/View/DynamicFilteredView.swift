//
//  DynamicFilteredView.swift
//  Tasks (iOS)
//
//  Created by Teruya Hasegawa on 02/05/22.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject {
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    // MARK: Building Custom ForEach which will give Coredata object to build View
    init(currentTab: String,@ViewBuilder content: @escaping (T)->Content){
    
        // MARK: Predicate to Filter current date Tasks
        let calendar = Calendar.current
        var predicate: NSPredicate!
        if currentTab == "今日"{
            let today = calendar.startOfDay(for: Date())
            let tommorow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 HRS
            // 0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today,tommorow,0])
        }else if currentTab == "今後"{
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tommorow = Date.distantFuture
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 HRS
            // 0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today,tommorow,0])
        }else if currentTab == "未完"{
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 HRS
            // 0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past,today,0])
        }
        else{
            // 0-false, 1-true
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
        }
        // Intializing Request With NSPredicate
        // Adding Sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.deadline, ascending: false)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        
        Group{
            if request.isEmpty{
                Text("タスクが見つかりません")
                    .foregroundColor(Color.gray.opacity(0.7))
                    .font(.callout.bold())
                    .offset(y: 100)
            }
            else{
                
                ForEach(request,id: \.objectID){object in
                    self.content(object)
                }
            }
        }
    }
}
