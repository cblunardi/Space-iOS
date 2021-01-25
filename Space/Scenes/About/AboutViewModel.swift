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

        snapshot.appendSections([.footer])
        snapshot.appendItems(Footer.allCases.map { Item.footer($0) },
                             toSection: .footer)

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
        case .footer(.author):
            URL(string: "https://www.linkedin.com/in/cblunardi/")
                .map(dependencies.appService.open(url:))
        case .footer(.openSource):
            URL(string: "https://github.com/cblunardi/space-ios")
                .map(dependencies.appService.open(url:))
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
        case footer(Footer)
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

    enum Footer: Hashable, CaseIterable {
        case openSource
        case author

        var text: String {
            switch self {
            case .openSource: return "Space is build with Swift and is available open-source"
            case .author: return "This is a hobbist project from Caio Brigagão Lunardi"
            }
        }

        var image: UIImage? {
            switch self {
            case .openSource: return UIImage(systemName: "swift")
            case .author: return UIImage(systemName: "figure.wave.circle")
            }
        }
    }
}
