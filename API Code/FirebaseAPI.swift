import Foundation
import RxSwift
import RxCocoa
import Firebase
import RxFirebase
import Unbox

typealias JSONObject = [String: Any]

protocol FirebaseAPIProtocol {
    static func auth() -> Observable<UserProfile?>
    static func list(user: UserProfile) -> Observable<[JSONObject]>
    static func history() -> Observable<[JSONObject]>
}

struct FirebaseAPI: FirebaseAPIProtocol {
    
    // MARK: - API errors
    enum Errors: Error {
        case requestFailed
    }
    
    static func auth() -> Observable<UserProfile?> {
        return Observable.create { observer in
            if Auth.auth().currentUser == nil {
                observer.onNext(nil)
                observer.onCompleted()
            } else {
                Firestore.firestore().collection("Users").addSnapshotListener { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        observer.onCompleted()
                        return
                    }
                    let user = UserProfile()
                    user.uuid = Auth.auth().currentUser?.uid
                    
                    for document in documents {
                        if document.documentID == user.uuid {
                            let description = document.data()[String(describing: document.documentID)] as! [String:Any]
                            
                            let status = String(describing: (description["Status"]) ?? "0")
                            user.status = Int(status)
                            user.userName = String(describing: (description["UserName"]) ?? "")

                            guard let adressArr = description["Adress"] as? [[String: String]] else {
                                return
                            }
                            
                            var adressMesive = [Adress]()
                            
                            for i in 0..<adressArr.count {
                                guard let adress = adressArr[i]["adress"] else {
                                    return
                                }
                                
                                guard let phoneNumber = adressArr[i]["phoneNumber"] else {
                                    return
                                }
                                
                                guard let name = adressArr[i]["name"] else {
                                    return
                                }
                                
                                let adressObj = Adress(name: name, adress: adress, phoneNumber: phoneNumber)
                                adressMesive.append(adressObj)
                            }
                            
                            user.address.accept(adressMesive)
                            user.userPhone = String(describing: (description["UserPhone"]) ?? "")
                            observer.onNext(user)
                        }
                    }
                }
            }
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    static func list(user: UserProfile) -> Observable<[JSONObject]> {
        return Observable.create { observer in
            Firestore.firestore().collection("Price").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    observer.onCompleted()
                    return
                }
                
                var arrPrice = [JSONObject]()
                
                for document in documents {
                    var price = ""
                    
                    if (user.status! == 0) {
                        price = String(describing: document.data()["price"] ?? "")
                    }
                    
                    if (user.status! == 1) {
                        let pr = String(describing: document.data()["price(1)"] ?? "")
                        if pr == "" {
                            price = String(describing: document.data()["price"] ?? "")
                        } else {
                            price = pr
                        }
                    }
                    
                    if (user.status! == 2) {
                        let pr = String(describing: document.data()["price(2)"] ?? "")
                        if pr == "" {
                            price = String(describing: document.data()["price"] ?? "")
                        } else {
                            price = pr
                        }
                    }
                    
                    if (user.status! == 3) {
                        let pr = String(describing: document.data()["price(3)"] ?? "")
                        if pr == "" {
                            price = String(describing: document.data()["price"] ?? "")
                        } else {
                            price = pr
                        }
                    }
                    
                    if (user.status! == 4) {
                        let pr = String(describing: document.data()["price(4)"] ?? "")
                        if pr == "" {
                            price = String(describing: document.data()["price"] ?? "")
                        } else {
                            price = pr
                        }
                    }
                    
                    let object: [String: Any] = [
                        "name" : document.documentID,
                        "price" : price,
                        "imageUrl" : (document.data()["image"]) ?? ""
                    ]
                    arrPrice.append(object)
                }
                observer.onNext(arrPrice)
            }
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
    static func history() -> Observable<[JSONObject]> {
        return Observable.create { observer in
            Firestore.firestore().collection("ShoppingList").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    observer.onCompleted()
                    return
                }
                
                var arrPrice = [JSONObject]()
                
                for document in documents {
                    guard let key = document.data().first?.key else {
                        return
                    }
                    
                    if key == Auth.auth().currentUser?.uid {
                        let order = document.documentID
                        guard let data = document.data()[key] as? [String: Any] else {
                            return
                        }

                        guard let dataTime = data["deliveryDate"] else {
                            return
                        }
                        
                        guard let time = dataTime as? Timestamp else {
                            return
                        }
                        
                        let timeDB = time.dateValue()
                        
                        let date = Date()
                        var dateComponents: DateComponents = DateComponents()
                        dateComponents.day = -1
                        let currentCalander: Calendar = Calendar.current
                        guard let dateCheck = currentCalander.date(byAdding:dateComponents, to: date) else {
                            return
                        }
                        
                        if timeDB < dateCheck {
                            print("Не отображаем старые заказы")
                        } else {
                            
                            guard let shoppingList = data["Shopping List"] else {
                                return
                            }
                            
                            guard let status = data["status"] else {
                                return
                            }
                            
                            guard let adress = data["Adress"] else {
                                return
                            }
                            
                            guard let shoppingListTransform = (shoppingList as? Array<Any>) else {
                                return
                            }
                            
                            guard let shoppingListTransformFN = shoppingListTransform as? [[String: Any]] else {
                                return
                            }
                            
                            var priceOBJ = [Price]()
                            for i in 0..<shoppingListTransformFN.count {
                                let name = String(describing: shoppingListTransformFN[i]["Name"] ?? "")
                                guard let price = shoppingListTransformFN[i]["Price"] as? Int else {
                                    return
                                }
                                guard let countBag = shoppingListTransformFN[i]["Count"] as? Int else {
                                    return
                                }
                                
                                guard let priceBD = try? Price(name: name,
                                                               price: price,
                                                               countBag: countBag, time: String(describing: dataTime) ) else {
                                                                return
                                }
                                
                                priceOBJ.append(priceBD)
                            }
                            
                            let object: [String: Any] = [
                                "name" : order,
                                "status" : status,
                                "adress" : adress,
                                "deliveryDate" : String(describing: timeDB.timestamp),
                                "price" : priceOBJ,
                            ]
                            
                            arrPrice.append(object)
                        }
                    }
                    
                }
                observer.onNext(arrPrice)
                
            }
            return Disposables.create {
                observer.onCompleted()
            }
        }
    }
    
}
