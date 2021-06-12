//
//  ViewController.swift
//  com.work.with.filemanager
//
//  Created by v.milchakova on 20.04.2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private let baseConstant: CGFloat = 20
    private let table = UITableView(frame: .zero, style: .grouped)
    let fm = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        view.backgroundColor = .white
        
        print(fm.urls(for: .documentDirectory, in: .userDomainMask))
        table.toAutoLayout()
        table.allowsSelection = false

        table.register(UITableViewCell.self, forCellReuseIdentifier: "reuseId")
        table.dataSource = self
        
        table.backgroundColor = .white
        view.addSubview(addPhotoButton)
        view.addSubview(addFolderButton)
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseConstant),
            addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseConstant),
            
            addFolderButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: baseConstant),
            addFolderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(baseConstant)),
            
            table.topAnchor.constraint(equalTo: addFolderButton.bottomAnchor, constant: baseConstant),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.backgroundColor = .systemPink
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("Добавить фото", for: .normal)
        button.addTarget(self, action: #selector(btnClicked), for:.touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    private lazy var addFolderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.backgroundColor = .systemPink
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.setTitle("Создать папку", for: .normal)
        button.addTarget(self, action: #selector(showAlert), for:.touchUpInside)
        button.toAutoLayout()
        return button
    }()
    
    @objc func showAlert() {
        let ac = UIAlertController(title: "Введите название папки", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "OK", style: .default) { [self, unowned ac] _ in
            let answer = ac.textFields![0]
            createDirectory(name: answer.text!)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    var imagePicker = UIImagePickerController()

    @objc func btnClicked() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Кликнули кнопоку добавления фото")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func createDirectory(name: String) {
        if name.isEmpty { return }
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let logsPath = documentsPath.appendingPathComponent(name)
        print(logsPath!)
        do {
            try fm.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
            
        } catch let error as NSError {
            print("Не пошлучилось создать папку",error)
        }
        table.reloadData()
    }
    
    func saveImage(data: Data?) {
        let documentsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let result = formatter.string(from: date)
        
        let fileName = "image-\(result).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if let data = data, !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                print("Изображение сохранено")
            } catch {
                print("Не смогли сохранить изображение:", error)
            }
        }
        table.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let result = image?.jpegData(compressionQuality:  1.0)
        saveImage(data: result)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func toAutoLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowsCount = getFiles().count
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseId", for: indexPath)
        let allUrls = getFiles()
        let file = getFilesSorted()[indexPath.row]
        let fileSizeShowed = defaults.value(forKey: "fileSizeShowed") as? Bool ?? true

        if fileSizeShowed {
            let attr : NSDictionary? = try! fm.attributesOfItem(atPath: allUrls[indexPath.row].path) as NSDictionary
            if let _attr = attr {
                let size = _attr.fileSize()
                cell.textLabel?.text = "\(file), \(size) bytes"
            }
        } else {
            cell.textLabel?.text = file
        }
        return cell
    }
    
    func getFiles() -> [URL] {
        var urls: [URL]
        urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        do {
            urls = try fm.contentsOfDirectory(at: urls[0], includingPropertiesForKeys: nil)
            print("Все файлы и папки: \(urls)")
        } catch {
            print("Не получили файлы и папки: \(error.localizedDescription)")
        }
        return urls
    }
    
    func getFilesSorted() -> [String] {
        let files = getFiles()
        var filePaths = [String]()
        for (index, _) in files.enumerated() {
            filePaths.append((files[index].path as NSString).lastPathComponent)
        }
        
        if defaults.value(forKey: "fileSorted") as? Bool ?? true {
            filePaths = filePaths.sorted { $0 < $1 }
        } else {
            filePaths = filePaths.sorted { $0 > $1 }
        }
        return filePaths
    }
}
