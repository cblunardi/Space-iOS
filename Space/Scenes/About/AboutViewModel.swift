import UIKit

final class AboutViewModel: ViewModel {
    private(set) lazy var snapshot: SnapshotType = makeSnapshot()

    let coordinator: AboutCoordinatorProtocol
    let title: String = "About"

    init(coordinator: AboutCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

private extension AboutViewModel {
    func makeSnapshot() -> SnapshotType {
        var snapshot: SnapshotType = .init()

        snapshot.appendSections([.header])
        snapshot.appendItems([.header], toSection: .header)

        snapshot.appendSections([.options])
        snapshot.appendItems(Option.allCases.map { Item.option($0) },
                             toSection: .options)

        return snapshot
    }
}

extension AboutViewModel {
    func didSelect(_ item: Item) {
        switch item {
        case .header:
            break
        case .option(.aboutDSCVR):
            URL(string: "https://solarsystem.nasa.gov/missions/DSCOVR/in-depth/")
                .map(dependencies.appService.open(url:))
        case .option(.aboutEPIC):
            URL(string: "https://epic.gsfc.nasa.gov/about/epic")
                .map(dependencies.appService.open(url:))
        case .option(.acknowledgements):
            coordinator.showAcknowledgements()
        }
    }
}

extension AboutViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section {
        case header
        case options
        case footer
    }

    enum Item: Hashable {
        case header
        case option(Option)
    }

    enum Option: Hashable, CaseIterable {
        case aboutDSCVR
        case aboutEPIC
        case acknowledgements

        var title: String {
            switch self {
            case .aboutDSCVR: return "About DSCVR"
            case .aboutEPIC: return "About EPIC"
            case .acknowledgements: return "Acknowledgements"
            }
        }

        var image: UIImage? {
            switch self {
            case .aboutDSCVR: return UIImage(systemName: "sun.max")
            case .aboutEPIC: return UIImage(systemName: "camera.circle")
            case .acknowledgements: return UIImage(systemName: "info.circle")
            }
        }
    }
}
