final class AcknowledgementsViewModel: ViewModel {
    let title: String = "Acknowledgements"

    var text: String {
        [nasa, epic, vapor, lottie, animation, logo]
            .joined(separator: "\n\n--------------\n\n")
    }
}

private extension AcknowledgementsViewModel {
    var nasa: String {
        """
        \(Localized.acknowledgementsNasa())
        https://api.nasa.gov
        """
    }

    var epic: String {
        """
        \(Localized.acknowledgementsEpic())
        https://epic.gsfc.nasa.gov/about
        https://epic.gsfc.nasa.gov/about/epic
        https://www.nesdis.noaa.gov/content/dscovr-deep-space-climate-observatory
        """
    }

    var vapor: String {
        """
        \(Localized.acknowledgementsVapor())
        http://github.com/vapor/vapor
        """
    }

    var lottie: String {
        """
        \(Localized.acknowledgementsLottie())
        https://github.com/airbnb/lottie-ios
        """
    }

    var animation: String {
        """
        \(Localized.acknowledgementsAnimation())
        https://lottiefiles.com/44415-orbit-loader-flat
        """
    }

    var logo: String {
        """
        \(Localized.acknowledgementsLogo())
        https://www.flaticon.com/authors/photo3idea-studio
        """
    }
}
