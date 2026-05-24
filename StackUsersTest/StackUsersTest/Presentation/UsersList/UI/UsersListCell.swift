//
//  UsersListCell.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import UIKit

final class UsersListCell: UITableViewCell {
    static let reuseIdentifier = "UsersListCell"

    var toggleFollow: (() -> Void)?

    // MARK: - UI

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray5
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let reputationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var imageTask: Task<Void, Never>?
    private var currentLoadId: Int?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        currentLoadId = nil
        showPlaceholder()
    }

    // MARK: - Configure

    func configure(with item: UserListItem) {
        nameLabel.text = item.user.displayName
        reputationLabel.text = "Rep: \(item.user.reputation.formatted())"

        updateFollowButton(isFollowed: item.isFollowed)

        imageTask?.cancel()
        currentLoadId = item.user.id
        showPlaceholder()

        guard let url = item.user.profileImageURL else { return }
        let loadId = item.user.id
        imageTask = Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  !Task.isCancelled
            else { return }
            await MainActor.run {
                guard self?.currentLoadId == loadId else { return }
                self?.profileImageView.image = image
                self?.profileImageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    func updateFollowButton(isFollowed: Bool) {
        let symbolName = isFollowed ? "star.fill" : "star"
        let color = isFollowed ? UIColor.systemYellow : UIColor.systemGray
        
        UIView.transition(with: followButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.followButton.setImage(UIImage(systemName: symbolName), for: .normal)
            self.followButton.tintColor = color
        }
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        followButton.addTarget(self, action: #selector(onFollowTap), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, reputationLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(profileImageView)
        contentView.addSubview(textStack)
        contentView.addSubview(followButton)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            textStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: followButton.leadingAnchor, constant: -8),

            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 44),
            followButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func showPlaceholder() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = Self.placeholderImage
    }

    // Pre-rendered once: person.fill centred with padding inside a 50×50 canvas
    // for some reason without pre-render placeholder has broken layout sometimes
    private static let placeholderImage: UIImage = {
        let canvasSize = CGSize(width: 50, height: 50)
        let padding: CGFloat = 12
        let iconRect = CGRect(
            x: padding, y: padding,
            width: canvasSize.width - padding * 2,
            height: canvasSize.height - padding * 2
        )
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        let symbol = UIImage(systemName: "person.fill", withConfiguration: config)?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)

        return UIGraphicsImageRenderer(size: canvasSize).image { _ in
            symbol?.draw(in: iconRect)
        }
    }()
    
    // MARK: - Actions
    
    @objc private func onFollowTap() {
        toggleFollow?()
    }
}
