//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Elena Sharipova on 18.05.2023.
//

import Foundation
import CoreData

final class StorageManager {
    
    // MARK: Public Properties
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchTasks(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func createTask(withTitle title: String, completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = title
        completion(task)
        saveContext()
    }
    
    func edit(task: Task, withNewTitle title: String, completion: (Task) -> Void) {
        task.title = title
        completion(task)
        saveContext()
    }
    
    func delete(task: Task) {
        context.delete(task)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
