using Toybox.WatchUi;

class MyProgressDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        return true;
    }
}