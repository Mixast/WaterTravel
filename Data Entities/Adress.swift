import Foundation

class Adress {
    @objc dynamic var name: String?
    @objc dynamic var adress: String?
    @objc dynamic var phoneNumber: String?
    
    // MARK: Init with Unboxer
    
    init(name: String = "", adress: String = "", phoneNumber: String = "") {
        self.name = name
        self.adress = adress
        self.phoneNumber = phoneNumber
    }
}
