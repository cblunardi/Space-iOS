import WidgetKit
import SwiftUI

struct SpaceWidgetEntryView : View {
    @Environment(\.widgetFamily) var family

    var entry: Provider.Entry

    var body: some View {
        switch entry.content {
        case let .failure(failure):
            return AnyView(Text(failure.localizedDescription).minimumScaleFactor(0.2))
        case let .image(title, image):
            return AnyView(entryView(title: title, image: image))
        case .placeholder:
            return AnyView(entryView(title: .placeholder, image: UIImage(named: "PlaceholderImage")!))
        }
    }

    private func entryView(title: ImageEntry.Content.Title, image: UIImage) -> some View {
        ZStack {
            Color.black
            imageView(image: image)
        }.overlay(titleView(title: title), alignment: .bottom)
    }

    private func titleView(title: ImageEntry.Content.Title) -> some View {
        let padding: CGFloat
        switch family {
        case .systemSmall: padding = 2
        case .systemMedium: padding = 2
        case .systemLarge: padding = 8
        @unknown default: padding = 6
        }

        return Text(title.text(for: family))
            .background(Color.clear)
            .foregroundColor(.white)
            .opacity(0.5)
            .font(.footnote)
            .padding([.all], padding)
    }

    private func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
    }
}

@main
struct SpaceWidget: Widget {
    let kind: String = "SpaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SpaceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SpaceWidget_Previews: PreviewProvider {
    static var previews: some View {
        SpaceWidgetEntryView(entry: .init(content: .failure(NSError(domain: "test", code: -1, userInfo: nil))))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private extension ImageEntry.Content.Title {
    func text(for widgetFamily: WidgetFamily) -> String {
        switch widgetFamily {
        case .systemSmall: return medium
        case .systemMedium: return medium
        case .systemLarge: return large
        @unknown default: return medium
        }
    }
}
