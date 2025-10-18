//
//  PersonalViewController.swift
//  BilibiliLive
//
//  Created by yicheng on 2022/8/20.
//

import Alamofire
import Kingfisher
import SwiftyJSON
import UIKit

struct CellModel {
    var iconImage: UIImage? = nil
    let title: String
    var desp: String? = nil
    var autoSelect: Bool? = true
    var contentVC: UIViewController? = nil
    var action: (() -> Void)? = nil
}

class PersonalViewController: UIViewController, BLTabBarContentVCProtocol {
    struct CellModel {
        let title: String
        var autoSelect: Bool? = true
        var contentVC: UIViewController? = nil
        var action: (() -> Void)? = nil
    }

    static func create() -> PersonalViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: String(describing: self)) as! PersonalViewController
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet var leftCollectionView: UICollectionView!
    weak var currentViewController: UIViewController?

    @IBOutlet var menusbgView: UIView!
    @IBOutlet var menusView: UIView!

    @IBOutlet var menusLeft: NSLayoutConstraint!

    @IBOutlet var leftCollectionViewLeft: NSLayoutConstraint!

    private var currentIndex: IndexPath?
    private var leftCollectionViewShowLeft: CGFloat = 40.0
    private var leftCollectionViewHiddenLeft: CGFloat = -300

    var cellModels = [CellModel]()

    private var isFirstShowMenus = false
    private var isShowFocusToMainView = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        leftCollectionView.backgroundColor = .clear
        leftCollectionView.reloadData()
        leftCollectionView.register(BLSettingLineCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        leftCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        collectionView(leftCollectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        menusLeft.constant = leftCollectionViewShowLeft

        if #available(tvOS 26.0, *) {
            menusbgView.setGlassEffectView(style: .clear, cornerRadius: bigSornerRadius)
        } else {
            menusbgView.setBlurEffectView(cornerRadius: bigSornerRadius)
            if #available(tvOS 26.0, *) {
                menusbgView.setAutoGlassEffectView(cornerRadius: bigSornerRadius)
            } else {
                menusbgView.setBlurEffectView(cornerRadius: lessBigSornerRadius)
                menusbgView.setCornerRadius(cornerRadius: lessBigSornerRadius, borderColor: .lightGray, borderWidth: 0.5)
            }
        }

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(forName: EVENT_COLLECTION_TO_SHOW_MENU, object: nil, queue: .main) { [weak self] _ in
            self?.hiddenMenus()
        }
    }

    func setupData() {
        let setting = CellModel(title: "设置", contentVC: SettingsViewController())
        cellModels.append(setting)
//        cellModels.append(CellModel(title: "搜索", autoSelect: false, action: {
//            [weak self] in
//            let resultVC = SearchResultViewController()
//            let searchVC = UISearchController(searchResultsController: resultVC)
//            searchVC.searchResultsUpdater = resultVC
//            self?.present(UISearchContainerViewController(searchController: searchVC), animated: true)
//        }))
        cellModels.append(CellModel(title: "关注UP", contentVC: FollowUpsViewController()))
        cellModels.append(CellModel(title: "稍后再看", contentVC: ToViewViewController()))
//        cellModels.append(CellModel(title: "历史记录", contentVC: HistoryViewController()))
        cellModels.append(CellModel(title: "每周必看", contentVC: WeeklyWatchViewController()))

        let logout = CellModel(title: "登出", autoSelect: false) {
            [weak self] in
            self?.actionLogout()
        }
        cellModels.append(logout)
    }

    func setViewController(vc: UIViewController) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        currentViewController = vc
        addChild(vc)
        contentView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    func reloadData() {
        (currentViewController as? BLTabBarContentVCProtocol)?.reloadData()
    }

    func actionLogout() {
        let alert = UIAlertController(title: "确定登出？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) {
            _ in
            ApiRequest.logout {
                WebRequest.logout {
                    AppDelegate.shared.showLogin()
                }
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    func isShowMenus(isFocused: Bool) {
        if isFirstShowMenus {
            isFirstShowMenus = false
            return
        }

        if isFocused {
            isShowFocusToMainView = false
            if let currentIndex = currentIndex {
                focus(on: currentIndex)
            }

            UIView.animate(springDuration: 0.4, bounce: 0.2) {
                leftCollectionViewLeft.constant = leftCollectionViewShowLeft
                self.view.layoutIfNeeded()
            }
        } else {
            isShowFocusToMainView = true
            UIView.animate(springDuration: 0.4, bounce: 0.6) {
                leftCollectionViewLeft.constant = leftCollectionViewHiddenLeft
                self.view.layoutIfNeeded()
            }
        }
    }

    func focus(on indexPath: IndexPath) {
        currentIndex = indexPath
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if isShowFocusToMainView {
            if let currentViewController = currentViewController {
                return [currentViewController]
            }
        }
        guard let indexPath = currentIndex,
              let cell = leftCollectionView.cellForItem(at: indexPath) else {
            return [leftCollectionView]
        }
        return [cell]
    }

    func hiddenMenus() {
        isShowMenus(isFocused: false)
    }
}

extension PersonalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BLSettingLineCollectionViewCell
        cell.titleLabel.text = cellModels[indexPath.item].title
        cell.didUpdateFocus = { [weak self] isFocused in

            if isFocused && self?.leftCollectionViewLeft.constant == self?.leftCollectionViewHiddenLeft {
                self?.isShowMenus(isFocused: isFocused)
            }

            if !isFocused && self?.leftCollectionViewLeft.constant == self?.leftCollectionViewShowLeft {
                self?.isShowMenus(isFocused: isFocused)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
}

extension PersonalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentViewController != nil {
            isShowMenus(isFocused: false)
        }
        currentIndex = indexPath

        BLAfter(afterTime: 0.4) {
            var waitTime = 0.3
            let model = self.cellModels[indexPath.item]
            if let vc = model.contentVC {
                self.setViewController(vc: vc)

                if vc is ToViewViewController
                    || vc is FollowUpsViewController {
                    waitTime = 1
                } else if vc is HistoryViewController
                    || vc is WeeklyWatchViewController {
                    waitTime = 2
                }
            }
            model.action?()
            BLAfter(afterTime: waitTime) {
                BLAnimate(withDuration: 0.3) {
                    if self.isShowFocusToMainView {
                        self.view.setNeedsFocusUpdate()
                        self.view.updateFocusIfNeeded()
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if Settings.sideMenuAutoSelectChange == false {
            return
        }
        // 检查新的焦点是否是UICollectionViewCell
        guard let nextFocusedIndexPath = context.nextFocusedIndexPath else {
            return
        }
        let model = cellModels[nextFocusedIndexPath.item]
        if model.autoSelect == false {
            // 不自动选中
            return
        }
        collectionView.selectItem(at: nextFocusedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        if let vc = model.contentVC {
            setViewController(vc: vc)
        }
        model.action?()
    }
}

class EmptyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "Nothing Here"
        view.addSubview(label)
        label.makeConstraintsBindToCenterOfSuperview()
    }
}
