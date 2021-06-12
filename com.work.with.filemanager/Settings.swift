//
//  Settings.swift
//  com.work.with.filemanager
//
//  Created by v.milchakova on 08.05.2021.
//

import UIKit

let defaults = UserDefaults.standard

class Settings: UIViewController {
    
    enum SettingType: String {
        case fileSorted
        case fileSizeShowed
    }
    
    private var fileSorted: Bool = true
    private var fileSizeShowed: Bool = true
    
    private lazy var switchFileSorted: UISwitch = {
        let switchFileSorted = UISwitch()
        switchFileSorted.addTarget(self, action: #selector(self.switchFileSortedStateDidChange(_:)), for: .valueChanged)
        let state = getUserDefault(.fileSorted) as! Bool
        switchFileSorted.setOn(state, animated: false)
        switchFileSorted.toAutoLayout()
        return switchFileSorted
    }()
    
    private lazy var switchFileSortedLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Cортировать файлы по алфавиту"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    @objc func switchFileSortedStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            print("Переключатель сортировки файлов включен")
            setUserDefault(.fileSorted, value: true)
        }
        else {
            print("Переключатель сортировки файлов выключен")
            setUserDefault(.fileSorted, value: false)
        }
    }
    
    private lazy var switchFileSizeShowed: UISwitch = {
        let switchFileSizeShowed = UISwitch()
        switchFileSizeShowed.addTarget(self, action: #selector(self.switchFileSizeShowedStateDidChange(_:)), for: .valueChanged)
        let state = getUserDefault(.fileSizeShowed) as! Bool
        switchFileSizeShowed.setOn(state, animated: false)
        switchFileSizeShowed.toAutoLayout()
        return switchFileSizeShowed
    }()
    
    private lazy var switchFileSizeShowedLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = "Показать размер файлов"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    @objc func switchFileSizeShowedStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            print("Переключатель размера файлов включен")
            setUserDefault(.fileSizeShowed, value: true)
        }
        else {
            print("Переключатель размера файлов выключен")
            setUserDefault(.fileSizeShowed, value: false)
        }
    }
    
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.backgroundColor = .systemTeal
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(changePasswordButtonPressed), for: .touchUpInside)
        button.setTitle("Сменить пароль", for: .normal)
        button.toAutoLayout()
        return button
    }()
    
    func createNewPassword() {
        defaults.set("123", forKey: "newPassword")
        let vc = LogInViewController()
        vc.navigationController?.navigationBar.isHidden = true
        vc.modalPresentationStyle = .popover
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func changePasswordButtonPressed() {
        print("Нажали кнопку смены пароля")
        createNewPassword()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.tabBarController?.tabBar.isHidden = false
        setDefaultValues()
        view.addSubview(switchFileSorted)
        view.addSubview(switchFileSizeShowed)
        view.addSubview(switchFileSortedLabel)
        view.addSubview(switchFileSizeShowedLabel)
        view.addSubview(changePasswordButton)
        setConstraints()
    }
    
    let baseConstant: CGFloat = 20
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            switchFileSorted.topAnchor.constraint(equalTo: view.topAnchor, constant: baseConstant*5),
            switchFileSorted.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseConstant),
            switchFileSorted.heightAnchor.constraint(equalToConstant: baseConstant*2),
            switchFileSorted.widthAnchor.constraint(equalToConstant: baseConstant*2),
            
            switchFileSizeShowed.topAnchor.constraint(equalTo: switchFileSorted.bottomAnchor, constant: baseConstant),
            switchFileSizeShowed.leadingAnchor.constraint(equalTo: switchFileSorted.leadingAnchor),
            switchFileSizeShowed.heightAnchor.constraint(equalToConstant: baseConstant*2),
            switchFileSizeShowed.widthAnchor.constraint(equalToConstant: baseConstant*2),
            
            switchFileSortedLabel.topAnchor.constraint(equalTo: switchFileSorted.topAnchor),
            switchFileSortedLabel.leadingAnchor.constraint(equalTo: switchFileSorted.trailingAnchor, constant: baseConstant),
            switchFileSortedLabel.heightAnchor.constraint(equalToConstant: baseConstant*2),
            switchFileSortedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            switchFileSizeShowedLabel.topAnchor.constraint(equalTo: switchFileSizeShowed.topAnchor),
            switchFileSizeShowedLabel.leadingAnchor.constraint(equalTo: switchFileSizeShowed.trailingAnchor, constant: baseConstant),
            switchFileSizeShowedLabel.heightAnchor.constraint(equalToConstant: baseConstant*2),
            switchFileSizeShowedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            changePasswordButton.topAnchor.constraint(equalTo: switchFileSizeShowedLabel.bottomAnchor, constant: baseConstant),
            changePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(baseConstant)),
            changePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: baseConstant),
            changePasswordButton.heightAnchor.constraint(equalToConstant: baseConstant*2),
            changePasswordButton.widthAnchor.constraint(equalToConstant: baseConstant*5),
        ])
    }
    
    func setUserDefault(_ key: SettingType, value: Any) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func getUserDefault(_ key: SettingType) -> Any? {
        defaults.value(forKey: key.rawValue)
    }
    
    func setDefaultValues() {
        
        if UserDefaults.standard.object(forKey: "fileSorted") == nil {
            print("Нет значения для сортировки файлов")
            defaults.set(true, forKey: "fileSorted")
        }
        if UserDefaults.standard.object(forKey: "fileSizeShowed") == nil {
            print("Нет значения для размера файлов")
            defaults.set(true, forKey: "fileSizeShowed")
        }
        fileSorted = defaults.object(forKey: "fileSorted") as? Bool ?? true
        fileSizeShowed = defaults.object(forKey: "fileSizeShowed") as? Bool ?? true
    }
}
