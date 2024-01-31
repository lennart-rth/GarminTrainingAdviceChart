//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.WatchUi;
import Toybox.Lang;

//! Creates a web request on menu / select events
class ImReady4Delegate extends WatchUi.BehaviorDelegate {
    

    //! Set up the callback to the view
    //! @param handler Callback method for when data is received
    public function initialize(handler as Method(args as Dictionary or String or Null) as Void) {
        WatchUi.BehaviorDelegate.initialize();
    }

    //! On a select event, make a web request
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        var request = new IntervalsRequest();
        request.makeRequest();
        return true;
    }

}