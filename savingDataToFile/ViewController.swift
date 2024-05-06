//
//  ViewController.swift
//  savingDataToFile
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    private var table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self
                       , forCellReuseIdentifier: "cell")
        return table
    }()

    var items = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        
        title = "To Do List"
        view.addSubview(table)
        table.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        //saving to txt-file
        
        let manager = FileManager.default
        guard let url = manager.urls(for: .documentDirectory,
                                     in: .userDomainMask).first else {
            return
        }
        print(url.path)
        
        
        let newFolderUrl = url.appendingPathComponent("to do list")
        do {
            //making directory
            try manager .createDirectory(at: newFolderUrl,
                                     withIntermediateDirectories: true,
                                     attributes: [:])
            
            //making file
            let fileUrl = newFolderUrl.appendingPathComponent("list_item.txt")
            let string: String = items.joined(separator: " |*| ")
            let data = string.data(using: .utf8)
            //let data = Data(string: string)
            manager.createFile(atPath: fileUrl.path,
                               contents: data,
                               attributes: [FileAttributeKey.creationDate:Date()])
        }
        catch {
            print(error)
        }
        print(items)
        /*
        let fileURL = URL(fileURLWithPath: url.path)
        let destinationURL = URL(string: "путь до папки")!

        var request = URLRequest(url: destinationURL)
        request.httpMethod = "POST"
        request.setValue("Authorization", forHTTPHeaderField: "OAuth-access-token")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let uploadLink = json["href"] as! String
                    var uploadRequest = URLRequest(url: URL(string: uploadLink)!)
                    uploadRequest.httpMethod = "PUT"
                    uploadRequest.httpBody = try Data(contentsOf: fileURL)

                    let uploadTask = URLSession.shared.dataTask(with: uploadRequest) { (data, response, error) in
                        guard error == nil else {
                            print("Error: \(error!)")
                            return
                        }

                        print("File uploaded successfully")
                    }

                    uploadTask.resume()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
        */

    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField {
            field in field.placeholder = "Enter item:"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty{
                    DispatchQueue.main.async {
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        currentItems.append(text)
                        UserDefaults.standard.set(currentItems, forKey: "items")
                        self?.items.append(text)
                        self?.table.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

}

