final class AcknowledgementsViewModel: ViewModel {
    let title: String = "Acknowledgements"

    var text: String {
        [nasa, epic, vapor, lottie, animation]
            .joined(separator: "\n\n--------------\n\n")
    }
}

private extension AcknowledgementsViewModel {
    var nasa: String {
        """
        NASA, for granting free and open usage of the NASA Open APIs.
        https://api.nasa.gov
        """
    }

    var epic: String {
        """
        NASA, NOAA and NASA ASDC for granting free and open usage of EPIC onboard NOAA's DSCOVR spacecraft.
        https://epic.gsfc.nasa.gov/about
        https://epic.gsfc.nasa.gov/about/epic
        https://www.nesdis.noaa.gov/content/dscovr-deep-space-climate-observatory
        """
    }

    var vapor: String {
        """
        The Open Source Community for Vapor, a Web Framework for Swift.
        http://github.com/vapor/vapor
        """
    }

    var lottie: String {
        """
        AirBnB for Lottie, a native animation renderer.
        https://github.com/airbnb/lottie-ios
        """
    }

    var animation: String {
        """
        Wan Souza, for the amazing Earth-Moon Loading Animation.
        https://lottiefiles.com/44415-orbit-loader-flat
        """
    }
}
