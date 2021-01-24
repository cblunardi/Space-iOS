import Combine

struct AboutHeaderViewModel: ViewModel, Hashable {
    let text: String =  """
    Deep Space Climate Observatory (DSCOVR) is a NOAA space weather, space climate, and Earth observation satellite.
    It was launched by SpaceX on a Falcon 9 launch vehicle on February 11, 2015, from Cape Canaveral.
    This is NOAA's first operational deep space satellite and became its primary system of warning Earth in the event of solar magnetic storms.
    """
}
