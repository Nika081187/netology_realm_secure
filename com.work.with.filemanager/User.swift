//
//  User.swift
//  com.work.with.filemanager
//
//  Created by v.milchakova on 16.05.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login: String?
    @objc dynamic var password: String?
}
