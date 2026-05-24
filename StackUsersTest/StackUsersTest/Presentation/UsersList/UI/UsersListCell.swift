//
//  UsersListCell.swift
//  StackUsersTest
//
//  Created by Oleksii Maidanyk on 24/05/2026.
//

import UIKit

final class UsersListCell: UITableViewCell {
    static let reuseIdentifier = "UsersListCell"

    var onFollowToggled: (() -> Void)?

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

    func configure(with user: User) {
        nameLabel.text = user.displayName
        reputationLabel.text = "Reputation: \(user.reputation.formatted())"

        imageTask?.cancel()
        currentLoadId = user.id
        showPlaceholder()

        guard let url = user.profileImageURL else { return }
        let loadId = user.id
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

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [nameLabel, reputationLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(profileImageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            textStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
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
}
