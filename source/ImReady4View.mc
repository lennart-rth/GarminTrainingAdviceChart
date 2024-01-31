import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class ImReady4View extends WatchUi.View {

    function initialize() {
        WatchUi.View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    private function polar_to_cartesian(dc as Dc, r, t) {
        var h = dc.getHeight();
        var w = dc.getWidth(); 
        var w_center = (w/2).toFloat();
        var h_center = (h/2).toFloat();

        var xform = new AffineTransform();
        xform.translate(w_center, h_center);
        xform.rotate(Math.toRadians(-90+t));
        var pt = [r,0];
        pt = xform.transformPoint(pt);
        return pt;
    }


    private function draw_poly(dc as Dc, radius_ele, s0 as Array<Number>, s1 as Array<Number>, s2 as Array<Number>, s3 as Array<Number>, color) {
        var pts = [];
        dc.setColor(color, Graphics.COLOR_BLACK);
        var span1 = (s1[1]-s2[1]).abs();
        var span2 = (s3[1]-s0[1]).abs();
        // Fill Poly has a 64 Point limit. Then split into to polys.
        if (4+(span1)+(span2) > 64) {
            var zwi_s2 = [s2[0], s1[1] - (span1/2)];
            var zwi_s3 = [s3[0], s1[1] - (span1/2)];
            draw_poly(dc, radius_ele, s0, s1, zwi_s2, zwi_s3, color);
            draw_poly(dc, radius_ele, zwi_s3, zwi_s2, s2, s3, color);
        }
        else {
            pts.add(polar_to_cartesian(dc, s0[0] * radius_ele, s0[1]));
            pts.add(polar_to_cartesian(dc, s1[0] * radius_ele, s1[1]));
            
            for (var i=0; i<span1; i+=1) {
                pts.add(polar_to_cartesian(dc, s1[0] * radius_ele, s1[1]-i));
            }
            pts.add(polar_to_cartesian(dc, s2[0] * radius_ele, s2[1]));
            pts.add(polar_to_cartesian(dc, s3[0] * radius_ele, s3[1]));
            
            for (var i=0; i<span2; i+=1) {
                pts.add(polar_to_cartesian(dc, s3[0] * radius_ele, s3[1]+i));
            }
            dc.fillPolygon(pts);
        }

    }

    private function draw_grid(dc as Dc, r, radius_ele, pta, ptb) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);

        pta = polar_to_cartesian(dc, 0, 0) as Array<Number>;
        dc.drawCircle(pta[0],pta[1], 2*radius_ele);

        dc.drawArc(pta[0],pta[1],3*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);
        dc.drawArc(pta[0],pta[1],4*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);
        dc.setPenWidth(2);
        dc.drawArc(pta[0],pta[1],5*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);
        dc.setPenWidth(1);

        dc.drawArc(pta[0],pta[1],6*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);
        dc.drawArc(pta[0],pta[1],7*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);
        dc.drawArc(pta[0],pta[1],8*radius_ele,Graphics.ARC_CLOCKWISE,225,-45);

        pta = polar_to_cartesian(dc, 2*radius_ele, 0) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, 0) as Array<Number>;
        dc.setPenWidth(2);
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);
        dc.setPenWidth(1);

        pta = polar_to_cartesian(dc, 2*radius_ele, 45) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, 45) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);

        pta = polar_to_cartesian(dc, 2*radius_ele, 90) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, 90) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);

        pta = polar_to_cartesian(dc, 2*radius_ele, 135) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, 135) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);

        pta = polar_to_cartesian(dc, 2*radius_ele, -45) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, -45) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);

        pta = polar_to_cartesian(dc, 2*radius_ele, -90) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, -90) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);

        pta = polar_to_cartesian(dc, 2*radius_ele, -135) as Array<Number>;
        ptb = polar_to_cartesian(dc, r, -135) as Array<Number>;
        dc.drawLine(pta[0],pta[1],ptb[0],ptb[1]);
    }

    private function draw_status(dc as Dc, radius_ele) {
        if ($.zscore_hrv.size() == 0 or $.zscore_hrv.size() == 0) {
            var pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(pt[0],pt[1], 1.75*radius_ele);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
            dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, $.request_failed.toString(), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
        }
        else{
            var hrv = ($.zscore_hrv as Array<Float>)[0];
            var rhr = ($.zscore_rhr as Array<Float>)[0];

            if (hrv == null or rhr == null) {
                var pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(pt[0],pt[1], 1.75*radius_ele);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
                dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "No\ndata", Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
                dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "Invalid!\nNo data for today.", Graphics.TEXT_JUSTIFY_CENTER);
            }
            else{
                var text = "In\nvalid";
                var detail = "No data!\nSync with Garmin.";
                var color = Graphics.COLOR_LT_GRAY;

                if ((-1 < rhr) and (rhr <= 1) and (hrv > 1)) {
                    text = "HIT";
                    detail = "Ready for\nIntensive Training";
                    color = Graphics.COLOR_DK_GREEN;
                }
                else if ((-2 <= rhr) and (rhr <= -1) and (-1 <= hrv) and (hrv < 0)) {
                    text = "LIT";
                    detail = "Low\nintensity training";
                    color = Graphics.COLOR_ORANGE;
                }
                else if ((rhr <= -2) and (hrv >= 0)) {
                    text = "LIT!";
                    detail = "Keep calm\nAcute fatigue signs";
                    color = Graphics.COLOR_ORANGE;
                }
                else if ((rhr < 1.7) and (hrv >= -1)) {
                    text = "Norm";
                    detail = "Go on!\nTrain as planned.";
                    color = Graphics.COLOR_GREEN;
                }
                else if (hrv >= -1) {
                    text = "LIT";
                    detail = "Low\nintensity training";
                    color = Graphics.COLOR_ORANGE;
                }
                else if (rhr <= -2) {
                    text = "Rest";
                    detail = "Recover\nAvoid overtraining";
                    color = Graphics.COLOR_RED;
                }
                else if (rhr <= 1.7) {
                    text = "LIT";
                    detail = "Low intensity\nRecovery not complete";
                    color = Graphics.COLOR_ORANGE;
                }
                else {
                    text = "REST!";
                    detail = "Be careful\nIllness/stress detected";
                    color = Graphics.COLOR_DK_RED;
                }
                var pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
                dc.setColor(color, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(pt[0],pt[1], 1.75*radius_ele);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                pt = polar_to_cartesian(dc, 0, 0) as Array<Number>;
                dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
                dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, detail, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    private function scale_radius(radius as Float, r, radius_ele){
        radius = (radius / 3) * (3 * radius_ele);
        radius *= -1;
        radius = (5 * radius_ele) + radius;

        return radius;
    }

    private function scale_angle(angle as Float){
        angle = (angle / 3) * 135;

        return angle;
    }


    private function draw_points(dc as Dc, r, radius_ele) {
        if ($.zscore_hrv.size() != 0 or $.zscore_hrv.size() != 0) {
            var pt = [];
            var pt1 = [];
            var pt2 = [];
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            for (var i=0; i<$.zscore_hrv.size(); i+=1) {
                if (($.zscore_hrv as Array<Float>)[i] != null and ($.zscore_rhr as Array<Float>)[i] != null) {
                    var radius = scale_radius(($.zscore_hrv as Array<Float>)[i].toFloat(), r, radius_ele);
                    var angle = scale_angle(($.zscore_rhr as Array<Float>)[i].toFloat());
                    pt = polar_to_cartesian(dc, radius, angle) as Array<Number>;
                    if (i == 0) {
                        dc.setPenWidth(3);
                        dc.drawCircle(pt[0], pt[1], 14);
                    }else if (i == 1) {
                        dc.setPenWidth(3);
                        dc.drawCircle(pt[0], pt[1], 12);
                    }else if (i == 2) {
                        dc.setPenWidth(3);
                        dc.drawCircle(pt[0], pt[1], 10);
                    }else if (i == 3) {
                        dc.setPenWidth(3);
                        dc.drawCircle(pt[0], pt[1], 8);
                    }else{
                        dc.setPenWidth(3);
                        dc.fillCircle(pt[0], pt[1], 5);
                    }
                    
                    
                }
            }
            var n_trace = 4;
            if (n_trace >= $.zscore_hrv.size()) {
                n_trace = $.zscore_hrv.size()-1;
            }

            for (var i=0; i<n_trace; i+=1) {
                if (($.zscore_hrv as Array<Float>)[i] != null and ($.zscore_rhr as Array<Float>)[i] != null and ($.zscore_hrv as Array<Float>)[i+1] != null and ($.zscore_rhr as Array<Float>)[i+1] != null) {
                    dc.setPenWidth(3);
                    var radius = scale_radius(($.zscore_hrv as Array<Float>)[i].toFloat(), r, radius_ele);
                    var angle = scale_angle(($.zscore_rhr as Array<Float>)[i].toFloat());
                    pt1 = polar_to_cartesian(dc, radius, angle) as Array<Number>;

                    radius = scale_radius(($.zscore_hrv as Array<Float>)[i+1].toFloat(), r, radius_ele);
                    angle = scale_angle(($.zscore_rhr as Array<Float>)[i+1].toFloat());
                    pt2 = polar_to_cartesian(dc, radius, angle) as Array<Number>;
                    dc.drawLine(pt1[0], pt1[1], pt2[0], pt2[1]);
                }
            }
            dc.setPenWidth(1);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var r = (dc.getWidth()/2).toNumber();
        var pta = [0, 0];
        var ptb = [0, 0];

        var radius_ele = (r/8).toNumber();
        draw_poly(dc, radius_ele, [2,135],[6,135],[6,75],[2,75], Graphics.COLOR_LT_GRAY);
        draw_poly(dc, radius_ele, [6,135],[8,135],[8,75],[6,75], Graphics.COLOR_RED);
        draw_poly(dc, radius_ele, [2,75],[6,75],[6,-90],[2,-90], Graphics.COLOR_GREEN);
        draw_poly(dc, radius_ele, [6,75],[8,75],[8,-90],[6,-90], Graphics.COLOR_ORANGE);
        draw_poly(dc, radius_ele, [2,45],[4,45],[4,-45],[2,-45], Graphics.COLOR_DK_GREEN);
        draw_poly(dc, radius_ele, [2,-90],[5,-90],[5,-135],[2,-135], Graphics.COLOR_ORANGE);
        draw_poly(dc, radius_ele, [5,-90],[6,-90],[6,-135],[5,-135], Graphics.COLOR_LT_GRAY);
        draw_poly(dc, radius_ele, [6,-90],[8,-90],[8,-135],[6,-135], Graphics.COLOR_DK_GRAY);
        draw_poly(dc, radius_ele, [5,45],[6,45],[6,0],[5,0], Graphics.COLOR_PURPLE);
        draw_grid(dc, r, radius_ele, pta, ptb);


        if ($.apikey_set == true and $.athleteid_set == true and $.request_failed == 200) {
            draw_status(dc, radius_ele);
            draw_points(dc, r, radius_ele);
        }else if ($.apikey_set == false) {
            var pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "Set api key\n In settings...", Graphics.TEXT_JUSTIFY_CENTER);
        } else if ($.athleteid_set == false) {
            var pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "Set athlete id\n In settings...", Graphics.TEXT_JUSTIFY_CENTER);
        } else if ($.request_failed == 0) {
            var pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "Syncing...\nIntervals.icu", Graphics.TEXT_JUSTIFY_CENTER);
        } else if ($.request_failed != 200) {
            var pt = polar_to_cartesian(dc, 3*radius_ele, 180) as Array<Number>;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pt[0], pt[1], Graphics.FONT_XTINY, "Request failed\n"+request_failed.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    //! Show the result or status of the web request
    //! @param args Data from the web request, or error message
    public function onReceive(args as Dictionary or String or Null) as Void {
        WatchUi.requestUpdate();
    }

}
