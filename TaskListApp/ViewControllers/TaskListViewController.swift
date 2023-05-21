//
//  TaskListViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 17.05.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    //MARK: Private properties
    private let storageManager = StorageManager.shared
    private let cellID = "cell"
    private var taskList: [Task] = []
    private var currentTaskIndex: Int?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchTasks()
    }
    
    // MARK: - Private Methods
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            storageManager.delete(task: task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentTaskIndex = indexPath.row
        showAlert(withTitle: "Edit Task", andMessage: "What do you want to edit?")
    }
}

// MARK: - SetupUI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - ShowAlert
private extension TaskListViewController {
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            if let currentTaskIndex = self?.currentTaskIndex {
                self?.edit(taskByIndex: currentTaskIndex, withNewTitle: task)
            } else {
                self?.save(task)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { [weak self] tfText in
            if let currentTaskIndex = self?.currentTaskIndex {
                tfText.placeholder = self?.taskList[currentTaskIndex].title
            } else {
                tfText.placeholder = "New Task"
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - StorageManaging
private extension TaskListViewController {
    private func fetchTasks() {
        storageManager.fetchTasks { result in
            switch result {
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskTitle: String) {
        storageManager.createTask(withTitle: taskTitle) { task in
            taskList.append(task)
            
            let indexPath = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            dismiss(animated: true)
        }
    }
    
    private func edit(taskByIndex taskIndex: Int, withNewTitle taskTitle: String) {
        storageManager.edit(task: taskList[taskIndex], withNewTitle: taskTitle) { task in
            let indexPath = IndexPath(item: taskIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            currentTaskIndex = nil
            
            dismiss(animated: true)
        }
    }
}
