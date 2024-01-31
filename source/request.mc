import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.StringUtil; 
import Toybox.System;
import Toybox.Math;
import Toybox.Application.Properties;
import Toybox.Attention;


using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;

var zscore_hrv = [];
var zscore_rhr = [];

var apikey_set = true;
var athleteid_set = true;
var request_failed = 0;

class IntervalsRequest {
    var hrv as Lang.Array<Lang.Float or Null> = [];
    var restingHR as Lang.Array<Lang.Float or Null> = [];

    private function format_date(date as Toybox.Time.Moment) as String {
        var info = Calendar.info(date, Time.FORMAT_SHORT);
        var month = info.month;
        if (month <= 9) {
            month = "0" + month.toString();
        }
        var day = info.day;
        if (day <= 9) {
            day = "0" + day.toString();
        }
        var dateStr = Lang.format("$1$-$2$-$3$", [info.year, month, day]);
        return dateStr;
    }

    // ! Make the web request
    public function makeRequest() as Void {
        hrv = [];
        restingHR = [];
        var now = Time.now();
        var end_date = format_date(now);

        var aDuration = Calendar.duration({:days => 30});
        aDuration = aDuration.multiply(-1);
        var start = now.add(aDuration);
        
        var start_date = format_date(start);

        var api_key = Application.Properties.getValue("intervalsKEY");
        if (api_key.equals("YOUR-API-KEY") == true  or api_key.equals("") == true) {
            apikey_set = false;
        }else{
            apikey_set = true;
        }

        var athlete_id = Application.Properties.getValue("intervalsID");
        if (athlete_id.equals("YOUR-ATHLETE-ID") == true  or athlete_id.equals("") == true) {
            athleteid_set = false;
        }else{
            athleteid_set = true;
        }


        var auth = StringUtil.encodeBase64("API_KEY:"+api_key.toString());

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "accept" => "*/*",
                "Authorization" => "Basic " + auth,
            }
        };

        var param = {
            "oldest" => start_date,
            "newest" => end_date,
            "cols" => "hrv,restingHR",
        };

        var url = "https://intervals.icu/api/v1/athlete/"+athlete_id.toString()+"/wellness.json";
        Communications.makeWebRequest(
            url,
            param,
            options,
            method(:onReceive)
        );
    }
    
    private function parse_csv(data) {
        for(var i=0; i<data.size(); i+=1) {
            var json = (data as Array)[i];
            if ((json as Dictionary)["restingHR"] == null) {
                restingHR.add(null);
            }else{
                restingHR.add((json as Dictionary)["restingHR"].toFloat());
            }
            if ((json as Dictionary)["hrv"] == null) {
                hrv.add(null);
            }else{
                hrv.add((json as Dictionary)["hrv"].toFloat());
            }
        }
    }

    private function rolling(data as Lang.Array<Lang.Float or Null>, i as Number) {
        var sub = [];
        var l = 30;
        if (l > data.size()) {
            sub = data.slice(i,data.size());
        }else{
            sub = data.slice(i,i+l);
        }
        sub.remove(null);

        if (sub.size() > 1) {
            var mean = Math.mean(sub);
            var std = Math.stdev(sub, mean);
            if (std != 0 and data[i] != null){
                return (data[i] - mean) / std; 
            }else{
                return null;
            }
        } else {
            return null;
        }
    }

    private function calc_scores() {
        hrv = hrv.reverse();
        restingHR = restingHR.reverse();
        for(var i = 0; i<hrv.size(); i+=1 ) {
            zscore_hrv.add(rolling(hrv, i));
            zscore_rhr.add(rolling(restingHR, i));
        } 
        // System.println(zscore_hrv);
        // System.println(zscore_rhr);
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    public function onReceive(responseCode as Number, data as Dictionary<String, Object?> or String or Null) as Void {
        if (responseCode == 200) {
            parse_csv(data);
            calc_scores();
            if (Attention has :vibrate) {
                var vibeData = [new Attention.VibeProfile(50, 500)];
                Attention.vibrate(vibeData);  
            }
            request_failed = data.toString();
        }
        if (data == null){
            request_failed = "null";
        }else{
            request_failed = responseCode;
        }
        WatchUi.requestUpdate();
    }
}
