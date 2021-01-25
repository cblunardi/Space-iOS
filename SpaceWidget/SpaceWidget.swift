import WidgetKit
import SwiftUI

struct SpaceWidgetEntryView: View {
    @Environment(\.widgetFamily) var family

    var entry: WidgetImageProvider.Entry

    var contentPadding: CGFloat {
        switch family {
        case .systemSmall, .systemMedium:
            return 4
        case .systemLarge:
            return 8
        @unknown default:
            return 4
        }
    }

    var body: some View {
        switch entry.result {
        case let .failure(failure):
            return AnyView(Text(failure.localizedDescription).minimumScaleFactor(0.2))
        case let .success(content):
            return AnyView(entryView(content: content))
        }
    }

    private func entryView(content: WidgetEntry.Content) -> some View {
        ZStack {
            Color.black
            imageView(image: content.image)
        }.overlay(titleView(title: content.title), alignment: .bottom)
    }

    private func titleView(title: String) -> some View {
        Text(title)
            .background(Color.clear)
            .foregroundColor(.white)
            .opacity(0.5)
            .font(.footnote)
            .padding(.bottom, contentPadding)
    }

    private func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.bottom, contentPadding)
    }
}

@main
struct SpaceWidget: Widget {
    let kind: String = "SpaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetImageProvider()) { entry in
            SpaceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Localized.widgetDisplayName())
        .description(Localized.widgetDescription())
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct SpaceWidget_Previews: PreviewProvider {
    static var previews: some View {
        SpaceWidgetEntryView(entry: .placeholder(family: .systemSmall))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
