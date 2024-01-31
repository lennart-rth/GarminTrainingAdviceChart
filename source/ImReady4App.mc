import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ImReady4App extends Application.AppBase {

    public function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    public function onStart(state as Dictionary?) as Void {
        var request = new IntervalsRequest();
        request.makeRequest();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        var view = new $.ImReady4View();
        var delegate = new $.ImReady4Delegate(view.method(:onReceive));
        return [view, delegate] as Array<Views or InputDelegates>;
        // return [ new ImReady4View() ] as Array<Views or InputDelegates>;
    }

}

// function getApp() as ImReady4App {
//     return Application.getApp() as ImReady4App;
// }