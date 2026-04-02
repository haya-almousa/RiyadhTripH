import SwiftUI

struct ProfileView: View {
    // Public properties to configure the view
    var avatarImageName: String? = nil // If nil, show system placeholder
    var displayName: String = "Haya Almousa"

    // Callbacks
    var onEditProfile: (() -> Void)?
    var onTrips: (() -> Void)?
    var onFavorites: (() -> Void)?
    var onSignOut: (() -> Void)?

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                Text("Profile")
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Card content
                VStack(spacing: 20) {
                    // Avatar + name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange.opacity(0.7), lineWidth: 2)
                                )

                            if let avatarImageName, !avatarImageName.isEmpty, UIImage(named: avatarImageName) != nil {
                                Image(avatarImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, height: 80)
                            }
                        }

                        Text(displayName)
                            .font(.title3.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                    // Rows
                    VStack(spacing: 10) {
                        ProfileRow(icon: "person.text.rectangle", title: "Edit Profile") {
                            onEditProfile?()
                        }
                        ProfileRow(icon: "figure.2.and.child.holdinghands", title: "Trips") {
                            onTrips?()
                        }
                        ProfileRow(icon: "heart.fill", title: "Favorite Places") {
                            onFavorites?()
                        }
                    }
                    .padding(.horizontal, 8)

                    // Sign out button
                    Button(action: { onSignOut?() }) {
                        Text("Sign Out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(.systemGray4))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.top, 8)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundStyle(Color.purple)
                }

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            avatarImageName: nil,
            displayName: "Haya Almousa",
            onEditProfile: { print("Edit Profile tapped") },
            onTrips: { print("Trips tapped") },
            onFavorites: { print("Favorites tapped") },
            onSignOut: { print("Sign Out tapped") }
        )
    }
}
