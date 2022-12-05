//
//  Home.swift
//  Tasks (iOS)
//
//  Created by Teruya Hasegawa on 02/05/22.
//

import SwiftUI

struct Home: View {
    @StateObject var taskModel: TaskViewModel = .init()
    // MARK: Matched Geometry Namespace
    @Namespace var animation
    
    // MARK: Fetching Task
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.deadline, ascending: false)], predicate: nil, animation: .easeInOut) var tasks: FetchedResults<Task>
    
    // MARK: Environment Values
    @Environment(\.self) var env
    
    @State var dateText = ""
    @State var nowDate = Date()
    private let dateFormatter = DateFormatter()
    private let dateFormatter2 = DateFormatter()
    init() {
        dateFormatter.dateFormat = "MM月d日(E)"
        dateFormatter.locale = Locale(identifier: "ja_jp")
    }
    
    @State private var showingAlert = false

    
    var body: some View {
            VStack{
                HStack(alignment: .center) {
                    Text("TASKS").font(.title.bold())
                    Spacer()
                    Text(dateText.isEmpty ? "\(dateFormatter.string(from: nowDate))" : dateText).font(.title2)
                        .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                self.nowDate = Date()
                                dateText = "\(dateFormatter.string(from: nowDate))"
                            }
                        }
                  
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                CustomSegmentedBar()
                    .padding(.top,5)
                TaskView()
            }
            .padding(.horizontal)
            .padding(.vertical)
        .overlay(alignment: .bottomTrailing) {
            Button {
                taskModel.openEditTask.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
                    .background{
                        Circle()
                            .fill( .black)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $taskModel.openEditTask) {
            taskModel.resetTaskData()
        } content: {
            AddNewTask()
                .environmentObject(taskModel)
        }
    }
    
    // MARK: TaskView
    @ViewBuilder
    func TaskView()->some View{
        ScrollView( showsIndicators: false) {
            LazyVStack(spacing: 20){
                DynamicFilteredView(currentTab: taskModel.currentTab) { (task: Task) in
                    TaskRowView(task: task)
                }
            }
            .padding(.top, 5)
        }
    }
    
    // MARK: Task Row View
    @ViewBuilder
    func TaskRowView(task: Task)->some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.3))
                    }
                    .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 0.2)
                                )
                
                Spacer()
            
                    Button {
                        taskModel.editTask = task
                        taskModel.openEditTask = true
                        taskModel.setupTask()
                    } label: {
                        Image(systemName: "square.and.pencil")
                           
                            .foregroundColor(.black)
                    }
                
                
                
          
                
                
                
           
            }
            
            
            
            
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundColor(.black)
                .padding(.vertical,8)
            
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text("\(dateFormatter.string(from: task.deadline ?? Date()))" ).font(.caption)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
            
               Spacer()
                
                if !task.isCompleted && taskModel.currentTab != "未完"{
                    Button {
                        self.showingAlert = true
                    } label: {
                        Circle()
                            .strokeBorder(.black,lineWidth: 1.5)
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                    .alert(isPresented: $showingAlert) {
                              Alert(title: Text("メッセージ"),
                                    message: Text("タスクを完了してもよろしいですか？"),
                                    primaryButton: .cancel(Text("キャンセル")),
                                    secondaryButton: .default(Text("OK"), action: {
                                  task.isCompleted.toggle()
                                  try? env.managedObjectContext.save()
                              }))
                        
                          }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(task.color ?? "Yellow"))
        }
    }
    
    // MARK: Custom Segmented Bar
    @ViewBuilder
    func CustomSegmentedBar()->some View{
        // In Case if we Missed the Task
        let tabs = ["今日","今後","完了","未完"]
        HStack(spacing: 0){
            ForEach(tabs,id: \.self){tab in
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(taskModel.currentTab == tab ? .white : .black)
                    .padding(.vertical,6)
                    .frame(maxWidth: .infinity)
                    .background{
                        if taskModel.currentTab == tab{
                            Capsule()
                                .fill(.black)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation{taskModel.currentTab = tab}
                    }
            }
        }
        Rectangle()
            .foregroundColor(Color.gray.opacity(0.3))
              .frame(height: 2)
    }
    
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
