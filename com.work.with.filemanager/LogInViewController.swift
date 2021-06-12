//
//  LogInViewController.swift
//  com.work.with.filemanager
//
//  Created by v.milchakova on 05.05.2021.
//

import UIKit
import RealmSwift

let account = "myAccount"

class LogInViewController: UIViewController {
    private let basePadding: CGFloat = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if authoriseUser() {
            navigationController?.pushViewController(Tabbar(), animated: true)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(errorLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(logInButton)
        setConstraints()

        defaults.removeObject(forKey: "newPassword")
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            errorLabel.heightAnchor.constraint(equalToConstant: 50),
            errorLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100),
            errorLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:basePadding),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -50),
            passwordTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:basePadding),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        if defaults.value(forKey: "newPassword") == nil && KeyChain.load(key: account) != nil {
            logInButton.setTitle("Введите пароль", for: .normal)
            NSLayoutConstraint.activate([
                logInButton.heightAnchor.constraint(equalToConstant: 50),
                logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: basePadding),
                logInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                logInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: basePadding),
                logInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                logInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            logInButton.setTitle("Создать пароль", for: .normal)
            contentView.addSubview(confirmTextField)
            
            NSLayoutConstraint.activate([
                confirmTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: basePadding),
                confirmTextField.centerXAnchor.constraint(equalTo: passwordTextField.centerXAnchor),
                confirmTextField.heightAnchor.constraint(equalToConstant: 50),
                confirmTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
                confirmTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
                
                logInButton.heightAnchor.constraint(equalToConstant: 50),
                logInButton.topAnchor.constraint(equalTo: confirmTextField.bottomAnchor, constant: basePadding),
                logInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                logInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: basePadding),
                logInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                logInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        let _ = KeyChain.remove(key: "tempPass")
        let _ = KeyChain.remove(key: "confirmPass")
        passwordTextField.text = ""
        confirmTextField.text = ""
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets = .zero
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.toAutoLayout()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemGray6
        field.isSecureTextEntry = true
        field.textColor = .black
        field.layer.cornerRadius = 10
        field.placeholder = "Пароль"
        field.font = UIFont.systemFont(ofSize: 20)
        
        let paddingView: UIView = UIView(frame: CGRect(x: 10, y: 0, width: 20, height: 50))
        field.leftView = paddingView
        field.leftViewMode = .always

        field.toAutoLayout()
        return field
    }()
    
    private lazy var confirmTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemGray6
        field.isSecureTextEntry = true
        field.textColor = .black
        field.layer.cornerRadius = 10
        field.placeholder = "Подтверждение"
        field.font = UIFont.systemFont(ofSize: 20)
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 50))
        field.leftView = paddingView
        field.leftViewMode = .always

        field.toAutoLayout()
        return field
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var logInButton: UIButton = {
        let logInButton = UIButton(type: .system)
        logInButton.setTitleColor(.gray, for: .normal)
        logInButton.layer.cornerRadius = 10
        logInButton.layer.masksToBounds = false
        logInButton.clipsToBounds = true
        logInButton.backgroundColor = .cyan
        logInButton.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        logInButton.addTarget(self, action: #selector(loginButtonPressed), for:.touchUpInside)
        logInButton.toAutoLayout()
        return logInButton
    }()
    
    @objc func loginButtonPressed() {
        print("Нажали кнопку логина")
        if let pass = passwordTextField.text, let confirm = confirmTextField.text {
            let loginButtonText = logInButton.titleLabel?.text
            if loginButtonText == "Введите пароль" {
                if checkAccount(pass: pass) {
                    navigationController?.pushViewController(Tabbar(), animated: true)
                    return
                } else {
                    errorLabel.text = "Авторизация не удалась, попробуйте еще раз"
                    return
                }
            }
            if loginButtonText == "Создать пароль" || loginButtonText == "Повторите пароль" {
                if pass.isEmpty || confirm.isEmpty {
                    errorLabel.text = "Заполните Пароль и Подтверждение"
                    return
                }
                if pass.count != 4 || confirm.count != 4 {
                    errorLabel.text = "Пароль и Подтверждение должны содержать 4 символа"
                    return
                }
                if !checkPassAndConfirm() {
                    errorLabel.text = "Пароль и Подтверждение не совпадают"
                    return
                }
                if checkPassAndConfirm() {
                    let user = User()
                    user.login = account
                    user.password = pass
                    addUser(user: user)
                    navigationController?.pushViewController(Tabbar(), animated: true)
                }
            }
        }
    }
    
    //REALM
    func addUser(user: User) {
        do {
            guard let realm = try? Realm() else {
                print("Ошибка инициализации Realm")
                return
            }
            try realm.write {
                realm.add(user)
                print("Добавили пользователя в базу Realm")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func authoriseUser() -> Bool {
        guard let realm = try? Realm() else {
            print("Ошибка инициализации Realm")
            return false
        }
        if realm.objects(User.self).count >= 1 {
            print("Пользователь найден в базе Realm")
            return true
        } else {
            print("Пользователь НЕ найден в базе Realm")
            return false
        }
    }
    
    func checkAccount(pass: String) -> Bool {
        guard let accountPass = KeyChain.load(key: account) else {
            print("Аккаунт не создан")
            return false
        }
        let accountPassword = String(decoding: accountPass, as: UTF8.self)
        print("Подсказка, пароль: \(accountPassword)")
        return accountPassword  == pass
    }
    
    func checkPassAndConfirm() -> Bool {
        
        savePassword(text: passwordTextField.text)
        saveConfirm(text: confirmTextField.text)
        
        guard let pass1 = KeyChain.load(key: "tempPass") else {
            print("Не создан временный пароль")
            return false
        }
        
        guard let conf1 = KeyChain.load(key: "confirmPass") else {
            print("Не создано подтверждение")
            return false
        }
        
        let tempPass = String(decoding: pass1, as: UTF8.self)
        let confirm = String(decoding: conf1, as: UTF8.self)
        
        if tempPass == confirm {
            let _ = KeyChain.save(key: account, data: tempPass.data(using: .utf8)!)
            let _ = KeyChain.remove(key: "tempPass")
            let _ = KeyChain.remove(key: "confirmPass")
            print("Пароль совпал")
            return true
        }
        errorLabel.text = "Пароль и подтверждение на совпадают"
        return false
    }
    
    func saveConfirm(text: String?) {
        guard let conf = text, conf.count == 4 else {
            print("Нет подтверждения")
            return
        }
        let _ = KeyChain.save(key: "confirmPass", data: conf.data(using: .utf8)!)
        print("Запомнили подтверждение")
    }
    
    func savePassword(text: String?) {
        guard let pass = text, pass.count == 4 else {
            print("Нет пароля")
            return
        }
        let _ = KeyChain.save(key: "tempPass", data: pass.data(using: .utf8)!)
        logInButton.setTitle("Повторите пароль", for: .normal)
        print("Запомнили пароль")
    }
}

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
