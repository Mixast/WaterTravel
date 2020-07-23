import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    let navigator = Navigator()
    var user = UserProfile()
    private let bag = DisposeBag()
    
    init(user: UserProfile) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.tintColor = .darkText
        tabBar.barTintColor = .white
                
        self.navigationController?.navigationBar.isHidden = true
        let priceViewModel = PriceViewModel(user: user)
        let priceBasket = priceViewModel.basket
        let priceViewController = PriceViewController.createWith(navigator: navigator, storyboard: R.storyboard.priceViewController(), viewModel: priceViewModel)
        let price = createNavController(viewController: priceViewController, tilteLable: "Прайс лист", bagValue: priceBasket, selectedImage: R.image.list()!, unselectedImage: R.image.list()!)
        
        let bagViewModel = BagViewModel(element: priceBasket, user: user)
        let bagBasket = bagViewModel.shoppingList
        let bagViewController = BagViewController.createWith(navigator: navigator, storyboard: R.storyboard.priceViewController(), viewModel: bagViewModel)
        let bag = createNavController(viewController: bagViewController, tilteLable: "Корзина", bagValue: bagBasket, selectedImage: R.image.bag()!, unselectedImage: R.image.bag()!)
        
        let historyViewModel = HistoryViewModel(user: user)
        let historyController = HistoryViewController.createWith(navigator: navigator, storyboard: R.storyboard.historyViewController(), viewModel: historyViewModel)
        let history = createNavController(viewController: historyController, tilteLable: "Мои заказы", selectedImage: R.image.history()!, unselectedImage: R.image.history()!)
        
        let profileViewModel = ProfileViewModel(user: user)
        let profileController = ProfileViewController.createWith(navigator: navigator, storyboard: R.storyboard.profileViewController(), viewModel: profileViewModel)
        let profile = createNavController(viewController: profileController, tilteLable: "Мои адреса", selectedImage: R.image.profile()!, unselectedImage: R.image.profile()!)
        
        viewControllers = [price, bag, history, profile]
        
    }
    
    fileprivate func createNavController(viewController: UIViewController , tilteLable: String, bagValue: BehaviorRelay<[Price]?> = BehaviorRelay<[Price]?>(value: []), selectedImage: UIImage, unselectedImage: UIImage) -> UIViewController {

        let navController = UINavigationController(rootViewController: viewController)
        if tilteLable == "Корзина" {
            // MARK: - Счетчик корзины
            bagValue.asDriver()
                .drive(onNext: { value in
                    if value?.count == 0 {
                        navController.tabBarItem.title = " "
                    } else {
                        var allValue = 0
                        for i in 0..<value!.count {
                            value![i].countBag.asDriver()
                                .filter({ list in
                                    if list == 0 {
                                        return false
                                    }
                                    return true
                                })
                                .drive(onNext: { intoValue in
                                    allValue = 0
                                    guard let bag = bagValue.value else {
                                        return
                                    }
                                    for m in 0..<bag.count {
                                        allValue += bag[m].countBag.value ?? 0
                                    }
                                    
                                    navController.tabBarItem.title = String(describing: allValue)
                                })
                                .disposed(by: self.bag)
                            
                        }
                    }
                })
                .disposed(by: bag)
        }
    
        
        navController.tabBarItem.title = " "
        viewController.navigationItem.title = tilteLable
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.barTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        viewController.view.backgroundColor = .white
        navController.view.tintColor = .white
        return navController
        
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 50
        return sizeThatFits
    }
}
