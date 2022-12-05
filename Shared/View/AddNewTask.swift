//
//  AddNewTask.swift
//  Tasks (iOS)
//
//  Created by Teruya Hasegawa on 02/05/22.
//
import SwiftUI

struct AddNewTask: View {
    @EnvironmentObject var taskModel: TaskViewModel
    // MARK: All Environment Values in one Variable
    @Environment(\.self) var env
    @Namespace var animation
    
    @State private var showingAlert = false
    var body: some View {

                

        VStack(spacing: 12){
            Text("タスクの編集")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .overlay(alignment: .trailing) {
                    
                    Button {
                        self.showingAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .opacity(taskModel.editTask == nil ? 0 : 1)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("メッセージ"),
                              message: Text("タスクを削除してもよろしいですか？"),
                              primaryButton: .cancel(Text("キャンセル")),
                              secondaryButton: .destructive(Text("削除"), action: {
                            if let editTast = taskModel.editTask{
                                env.managedObjectContext.delete(editTast)
                                try? env.managedObjectContext.save()
                                env.dismiss()
                            }
                        }))
                        
                    }
                    
                }
                .padding()
            
            ScrollView( ) {
                VStack{

                VStack(alignment: .leading, spacing: 12) {
                    Text("カラー")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // MARK: Sample Card Colors
                    let colors: [String] = ["Yellow","Green","Blue","Purple","Red","Orange"]
                    
                    HStack(spacing: 15){
                        ForEach(colors,id: \.self){color in
                            Circle()
                                .fill(Color(color))
                                .frame(width: 25, height: 25)
                                .background{
                                    if taskModel.taskColor == color{
                                        Circle()
                                            .strokeBorder(.gray)
                                            .padding(-3)
                                    }
                                }
                                .contentShape(Circle())
                                .onTapGesture {
                                    taskModel.taskColor = color
                                }
                        }
                    }
                    .padding(.top,8)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                Divider()
                    .padding(.vertical,10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("カレンダー")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(taskModel.taskDeadline.formatted(date: .abbreviated, time: .omitted) + ", " + taskModel.taskDeadline.formatted(date: .omitted, time: .shortened))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.top,8)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        taskModel.showDatePicker.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("タイトル")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $taskModel.taskTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.top,8)
                }
                .padding(.top,10)
                
                Divider()
                
                // MARK: Sample Task Types
                let taskTypes: [String] = ["基本","緊急","重要"]
                VStack(alignment: .leading, spacing: 12) {
                    Text("タイプ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 12){
                        ForEach(taskTypes,id: \.self){type in
                            Text(type)
                                .font(.callout)
                                .padding(.vertical,8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(taskModel.taskType == type ? .white : .black)
                                .background{
                                    if taskModel.taskType == type{
                                        Capsule()
                                            .fill(.black)
                                            .matchedGeometryEffect(id: "TYPE", in: animation)
                                    }else{
                                        Capsule()
                                            .strokeBorder(.black)
                                    }
                                }
                                .contentShape(Capsule())
                                .onTapGesture {
                                    withAnimation{taskModel.taskType = type}
                                }
                        }
                    }
                    .padding(.top,8)
                }
                .padding(.vertical,10)
                    
                Divider()
                        .padding(.bottom, 20)
                    
                
                // MARK: Save Button
                Button {
                    // MARK: If Success Closing View
                    if taskModel.addTask(context: env.managedObjectContext){
                        env.dismiss()
                    }
                } label: {
                    Text("保存")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,12)
                        .foregroundColor(.white)
                        .background{
                            Capsule()
                                .fill(.black)
                        }
                }
                .frame(maxHeight: .infinity,alignment: .bottom)
                .padding(.bottom,10)
                .disabled(taskModel.taskTitle == "")
                .opacity(taskModel.taskTitle == "" ? 0.6 : 1)
            }
            .frame(maxHeight: .infinity,alignment: .top)
            .padding(.horizontal)
            .overlay {
                ZStack{
                    if taskModel.showDatePicker{
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                            .onTapGesture {
                                taskModel.showDatePicker = false
                            }
                        // MARK: Disabling Past Dates
                        DatePicker.init("", selection: $taskModel.taskDeadline)
                            .padding()
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .background(.white,in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                            .padding()
                    }
                }
                .animation(.none, value: taskModel.showDatePicker)
            }
        }
    }
    }
    
}

struct AddNewTask_Previews: PreviewProvider {
    static var previews: some View {
        AddNewTask()
            .environmentObject(TaskViewModel())
    }
}
