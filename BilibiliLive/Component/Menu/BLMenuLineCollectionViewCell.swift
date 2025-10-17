//
//  BLMenuLineCollectionViewCell.swift
//  BilibiliLive
//
//  Created by ManTie on 2024/7/4.
//

import UIKit

class BLMenuLineCollectionViewCell: BLSettingLineCollectionViewCell {
    var iconImageView = UIImageView()
    var normailSelectView = UIView()
    var beforeSelectCell: BLMenuLineCollectionViewCell?
    override func addsubViews() {
//        selectedWhiteView.setAutoGlassEffectView(cornerRadius: selectedWhiteView.height / 2)
        // 上下选择的view
        selectedWhiteView.setCornerRadius(cornerRadius: height / 2)
        selectedWhiteView.backgroundColor = UIColor(named: "menuCellColor")
        selectedWhiteView.isHidden = !isFocused
        addSubview(selectedWhiteView)
        selectedWhiteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectedWhiteView.alpha = 0.7

        // 之前选中的view
        addSubview(normailSelectView)
        normailSelectView.snp.makeConstraints { make in
            make.edges.equalTo(selectedWhiteView)
        }
        normailSelectView.isHidden = true
        normailSelectView.layer.cornerRadius = selectedWhiteView.layer.cornerRadius
        normailSelectView.backgroundColor = UIColor(named: "menuCellColor")?.withAlphaComponent(0.4)

        addSubview(iconImageView)
        let imageViewHeight = 32.0
        iconImageView.setCornerRadius(cornerRadius: imageViewHeight / 2.0)
        iconImageView.contentMode = .scaleAspectFit

        iconImageView.setImageColor(color: UIColor(named: "titleColor"))
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(imageViewHeight)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.trailing.equalToSuperview().offset(8)
            make.centerY.equalTo(iconImageView)
        }
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        titleLabel.textColor = UIColor(named: "titleColor")
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let beforeSelectCell = beforeSelectCell {
            return [beforeSelectCell]
        }
        return []
    }

    override func updateView() {
        selectedWhiteView.isHidden = !isFocused
        normailSelectView.isHidden = !isSelected
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
      
        // 前一个
        if let beforeSelectCell = context.previouslyFocusedView as? BLMenuLineCollectionViewCell {
            self.beforeSelectCell = beforeSelectCell
            if !(context.nextFocusedView is BLMenuLineCollectionViewCell) {
                setNeedsFocusUpdate()
                updateFocusIfNeeded()
            }
        }
    }
}
