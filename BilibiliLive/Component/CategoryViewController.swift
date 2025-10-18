//
//  CategoryViewController.swift
//  BilibiliLive
//
//  Created by yicheng on 2023/2/26.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController, BLTabBarContentVCProtocol {
    struct CategoryDisplayModel {
        let title: String
        let contentVC: UIViewController
        var autoSelect: Bool? = true
    }

    var typeCollectionView: UICollectionView!
    var categories = [CategoryDisplayModel]()
    let contentView = UIView()
    weak var currentViewController: UIViewController?
    private var currentIndex: IndexPath?

    private var isFirstShowMenus = false
    private var isShowFocusToMainView = false

    private var leftCollectionViewShowLeft: CGFloat = 40.0
    private var leftCollectionViewHiddenLeft: CGFloat = -300

    override func viewDidLoad() {
        super.viewDidLoad()
        if categories.isEmpty {
        } else {
            initTypeCollectionView()
        }

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(forName: EVENT_COLLECTION_TO_SHOW_MENU, object: nil, queue: .main) { [weak self] _ in
            self?.hiddenMenus()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func initTypeCollectionView() {
        if typeCollectionView != nil {
            return
        }

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        typeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: BLSettingLineCollectionViewCell.makeLayout())
        typeCollectionView.register(BLSettingLineCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(typeCollectionView)
        typeCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.width.equalTo(300)
        }
        typeCollectionView.dataSource = self
        typeCollectionView.delegate = self
        typeCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
        collectionView(typeCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))

        let backgroundView = UIView()
        if #available(tvOS 26.0, *) {
            backgroundView.setAutoGlassEffectView(cornerRadius: bigSornerRadius)
        } else {
            backgroundView.setBlurEffectView(cornerRadius: lessBigSornerRadius)
            backgroundView.setCornerRadius(cornerRadius: lessBigSornerRadius, borderColor: .lightGray, borderWidth: 0.5)
        }

        view.insertSubview(backgroundView, at: 1)
        backgroundView.snp.makeConstraints { make in
            make.left.right.equalTo(typeCollectionView)
            make.top.equalTo(typeCollectionView).offset(-20)
            make.bottom.equalTo(typeCollectionView).offset(20)
        }
    }

    func setViewController(vc: UIViewController) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        currentViewController = vc
        addChild(vc)
        contentView.addSubview(vc.view)
        vc.view.makeConstraintsToBindToSuperview()
        vc.didMove(toParent: self)
    }

    func reloadData() {
        (currentViewController as? BLTabBarContentVCProtocol)?.reloadData()
    }

    func focus(on indexPath: IndexPath) {
        currentIndex = indexPath
        view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if isShowFocusToMainView, let currentViewController = currentViewController {
            return [currentViewController]
        }
        guard let indexPath = currentIndex,
              let cell = typeCollectionView.cellForItem(at: indexPath) else {
            return [typeCollectionView]
        }
        return [cell]
    }

    func hiddenMenus() {
        isShowMenus(isFocused: false)
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BLSettingLineCollectionViewCell
        cell.titleLabel.text = categories[indexPath.item].title

        cell.didUpdateFocus = { [weak self] isFocused in
            self?.isShowMenus(isFocused: isFocused)
        }
        return cell
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
                self.typeCollectionView.snp.updateConstraints { make in
                    make.left.equalToSuperview().offset(leftCollectionViewShowLeft)
                }
                view.layoutIfNeeded()
            }
        } else {
            isShowFocusToMainView = true
            UIView.animate(springDuration: 0.4, bounce: 0.6) {
                self.typeCollectionView.snp.updateConstraints { make in
                    make.left.equalToSuperview().offset(leftCollectionViewHiddenLeft)
                }
                view.layoutIfNeeded()
            }
        }
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isShowMenus(isFocused: false)
        currentIndex = indexPath
        
        BLAfter(afterTime: 0.4) {
            self.setViewController(vc: self.categories[indexPath.item].contentVC)
            
             BLAfter(afterTime: 1) {
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
        guard let nextFocusedIndexPath = context.nextFocusedIndexPath else {
            return
        }
        let categoryModel = categories[nextFocusedIndexPath.item]
        if categoryModel.autoSelect == false {
            // 不自动选中
            return
        }
        collectionView.selectItem(at: nextFocusedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        setViewController(vc: categoryModel.contentVC)
    }
}
