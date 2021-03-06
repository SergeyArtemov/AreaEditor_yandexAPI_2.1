        ??  ??                  ??  <   ??
 H T M L _ W R I T E _ O L D         0           <!DOCTYPE HTML>
<html xmlns:vml="urn:schemas-microsoft-com:vml">
<meta content="text/html; charset=windows-1251">
<meta name="viewport" content="initial-scale=1.0, user-scalable=no, maximum-scale=1" />
<!-- 20151223 -->
<!-- 20181026 -->
<head>
    <style type="text/css">
        .fi80 {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: italic
        }

        .fi80red {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #FF0000;
            font-style: italic
        }

        .fn80 {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: normal
        }

        .fi60 {
            font-size: 60%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: italic
        }

        .fn70 {
            font-size: 70%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: normal
        }
    </style>
    <style>
        html, body, #map {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
    </style>
    <!--source file is Yandex_20181207.html, key for [developer.vulgaris@yandex.ru] created at 07.12.2018 -->
    <script src="https://api-maps.yandex.ru/1.1/index.xml?key=AF9nClwBAAAA7wIWegIAi8ta87V2ij9qjk9J-4U1ZfQx2roAAAAAAAAAAACcKppvtncPlbTULMdLtMRqAdTlOg==&modules=traffic~pmap~router-editor" type="text/javascript"></script>
    <!-- ?? ???????!!! ??? ?????????? ??? ??????? ????? ??? ???????? ???? -->
    <!--<script src="http://api-maps.yandex.ru/2.0/?load=package.standard&lang=ru-RU" type="text/javascript"></script>-->
    <script src="https://api-maps.yandex.ru/2.1.78/?lang=ru_RU" type="text/javascript"></script>
    <script src="data.js" type="text/javascript"></script>
    <script type="text/javascript">

        //FieldsDelimiter  = '?';
        //RecordsDelimiter = '?';
        GroupDelimiter = '?';
        //ItemDelimiter = '?';
        AreaDelimiter = '&';
        //crlf = '\n';
        MapMode = 0; //  : 0- yandex
        CanAreaEdit = 1;
        var gpMoscowCenter = { lat: 55.755833, lng: 37.617778 };
        var gpSPBCenter = { lat: 59.95, lng: 30.316667 };
        var gpRNDCenter = { lat: 47.23132, lng: 39.72326 };
        var map = null;
        var PolygonList = [];
        var DeletedPolygonList = [];
        var MarkerList = [];
        var route = null;
        var InfoWindow = null;
        var placemark = null;
        var GreenMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAABgALAAAAAAKAAoAhwD3AAiUCAicCAitCAjWCBj/GCGcISG9ISHWISnvKTk5OUqcSkr/SlpaWlreWnNzc3t7e4yMjJTWlJycnKWlxq2tra3Orb3evcb//9bn1v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUADFgsGAggEELAjEYcCABwYCHAgYu0JBBAoGLBA4EOCDhggMCAAAUQBBgAAIEIUUySFDyokoGK1u+hJnAwgACBWDqPKAQQQKdDBAkNOAzAQKeGAICADs=";
        var YellowMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAAA4ALAAAAAAKAAoAhzk5OVpaWnNzc3t7e4yMjJSECJyMCJyMIZyUSpycnKWlxq2cCK2trb2lIcb//87Orda1CNa9IdbOlN7OWt7evefn1u/WKffWAP/nGP/vSv///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUAB04eHCggMEHAh0cmCAhwoKHBgYi0FBBAoSLEBoUaCCBwgQIFy5giFBgQYQIIUVmsFDyosoMK1u+hGnhwQIIGGDqbKAwggWdGSIkPODTQgSeDgICADs=";
        var RedMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAANEALAAAAAAKAAoAhwAAAAAAMwAAZgAAmQAAzAAA/wArAAArMwArZgArmQArzAAr/wBVAABVMwBVZgBVmQBVzABV/wCAAACAMwCAZgCAmQCAzACA/wCqAACqMwCqZgCqmQCqzACq/wDVAADVMwDVZgDVmQDVzADV/wD/AAD/MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMrADMrMzMrZjMrmTMrzDMr/zNVADNVMzNVZjNVmTNVzDNV/zOAADOAMzOAZjOAmTOAzDOA/zOqADOqMzOqZjOqmTOqzDOq/zPVADPVMzPVZjPVmTPVzDPV/zP/ADP/MzP/ZjP/mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YrAGYrM2YrZmYrmWYrzGYr/2ZVAGZVM2ZVZmZVmWZVzGZV/2aAAGaAM2aAZmaAmWaAzGaA/2aqAGaqM2aqZmaqmWaqzGaq/2bVAGbVM2bVZmbVmWbVzGbV/2b/AGb/M2b/Zmb/mWb/zGb//5kAAJkAM5kAZpkAmZkAzJkA/5krAJkrM5krZpkrmZkrzJkr/5lVAJlVM5lVZplVmZlVzJlV/5mAAJmAM5mAZpmAmZmAzJmA/5mqAJmqM5mqZpmqmZmqzJmq/5nVAJnVM5nVZpnVmZnVzJnV/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwAM8wAZswAmcwAzMwA/8wrAMwrM8wrZswrmcwrzMwr/8xVAMxVM8xVZsxVmcxVzMxV/8yAAMyAM8yAZsyAmcyAzMyA/8yqAMyqM8yqZsyqmcyqzMyq/8zVAMzVM8zVZszVmczVzMzV/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8Amf8AzP8A//8rAP8rM/8rZv8rmf8rzP8r//9VAP9VM/9VZv9Vmf9VzP9V//+AAP+AM/+AZv+Amf+AzP+A//+qAP+qM/+qZv+qmf+qzP+q///VAP/VM//VZv/Vmf/VzP/V////AP//M///Zv//mf//zP///wAAAAAAAAAAAAAAAAhWAKNFG/bHj8FhAqP9ATds2h9UBQca2jdvWCpUF1P5STVsmLZU00JqxAgylbRp2qb5+XMxpDZw2rJtROVSm81pwzZOg2nzY7RCIHv6FPjn1bRsqV4JDAgAOw==";
        var BlueMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAABgALAAAAAAKAAoAhwAA9wgIlAgInAgIrQgI1hgY/yEhnCEhvSEh1ikp7zk5OUpKnEpK/1paWlpa3nNzc3t7e4yMjJSU1pycnKWlxq2tra2tzr293sb//9bW5////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUADFgsGAggEELAjEYcCABwYCHAgYu0JBBAoGLBA4EOCDhggMCAAAUQBBgAAIEIUUySFDyokoGK1u+hJnAwgACBWDqPKAQQQKdDBAkNOAzAQKeGAICADs="
        var VioletMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAAAAALAAAAAAKAAoAhwAAAJkAAMwAAP8AAJkAmcwAmf8AmZkAzP8AzMwrzP+AzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhNAAEASEAggMEEAgEQQJDAAAEBBQceWKAgQQEBFwsEKJAgAYICBkJqxAiywAADCAwEIHAxJIKXKluifJkywcaZNAsoBEnzY0KWInUCCAgAOw==";
        ipID = 0;
        ipParentID = 1;
        ipName = 2;
        ipLevel = 3;
        ipLineColor = 4;
        ipFillColor = 5;
        ipRoute = 6;
        ipSessionID = 7;
        comZOrder = 0;
        var searchControl = null;

        /* >> ???????????? ??????? */
        function yandex_initialize() {
            ymaps.ready(function () {
                map = new ymaps.Map("map",
                    {
                        center: [gpMoscowCenter.lat, gpMoscowCenter.lng]
                        , zoom: 10
                        , behaviors: ["drag", "scrollZoom"]
                        , controls: []
                    },
                    {
                        autoFitToViewport: "none"//"always"
                        , minZoom: 3
                        , maxZoom: 19
                        , suppressMapOpenBlock: true
                    }
                );
                map.controls.add("typeSelector", { position: { right: 5, top: 5 } });
                map.controls.add("zoomControl", { position: { left: 5, top: 40 } });
                map.events.add(["click"], yandex_MapClick);
            })
        }

        function yandex_MapClick(event) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_MapClick");

            var coords = event.get('coords');
            var str = coords[0] + "," + coords[1];
            SetValueOf("ClickCoord", str);
        }

        function SetArrayOfPolygonNew(aPolygons) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfPolygonNew"/* + '{' + JSON.stringify(aPolygons) + '}'*/);

            ClearPolygonList();
            try {
                //var nm ;
                var obj;
                var sid;
                for (var ind = 0; ind < aPolygons.length; ind++) {
                    //nm ="\u0420\u0435\u0433\u0438\u043E\u043D ?"+ind;
                    obj = aPolygons[ind];
                    var points = [];
                    for (var m = 0; m < obj.latlngarr.length; m++) {
                        var point = [];
                        point.push(obj.latlngarr[m].lat);
                        point.push(obj.latlngarr[m].lng);
                        points.push(point);
                    }
                    yandex_CreatePolygonNew(points, obj.rgbline, obj.rgbfill, obj.name, obj.name, obj.id, 0, obj.parentid, "", obj.level, obj.routenum, obj.sessionid);
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { }
        }

        function ClearPolygonList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearPolygonList");

            for (var i = PolygonList.length - 1; i >= 0; i--) { map.geoObjects.remove(PolygonList[i]); }
            PolygonList = [];
        }

        function ClearMarkerList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearMarkerList");

            for (var i = MarkerList.length - 1; i >= 0; i--) { map.geoObjects.remove(MarkerList[i]); }
            MarkerList = [];
        }

        function ClearRouteList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearRouteList");

            map.geoObjects.remove(route);
            route = null;
        }

        function yandex_PolygonClick(event) {
            //SetValueOf("forDebug", event.get("target"));
            yandex_MapClick(event);
            yandex_PolygonInfo(event.get("target"));
        }

        function yandex_PolygonInfo(polygon) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonInfo");

            var Result = yandex_PolygonAbout(polygon);
            SetValueOf("AreaXML", Result);
        }

        function yandex_PolygonAbout(polygon) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonAbout");

            //polygon.geometry.getCoordinates()
            //polygon.options.get("fillColor");
            //polygon.options.get("strokeColor");
            var ArrPoints = polygon.geometry.getCoordinates()[0];
            var Points = "";
            if (ArrPoints[0] == ArrPoints[ArrPoints.length - 1]) ArrPoints.splice(ArrPoints.length - 1, 1);
            ArrPoints.forEach(function (el) {
                Points += '<LATLNG><LAT>' + el[0] + '</LAT><LNG>' + el[1] + '</LNG></LATLNG>\n';
            });
            var Result =
                '<AREA>' + '\n' +
                '<_MODE>YANDEX</_MODE>\n' +
                '<_INDEX>' + polygon.metaDataProperty._index + '</_INDEX>\n' +
                '<_POINTS>' + ArrPoints.length + '</_POINTS>\n' +
                '<SESSIONID>' + polygon.metaDataProperty.SessionID + '</SESSIONID>\n' +
                '<RECORDSTATE>' + polygon.metaDataProperty.RecordState + '</RECORDSTATE>\n' +
                '<ID>' + polygon.metaDataProperty.ID + '</ID>' + '\n' +
                '<PARENTID>' + polygon.metaDataProperty.ParentID + '</PARENTID>\n' +
                '<NAME>' + polygon.metaDataProperty.Name + '</NAME>\n' +
                '<LEVEL>' + polygon.metaDataProperty.Level + '</LEVEL>\n' +
                '<RGBLINE>' + polygon.options.get("strokeColor").toUpperCase() + '</RGBLINE>\n' +
                '<RGBFILL>' + polygon.options.get("fillColor").toUpperCase() + '</RGBFILL>\n' +
                '<ROUTENUM>' + polygon.metaDataProperty.RouteNum + '</ROUTENUM>\n' +
                Points +
                '</AREA>';
            return Result;
        }

        function SetBoundsForPoints(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetBoundsForPoints" /*+ JSON.stringify(aPoints)*/);

            try {
                if (aPoints.length == 0) { return; }
                var minLat = aPoints[0].lat;
                var maxLat = aPoints[0].lat;
                var minLon = aPoints[0].lng;
                var maxLon = aPoints[0].lng;
                var lat = 0;
                var lng = 0;
                for (var i = 0; i < aPoints.length; i++) {
                    lat = aPoints[i].lat;
                    lng = aPoints[i].lng;
                    if (lat > maxLat) { maxLat = lat };
                    if (lat < minLat) { minLat = lat };
                    if (lng > maxLon) { maxLon = lng };
                    if (lng < minLon) { minLon = lng };
                }
                //var southWest = new YMaps.GeoPoint(minLon, minLat);
                //var nordEast = new YMaps.GeoPoint(maxLon, maxLat);
                //var bound = new YMaps.GeoBounds(southWest, nordEast);
                map.setBounds([[minLat, minLon], [maxLat, maxLon]]);
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message); }
            finally { }
        }

        function yandex_SetCenter(aLat, aLng) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_SetCenter");

            //map.setCenter(new YMaps.GeoPoint(aLng, aLat), map.getZoom());
            map.setCenter([aLat, aLng]);
        };

        function SendToBack(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SendToBack" + aSessionID);

            PolygonList.forEach(function (el) {
                if (el.metaDataProperty.SessionID == aSessionID || el.metaDataProperty.ID == aSessionID)
                    el.options.set("zIndex", el.options.get("zIndex") - 1);
            });
            /*
            var ind = -1;
            var z = 1000000;
            for (var i = 0; i < PolygonList.length; i++) {
                if ((ind == -1) && ((PolygonList[i].metaDataProperty.SessionID == aSessionID) || (PolygonList[i].metaDataProperty.ID + "" == aSessionID))) { ind = i; }
                //if (PolygonList[i].getOptions().zIndex < z) { z = PolygonList[i].getOptions().zIndex; }
                if (PolyginList[i].options.get("zIndex") < z) z = PoligonList[i].options.get("zIndex");
            }
            z = z - 1;
            //if (ind != -1) { PolygonList[ind].setOptions({ zIndex: z }); }
            if (ind != -1) PolygonList[ind].options.set("zIndex", z);*/
        }

        function yandex_PolygonStartEditing(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonStartEditing");

            polygon = PolygonList[aIndex];
            //if ((polygon) && (!polygon.isEditing())) { polygon.startEditing(); };
            if (polygon && !polygon.editor.state.get("editing")) { polygon.editor.startEditing(); }
            polygon.metaDataProperty.RecordState = 1;
            yandex_PolygonInfo(polygon);

        }

        function yandex_PolygonStopEditing(aIndex, aAreaID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonStopEditing");

            polygon = PolygonList[aIndex];
            //if ((polygon) && (polygon.isEditing())) { polygon.stopEditing(); };
            if (polygon && polygon.editor.state.get("editing")) { polygon.editor.stopEditing(); }
            polygon.metaDataProperty.ID = aAreaID;
            polygon.metaDataProperty.RecordState = 0
            yandex_PolygonInfo(polygon);
        }

        function CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "CreateNewArea"
            //    + "~" + lat + "~" + lng + "~" + num + "~" + dist + "~" + clrBord + "~" + clrFill + "~" + Descr + "~" + SessionID);

            if (!CanAreaEdit) { return };
            yandex2_CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID);
        }

        function ChangeProps_BySessionID(aSessionID, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ChangeProps_BySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_ChangeProps_Value(ind, aProp, aValue); }
        }

        function yandex_ChangeProps_Value(aIndex, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_ChangeProps_Value" + "~" + aIndex + "~" + aProp + "~" + aValue);

            var polygon = PolygonList[aIndex];
            switch (aProp) {
                case ipID:
                    polygon.metaDataProperty.ID = aValue;
                    break;
                case ipParentID:
                    polygon.metaDataProperty.ParentID = aValue;
                    break;
                case ipName:
                    polygon.metaDataProperty.Name = aValue;
                    polygon.name = aValue;
                    polygon.description = aValue;
                    polygon.properties.set("hintContent", aValue); // -- done
                    //// -- ?????????? ??? ?????????? Hint-? --
                    //var StyleName = polygon.getOptions().style;
                    //var style = YMaps.Styles.get(StyleName);
                    //polygon.setOptions({ style: StyleName });
                    break;
                case ipLevel:
                    polygon.metaDataProperty.Level = aValue;
                    break;
                case ipLineColor:
                    polygon.metaDataProperty.LineColor = aValue;
                    yandex_ChangeProps_Colors(aIndex, polygon.metaDataProperty.LineColor, polygon.metaDataProperty.FillColor);
                    break;
                case ipFillColor:
                    polygon.metaDataProperty.FillColor = aValue;
                    yandex_ChangeProps_Colors(aIndex, polygon.metaDataProperty.LineColor, polygon.metaDataProperty.FillColor);
                    break;
                case ipRoute:
                    polygon.metaDataProperty.RouteNum = aValue;
                    break;
                case ipSessionID:
                    polygon.metaDataProperty.SessionID = aValue; // -- !! ? ??????? ??????
                    break;
                default:
                    break;
            }
            //polygon.metaDataProperty.RecordState = 1;         // -- kaa ?? ?????? ????? ??? ?????????? ???? ? ??????? ??????
            yandex_PolygonInfo(polygon);
        }

        function yandex_ChangeProps_Colors(aIndex, lineColor, fillColor) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_ChangeProps_Colors");

            var polygon = PolygonList[aIndex];
            polygon.metaDataProperty.LineColor = lineColor;
            polygon.metaDataProperty.FillColor = fillColor;
            polygon.options.set("strokeColor", polygon.metaDataProperty.LineColor/* + "FF"*/);
            polygon.options.set("fillColor", polygon.metaDataProperty.FillColor/* + "40"*/);
            //var StyleName = polygon.getOptions().style;
            //var style = YMaps.Styles.get(StyleName);
            //style.polygonStyle.strokeColor = polygon.metaDataProperty.LineColor + "FF";
            //style.polygonStyle.fillColor = polygon.metaDataProperty.FillColor + "40";
            //polygon.setOptions({ style: StyleName });
        }

        function yandex2_CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex2_CreateNewArea");

            var ind = -1;
            var pts = [];
            var minLat = lat;
            var maxLat = lat;
            var minLon = lng;
            var maxLon = lng;
            var llat = 0;
            var llng = 0;
            //var pts = ""
            for (i = 0; i < num; i++) {
                angle = (360 / num) * i * Math.PI / 180;
                delta = [Math.cos(angle), Math.sin(angle)];
                pt = ymaps.coordSystem.geo.solveDirectProblem([lat, lng], delta, dist).endPoint;
                //pts = pts + pt[0] + "," + pt[1] + ';'
                llat = pt[0];
                llng = pt[1];
                if (llat > maxLat) { maxLat = llat };
                if (llat < minLat) { minLat = llat };
                if (llng > maxLon) { maxLon = llng };
                if (llng < minLon) { minLon = llng };
                pts.push(pt);
            }
            //pts = pts.substring(0, pts.length - 1);
            //ind = yandex_CreatePolygon(pts, clrBord, clrFill, Descr, Descr, "0", "1", "0", Descr, "3", "0", "1111111", SessionID);
            ind = yandex_CreatePolygonNew(pts, clrBord, clrFill, Descr, Descr, "0", "1", "0", Descr, "3", "0", "1111111", SessionID);
            if (ind > -1) {
                var xml = yandex_PolygonAbout(PolygonList[ind]);
                SetValueOf("AreaXML", xml);
                //PolygonList[ind].startEditing();
                map.setBounds([[minLat, minLon], [maxLat, maxLon]]);
                PolygonList[ind].editor.startEditing();
            }
            //event.preventMapEvent();
        }

        function yandex_CreatePolygonNew(aPts, aBorderColor, aFillColor, aShortDescr, aFullDescr, aID, aRecordState, aParentID, aName, aLevel, aRouteNum, aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreatePolygonNew");

            try {
                var res = -1;
                if (aPts.length == 0) return res
                var polygon = new ymaps.Polygon([aPts],
                    { hintContent: aShortDescr },
                    {
                        fill: true,
                        stroke: true,
                        strokeWidth: 1,
                        strokeColor: aBorderColor,
                        fillColor: aFillColor,
                        zIndex: 100,
                        opacity: 0.33
                    });

                var ind = PolygonList.length;
                var md =
                {
                    _index: ind ? ind : 0
                    , ID: aID ? aID : 0
                    , RecordState: aRecordState ? aRecordState : 0
                    , ParentID: aParentID ? aParentID : 0
                    , Name: aName ? aName : aFullDescr
                    , Level: aLevel ? aLevel : 3
                    , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                    , LineColor: aBorderColor ? aBorderColor : "FF0000"
                    , FillColor: aFillColor ? aFillColor : "FFFF00"
                    , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
                };
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;

                if (map && polygon) {
                    map.geoObjects.add(polygon);
                    polygon.events.add("click", yandex_PolygonClick);
                }
                if (polygon) {
                    PolygonList.push(polygon);
                    polygon.metaDataProperty._index = PolygonList.length - 1;
                    res = polygon.metaDataProperty._index;
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { return res; }


            /*  try {
                var res = -1;
                var GeoPoints = [];
                for (var pt = 0; pt < aPts.length; pt++) { GeoPoints.push(new YMaps.GeoPoint(aPts[pt].lng, aPts[pt].lat)); }
                if (GeoPoints.length == 0) { return res; };
                var ind = PolygonList.length;
                var md =
                {
                    _index: ind ? ind : 0
                    , ID: aID ? aID : 0
                    , RecordState: aRecordState ? aRecordState : 0
                    , ParentID: aParentID ? aParentID : 0
                    , Name: aName ? aName : aFullDescr
                    , Level: aLevel ? aLevel : 3
                    , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                    , LineColor: aBorderColor ? aBorderColor : "FF0000"
                    , FillColor: aFillColor ? aFillColor : "FFFF00"
                    , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
                };
                var polygon = new YMaps.Polygon(GeoPoints, { style: yandex_GetPolygonStyle(md.ID, aBorderColor, aFillColor), hasHint: 1, hasBalloon: 0, interactive: YMaps.Interactivity.INTERACTIVE, zIndex: 0 });
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;
                YMaps.Events.observe(polygon, polygon.Events.Click, yandex_PolygonClick);
                YMaps.Events.observe(polygon, polygon.Events.PositionChange, yandex_PolygonInfo);
                if ((map) && (polygon)) { map.addOverlay(polygon) };
                if (polygon) {
                    PolygonList.push(polygon);
                    polygon.metaDataProperty._index = PolygonList.length - 1;
                    res = polygon.metaDataProperty._index;
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { return res; }*/
        }


        /* << ???????????? ??????? */

        //https://msdn.microsoft.com/en-us/library/ms536951%28v=vs.85%29.aspx
        //https://msdn.microsoft.com/en-us/library/aa703876%28v=vs.85%29.aspx

        function yandex_GetGeoPointList(aGMPointArray, GeoPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_GetGeoPointList");

            var points = [];
            var LatLon = [];
            points = aGMPointArray.split(';');
            for (var pt = 0; pt < points.length; pt++) {
                LatLon = points[pt].split(',');
                GeoPoints.push(new YMaps.GeoPoint(LatLon[1], LatLon[0]));
            }
        }

        function yandex_GetPolygonStyle(aID, aBorderColor, aFillColor) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_GetPolygonStyle");

            var StyleName = "polygon#" + aID;
            var style = new YMaps.Style("default#greenSmallPoint");
            style.polygonStyle = new YMaps.PolygonStyle();
            style.polygonStyle.fill = 1;
            style.polygonStyle.outline = 1;
            style.polygonStyle.strokeWidth = 1;
            style.polygonStyle.strokeColor = aBorderColor + "FF";
            style.polygonStyle.fillColor = aFillColor + "40";
            YMaps.Styles.add(StyleName, style);
            return StyleName;
        }

        // ----
        function yandex_CreatePolygon(aPath, aBorderColor, aFillColor, aShortDescr, aFullDescr, aID, aRecordState, aParentID, aName, aLevel, aRouteNum, aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreatePolygon");

            var res = -1;
            var GeoPoints = [];
            var area_DblClick = null;
            var ind = PolygonList.length;
            var id = aID;
            var md = {
                _index: ind ? ind : 0
                , ID: aID ? aID : 0
                , RecordState: aRecordState ? aRecordState : 0
                , ParentID: aParentID ? aParentID : 0
                , Name: aName ? aName : aFullDescr
                , Level: aLevel ? aLevel : 3
                , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                , LineColor: aBorderColor ? aBorderColor : "FF0000"
                , FillColor: aFillColor ? aFillColor : "FFFF00"
                , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
            };
            var interact;
            interact = YMaps.Interactivity.INTERACTIVE;
            yandex_GetGeoPointList(aPath, GeoPoints);
            if (GeoPoints.length != 0) {
                var polygon = new YMaps.Polygon(GeoPoints,
                    { style: yandex_GetPolygonStyle(id, aBorderColor, aFillColor), hasHint: 1, hasBalloon: 0, interactive: interact, zIndex: 0 });
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;

                YMaps.Events.observe(polygon, polygon.Events.Click, yandex_PolygonClick);
                YMaps.Events.observe(polygon, polygon.Events.PositionChange, yandex_PolygonInfo);
                if ((map) && (polygon)) { map.addOverlay(polygon) };
            }
            if (polygon) {
                PolygonList.push(polygon);
                polygon.metaDataProperty._index = PolygonList.length - 1;
                res = polygon.metaDataProperty._index;
            }
            return res;
        }


        // -- ? ??? ?? ????? ??????? ?? ???????? (?.?. ????? ??????? ?????? ?????? ?? ?????????? ?????)
        //function SendToBack(obj){
        //	obj.setOptions({zIndex:-999});
        //}


        function yandex_CreateMarker(aLatitude, aLongitude, aDescription, aCorner) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreateMarker");

            var aCurStyle = GreenMarkerIcon;
            if (aDescription.lastIndexOf(")*") != -1) { aCurStyle = RedMarkerIcon; }
            if (aCorner) { aCurStyle = BlueMarkerIcon; }

            var marker = new YMaps.Placemark(new YMaps.GeoPoint(aLongitude, aLatitude),
                {
                    draggable: 0,
                    hideIcon: false,
                    interactive: YMaps.Interactivity.INTERACTIVE,
                    hintOptions: { maxWidth: 250, showTimeout: 200, offset: new YMaps.Point(5, 5) },
                    balloonOptions: { maxWidth: 250, hasCloseButton: true, mapAutoPan: 1 }
                });
            marker.description = aDescription;
            var MarkerStyle = new YMaps.Style();
            MarkerStyle.iconStyle = new YMaps.IconStyle();
            MarkerStyle.iconStyle.size = new YMaps.Point(10, 10); // -data-
            MarkerStyle.iconStyle.offset = new YMaps.Point(-5, -5);
            MarkerStyle.iconStyle.href = aCurStyle;
            marker.setStyle(MarkerStyle);
            //YMaps.Events.observe(marker, marker.Events.BalloonOpen,SendToBack);
            map.addOverlay(marker);
            MarkerList.push(marker);
        }

        function yandex_RoutePack(aObj, aIndex, aWPArray) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_RoutePack");

            var pt = new YMaps.GeoPoint(aObj.lng, aObj.lat);
            var wp = null;
            for (var i = 0; i < aWPArray.length; i++) {
                if (aWPArray[i].getGeoPoint().toString() == pt.toString()) {
                    aWPArray[i].metaDataProperty.Caption = aWPArray[i].metaDataProperty.Caption + "," + (aIndex + 1);
                    aWPArray[i].description = aWPArray[i].description +/*'<tr><td>'+*/"<div class='fi80red'>\u0422\u043E\u0447\u043A\u0430\u0020\u2116" + (aIndex + 1) + "</div>" + aObj.descr/*+'</td></tr>'*/;
                    return;
                }
            }
            wp = new YMaps.WayPoint(pt);
            wp.metaDataProperty.Caption = "" + (aIndex + 1);
            wp.description = "<div class='fi80red'>\u0422\u043E\u0447\u043A\u0430\u0020\u2116" + (aIndex + 1) + "</div>" + aObj.descr;
            aWPArray.push(wp);
        }

        function yandex_Route(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_Route");

            try {
                if (route) { map.removeOverlay(route); route = null };
                rs = new YMaps.Style();
                rs.lineStyle = new YMaps.LineStyle();
                rs.lineStyle.strokeColor = "000000";
                rs.lineStyle.strokeWidth = 2;
                rs.hideIcon = false;
                YMaps.Styles.add("router#RouteLine", rs);
                var points = []
                var waypoints = []
                var params = [];
                var wp = null;
                for (var i = 0; i < aPoints.length; i++) { yandex_RoutePack(aPoints[i], i, waypoints); }
                for (var i = 0; i < waypoints.length; i++) { points.push(waypoints[i].getGeoPoint()) }
                route = new YMaps.Router(points, [], { viewAutoApply: true });
                route.setStyle(rs);
                route.metaDataProperty.Source = aPoints;
                route.metaDataProperty.WayPoints = waypoints;
                YMaps.Events.observe(route, route.Events.Load, function () {
                    for (var pt = 0; pt < points.length; pt++) {
                        wp = route.getWayPoint(pt);
                        wp.setStyle("default#nightSmallPoint");
                        wp.setIconContent(waypoints[pt].metaDataProperty.Caption);
                        wp.setOptions({ hideIcon: false });
                        //var descr='<table>'+waypoints[pt].description+'</table>';
                        wp.setBalloonContent(waypoints[pt].description);
                        wp.setBalloonOptions({ maxWidth: 200, hasCloseButton: true, mapAutoPan: 1 });
                    }
                });
                map.addOverlay(route);
            } catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message); }
        }




        function yandex_DeleteArea(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_DeleteArea");

            var polygon = PolygonList[aIndex];
            var del = PolygonList.splice(aIndex, 1);
            for (var i = 0; i < del.length; i++) {
                del[i].metaDataProperty.ID = Math.abs(del[i].metaDataProperty.ID) * -1;
                DeletedPolygonList.push(del[i]);
            };
            map.removeOverlay(polygon);
            var Result = yandex_PolygonAbout(DeletedPolygonList[DeletedPolygonList.length - 1]);
            SetValueOf("AreaXML", Result);
        }

        // ----------------------------------------------------------------------------------


        function SetArrayOfPolygon(aPolygons) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfPolygon");

            ClearPolygonList();
            var StrPolygons = aPolygons.split(AreaDelimiter);
            var Params = []
            var ind = 0;
            var nm = "";
            var desc = "";
            for (var i = 0; i < StrPolygons.length; i++) {
                Params = StrPolygons[i].split(GroupDelimiter);
                ind = i + 1;
                nm = "\u0420\u0435\u0433\u0438\u043E\u043D ?" + ind;
                if (Params[3]) nm = Params[3];
                desc = nm;
                if (Params[4]) desc = Params[4];
                yandex_CreatePolygon(Params[0], Params[1].substring(1, 10), Params[2].substring(1, 10), nm, desc, Params[5], Params[6], Params[7], Params[8], Params[9], Params[10], Params[11]);
            }
        }

        function SetArrayOfMarker(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfMarker");

            ClearMarkerList();
            for (var i = 0; i < aPoints.length; i++) {
                yandex_CreateMarker(aPoints[i].lat, aPoints[i].lng, aPoints[i].descr);
            }
            SetBoundsForPoints(aPoints);
        }

        function CreateRoute(aMarkers) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "CreateRoute");

            yandex_Route(aMarkers);
            SetBoundsForPoints(aMarkers);
        }

        function ChangeProps_Value(aIndex, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ChangeProps_Value");

            yandex_ChangeProps_Value(aIndex, aProp, aValue)
        }


        function DeleteAreaByIndex(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "DeleteAreaByIndex");

            yandex_DeleteArea(aIndex)
        }

        function DeleteAreaBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "DeleteAreaBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { DeleteAreaByIndex(ind); }
        }

        function EditAreaBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "EditAreaBySessionID" + "~" + aSessionID);

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_PolygonStartEditing(ind); }
        }

        function SaveAreaBySessionID(aSessionID, AreaID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SaveAreaBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_PolygonStopEditing(ind, AreaID); }
        }

        function PolygonAboutBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "PolygonAboutBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    yandex_PolygonAbout(PolygonList[i]);
                    return;
                }
            }
        }


        // --- common utils functions ---------------------------------------------------------------------
        function GetObjectProps(aObj, Level) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "GetObjectProps");

            var Result = ""; for (var key in aObj) { Result = Result + key + ":" + aObj[key] + '\n' } return Result;
        }
        function SetValueOf(aName, aValue) {
            if (typeof this[aName] != "undefined") { this[aName].value = aValue; if (this[aName].id != "forDebug") SendMessage(aName); } else { }
        }
        function SendMessage(aText) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SendMessage" + aText);

            try { window.navigate("#" + aText); } catch (e) { var url = "#" + aText; location.href = url; }/*finally{alert(aText);}*/
        }
        function getFnName(fn) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "getFnName");

            return fn.toString().match(/function ([^(]*)\(/)[1];
        } //http://javascript.ru/forum/misc/4895-uznat-imya-funkcii.html
        // ------------------------------------------------------------------------
    </script>
</head>
<body onload="yandex_initialize()">
    <div id="map" style="width:100%; height:100%"></div>
    <input type="hidden" id="AreaXML" value="">
    <input type="hidden" id="ClickCoord" value="">
    <input type="hidden" id="forDebug" value="" style="width: 98%;" />
</body>
</html> ??  <   ??
 H T M L _ W R I T E _ N E W         0           <!DOCTYPE HTML>
<html xmlns:vml="urn:schemas-microsoft-com:vml">
<meta content="text/html; charset=windows-1251">
<meta name="viewport" content="initial-scale=1.0, user-scalable=no, maximum-scale=1" />
<!-- 20151223 -->
<!-- 20181026 -->
<head>
    <style type="text/css">
        .fi80 {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: italic
        }

        .fi80red {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #FF0000;
            font-style: italic
        }

        .fn80 {
            font-size: 80%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: normal
        }

        .fi60 {
            font-size: 60%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: italic
        }

        .fn70 {
            font-size: 70%;
            font-family: Verdana, Arial, Helvetica, sans-serif;
            color: #333366;
            font-style: normal
        }
    </style>
    <style>
        html, body, #map {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
    </style>
    <!--source file is Yandex_20181207.html, key for [developer.vulgaris@yandex.ru] created at 07.12.2018 -->
    <script src="https://api-maps.yandex.ru/1.1/index.xml?key=AF9nClwBAAAA7wIWegIAi8ta87V2ij9qjk9J-4U1ZfQx2roAAAAAAAAAAACcKppvtncPlbTULMdLtMRqAdTlOg==&modules=traffic~pmap~router-editor" type="text/javascript"></script>
    <!-- ?? ???????!!! ??? ?????????? ??? ??????? ????? ??? ???????? ???? -->
    <!--<script src="http://api-maps.yandex.ru/2.0/?load=package.standard&lang=ru-RU" type="text/javascript"></script>-->
    <script src="https://api-maps.yandex.ru/2.1.78/?lang=ru_RU" type="text/javascript"></script>
    <script src="data.js" type="text/javascript"></script>
    <script type="text/javascript">

        //FieldsDelimiter  = '?';
        //RecordsDelimiter = '?';
        GroupDelimiter = '?';
        //ItemDelimiter = '?';
        AreaDelimiter = '&';
        //crlf = '\n';
        MapMode = 0; //  : 0- yandex
        CanAreaEdit = 1;
        var gpMoscowCenter = { lat: 55.755833, lng: 37.617778 };
        var gpSPBCenter = { lat: 59.95, lng: 30.316667 };
        var gpRNDCenter = { lat: 47.23132, lng: 39.72326 };
        var map = null;
        var PolygonList = [];
        var DeletedPolygonList = [];
        var MarkerList = [];
        var route = null;
        var InfoWindow = null;
        var placemark = null;
        var GreenMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAABgALAAAAAAKAAoAhwD3AAiUCAicCAitCAjWCBj/GCGcISG9ISHWISnvKTk5OUqcSkr/SlpaWlreWnNzc3t7e4yMjJTWlJycnKWlxq2tra3Orb3evcb//9bn1v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUADFgsGAggEELAjEYcCABwYCHAgYu0JBBAoGLBA4EOCDhggMCAAAUQBBgAAIEIUUySFDyokoGK1u+hJnAwgACBWDqPKAQQQKdDBAkNOAzAQKeGAICADs=";
        var YellowMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAAA4ALAAAAAAKAAoAhzk5OVpaWnNzc3t7e4yMjJSECJyMCJyMIZyUSpycnKWlxq2cCK2trb2lIcb//87Orda1CNa9IdbOlN7OWt7evefn1u/WKffWAP/nGP/vSv///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUAB04eHCggMEHAh0cmCAhwoKHBgYi0FBBAoSLEBoUaCCBwgQIFy5giFBgQYQIIUVmsFDyosoMK1u+hGnhwQIIGGDqbKAwggWdGSIkPODTQgSeDgICADs=";
        var RedMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAANEALAAAAAAKAAoAhwAAAAAAMwAAZgAAmQAAzAAA/wArAAArMwArZgArmQArzAAr/wBVAABVMwBVZgBVmQBVzABV/wCAAACAMwCAZgCAmQCAzACA/wCqAACqMwCqZgCqmQCqzACq/wDVAADVMwDVZgDVmQDVzADV/wD/AAD/MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMrADMrMzMrZjMrmTMrzDMr/zNVADNVMzNVZjNVmTNVzDNV/zOAADOAMzOAZjOAmTOAzDOA/zOqADOqMzOqZjOqmTOqzDOq/zPVADPVMzPVZjPVmTPVzDPV/zP/ADP/MzP/ZjP/mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YrAGYrM2YrZmYrmWYrzGYr/2ZVAGZVM2ZVZmZVmWZVzGZV/2aAAGaAM2aAZmaAmWaAzGaA/2aqAGaqM2aqZmaqmWaqzGaq/2bVAGbVM2bVZmbVmWbVzGbV/2b/AGb/M2b/Zmb/mWb/zGb//5kAAJkAM5kAZpkAmZkAzJkA/5krAJkrM5krZpkrmZkrzJkr/5lVAJlVM5lVZplVmZlVzJlV/5mAAJmAM5mAZpmAmZmAzJmA/5mqAJmqM5mqZpmqmZmqzJmq/5nVAJnVM5nVZpnVmZnVzJnV/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwAM8wAZswAmcwAzMwA/8wrAMwrM8wrZswrmcwrzMwr/8xVAMxVM8xVZsxVmcxVzMxV/8yAAMyAM8yAZsyAmcyAzMyA/8yqAMyqM8yqZsyqmcyqzMyq/8zVAMzVM8zVZszVmczVzMzV/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8Amf8AzP8A//8rAP8rM/8rZv8rmf8rzP8r//9VAP9VM/9VZv9Vmf9VzP9V//+AAP+AM/+AZv+Amf+AzP+A//+qAP+qM/+qZv+qmf+qzP+q///VAP/VM//VZv/Vmf/VzP/V////AP//M///Zv//mf//zP///wAAAAAAAAAAAAAAAAhWAKNFG/bHj8FhAqP9ATds2h9UBQca2jdvWCpUF1P5STVsmLZU00JqxAgylbRp2qb5+XMxpDZw2rJtROVSm81pwzZOg2nzY7RCIHv6FPjn1bRsqV4JDAgAOw==";
        var BlueMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAABgALAAAAAAKAAoAhwAA9wgIlAgInAgIrQgI1hgY/yEhnCEhvSEh1ikp7zk5OUpKnEpK/1paWlpa3nNzc3t7e4yMjJSU1pycnKWlxq2tra2tzr293sb//9bW5////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////whUADFgsGAggEELAjEYcCABwYCHAgYu0JBBAoGLBA4EOCDhggMCAAAUQBBgAAIEIUUySFDyokoGK1u+hJnAwgACBWDqPKAQQQKdDBAkNOAzAQKeGAICADs="
        var VioletMarkerIcon = "data:image/gif;base64,R0lGODlhCgAKAHcAACH5BAUAAAAALAAAAAAKAAoAhwAAAJkAAMwAAP8AAJkAmcwAmf8AmZkAzP8AzMwrzP+AzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhNAAEASEAggMEEAgEQQJDAAAEBBQceWKAgQQEBFwsEKJAgAYICBkJqxAiywAADCAwEIHAxJIKXKluifJkywcaZNAsoBEnzY0KWInUCCAgAOw==";
        ipID = 0;
        ipParentID = 1;
        ipName = 2;
        ipLevel = 3;
        ipLineColor = 4;
        ipFillColor = 5;
        ipRoute = 6;
        ipSessionID = 7;
        comZOrder = 0;
        var searchControl = null;

        /* >> ???????????? ??????? */
        function yandex_initialize() {
            ymaps.ready(function () {
                map = new ymaps.Map("map",
                    {
                        center: [gpMoscowCenter.lat, gpMoscowCenter.lng]
                        , zoom: 10
                        , behaviors: ["drag", "scrollZoom"]
                        , controls: []
                    },
                    {
                        autoFitToViewport: "none"//"always"
                        , minZoom: 3
                        , maxZoom: 19
                        , suppressMapOpenBlock: true
                    }
                );
                map.controls.add("typeSelector", { position: { right: 5, top: 5 } });
                map.controls.add("zoomControl", { position: { left: 5, top: 40 } });
                map.events.add(["click"], yandex_MapClick);
            })
        }

        function yandex_MapClick(event) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_MapClick");

            var coords = event.get('coords');
            var str = coords[0] + "," + coords[1];
            SetValueOf("ClickCoord", str);
        }

        function SetArrayOfPolygonNew(aPolygons) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfPolygonNew"/* + '{' + JSON.stringify(aPolygons) + '}'*/);

            ClearPolygonList();
            try {
                //var nm ;
                var obj;
                var sid;
                for (var ind = 0; ind < aPolygons.length; ind++) {
                    //nm ="\u0420\u0435\u0433\u0438\u043E\u043D ?"+ind;
                    obj = aPolygons[ind];
                    var points = [];
                    for (var m = 0; m < obj.latlngarr.length; m++) {
                        var point = [];
                        point.push(obj.latlngarr[m].lat);
                        point.push(obj.latlngarr[m].lng);
                        points.push(point);
                    }
                    yandex_CreatePolygonNew(points, obj.rgbline, obj.rgbfill, obj.name, obj.name, obj.id, 0, obj.parentid, "", obj.level, obj.routenum, obj.sessionid);
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { }
        }

        function ClearPolygonList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearPolygonList");

            for (var i = PolygonList.length - 1; i >= 0; i--) { map.geoObjects.remove(PolygonList[i]); }
            PolygonList = [];
        }

        function ClearMarkerList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearMarkerList");

            for (var i = MarkerList.length - 1; i >= 0; i--) { map.geoObjects.remove(MarkerList[i]); }
            MarkerList = [];
        }

        function ClearRouteList() {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ClearRouteList");

            map.geoObjects.remove(route);
            route = null;
        }

        function yandex_PolygonClick(event) {
            //SetValueOf("forDebug", event.get("target"));
            yandex_MapClick(event);
            yandex_PolygonInfo(event.get("target"));
        }

        function yandex_PolygonInfo(polygon) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonInfo");

            var Result = yandex_PolygonAbout(polygon);
            SetValueOf("AreaXML", Result);
        }

        function yandex_PolygonAbout(polygon) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonAbout");

            //polygon.geometry.getCoordinates()
            //polygon.options.get("fillColor");
            //polygon.options.get("strokeColor");
            var ArrPoints = polygon.geometry.getCoordinates()[0];
            var Points = "";
            if (ArrPoints[0] == ArrPoints[ArrPoints.length - 1]) ArrPoints.splice(ArrPoints.length - 1, 1);
            ArrPoints.forEach(function (el) {
                Points += '<LATLNG><LAT>' + el[0] + '</LAT><LNG>' + el[1] + '</LNG></LATLNG>\n';
            });
            var Result =
                '<AREA>' + '\n' +
                '<_MODE>YANDEX</_MODE>\n' +
                '<_INDEX>' + polygon.metaDataProperty._index + '</_INDEX>\n' +
                '<_POINTS>' + ArrPoints.length + '</_POINTS>\n' +
                '<SESSIONID>' + polygon.metaDataProperty.SessionID + '</SESSIONID>\n' +
                '<RECORDSTATE>' + polygon.metaDataProperty.RecordState + '</RECORDSTATE>\n' +
                '<ID>' + polygon.metaDataProperty.ID + '</ID>' + '\n' +
                '<PARENTID>' + polygon.metaDataProperty.ParentID + '</PARENTID>\n' +
                '<NAME>' + polygon.metaDataProperty.Name + '</NAME>\n' +
                '<LEVEL>' + polygon.metaDataProperty.Level + '</LEVEL>\n' +
                '<RGBLINE>' + polygon.options.get("strokeColor").toUpperCase() + '</RGBLINE>\n' +
                '<RGBFILL>' + polygon.options.get("fillColor").toUpperCase() + '</RGBFILL>\n' +
                '<ROUTENUM>' + polygon.metaDataProperty.RouteNum + '</ROUTENUM>\n' +
                Points +
                '</AREA>';
            return Result;
        }

        function SetBoundsForPoints(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetBoundsForPoints" /*+ JSON.stringify(aPoints)*/);

            try {
                if (aPoints.length == 0) { return; }
                var minLat = aPoints[0].lat;
                var maxLat = aPoints[0].lat;
                var minLon = aPoints[0].lng;
                var maxLon = aPoints[0].lng;
                var lat = 0;
                var lng = 0;
                for (var i = 0; i < aPoints.length; i++) {
                    lat = aPoints[i].lat;
                    lng = aPoints[i].lng;
                    if (lat > maxLat) { maxLat = lat };
                    if (lat < minLat) { minLat = lat };
                    if (lng > maxLon) { maxLon = lng };
                    if (lng < minLon) { minLon = lng };
                }
                //var southWest = new YMaps.GeoPoint(minLon, minLat);
                //var nordEast = new YMaps.GeoPoint(maxLon, maxLat);
                //var bound = new YMaps.GeoBounds(southWest, nordEast);
                map.setBounds([[minLat, minLon], [maxLat, maxLon]]);
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message); }
            finally { }
        }

        function yandex_SetCenter(aLat, aLng) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_SetCenter");

            //map.setCenter(new YMaps.GeoPoint(aLng, aLat), map.getZoom());
            map.setCenter([aLat, aLng]);
        };

        function SendToBack(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SendToBack" + aSessionID);

            PolygonList.forEach(function (el) {
                if (el.metaDataProperty.SessionID == aSessionID || el.metaDataProperty.ID == aSessionID)
                    el.options.set("zIndex", el.options.get("zIndex") - 1);
            });
            /*
            var ind = -1;
            var z = 1000000;
            for (var i = 0; i < PolygonList.length; i++) {
                if ((ind == -1) && ((PolygonList[i].metaDataProperty.SessionID == aSessionID) || (PolygonList[i].metaDataProperty.ID + "" == aSessionID))) { ind = i; }
                //if (PolygonList[i].getOptions().zIndex < z) { z = PolygonList[i].getOptions().zIndex; }
                if (PolyginList[i].options.get("zIndex") < z) z = PoligonList[i].options.get("zIndex");
            }
            z = z - 1;
            //if (ind != -1) { PolygonList[ind].setOptions({ zIndex: z }); }
            if (ind != -1) PolygonList[ind].options.set("zIndex", z);*/
        }

        function yandex_PolygonStartEditing(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonStartEditing");

            polygon = PolygonList[aIndex];
            //if ((polygon) && (!polygon.isEditing())) { polygon.startEditing(); };
            if (polygon && !polygon.editor.state.get("editing")) { polygon.editor.startEditing(); }
            polygon.metaDataProperty.RecordState = 1;
            yandex_PolygonInfo(polygon);

        }

        function yandex_PolygonStopEditing(aIndex, aAreaID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_PolygonStopEditing");

            polygon = PolygonList[aIndex];
            //if ((polygon) && (polygon.isEditing())) { polygon.stopEditing(); };
            if (polygon && polygon.editor.state.get("editing")) { polygon.editor.stopEditing(); }
            polygon.metaDataProperty.ID = aAreaID;
            polygon.metaDataProperty.RecordState = 0
            yandex_PolygonInfo(polygon);
        }

        function CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "CreateNewArea"
            //    + "~" + lat + "~" + lng + "~" + num + "~" + dist + "~" + clrBord + "~" + clrFill + "~" + Descr + "~" + SessionID);

            if (!CanAreaEdit) { return };
            yandex2_CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID);
        }

        function ChangeProps_BySessionID(aSessionID, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ChangeProps_BySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_ChangeProps_Value(ind, aProp, aValue); }
        }

        function yandex_ChangeProps_Value(aIndex, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_ChangeProps_Value" + "~" + aIndex + "~" + aProp + "~" + aValue);

            var polygon = PolygonList[aIndex];
            switch (aProp) {
                case ipID:
                    polygon.metaDataProperty.ID = aValue;
                    break;
                case ipParentID:
                    polygon.metaDataProperty.ParentID = aValue;
                    break;
                case ipName:
                    polygon.metaDataProperty.Name = aValue;
                    polygon.name = aValue;
                    polygon.description = aValue;
                    polygon.properties.set("hintContent", aValue); // -- done
                    //// -- ?????????? ??? ?????????? Hint-? --
                    //var StyleName = polygon.getOptions().style;
                    //var style = YMaps.Styles.get(StyleName);
                    //polygon.setOptions({ style: StyleName });
                    break;
                case ipLevel:
                    polygon.metaDataProperty.Level = aValue;
                    break;
                case ipLineColor:
                    polygon.metaDataProperty.LineColor = aValue;
                    yandex_ChangeProps_Colors(aIndex, polygon.metaDataProperty.LineColor, polygon.metaDataProperty.FillColor);
                    break;
                case ipFillColor:
                    polygon.metaDataProperty.FillColor = aValue;
                    yandex_ChangeProps_Colors(aIndex, polygon.metaDataProperty.LineColor, polygon.metaDataProperty.FillColor);
                    break;
                case ipRoute:
                    polygon.metaDataProperty.RouteNum = aValue;
                    break;
                case ipSessionID:
                    polygon.metaDataProperty.SessionID = aValue; // -- !! ? ??????? ??????
                    break;
                default:
                    break;
            }
            //polygon.metaDataProperty.RecordState = 1;         // -- kaa ?? ?????? ????? ??? ?????????? ???? ? ??????? ??????
            yandex_PolygonInfo(polygon);
        }

        function yandex_ChangeProps_Colors(aIndex, lineColor, fillColor) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_ChangeProps_Colors");

            var polygon = PolygonList[aIndex];
            polygon.metaDataProperty.LineColor = lineColor;
            polygon.metaDataProperty.FillColor = fillColor;
            polygon.options.set("strokeColor", polygon.metaDataProperty.LineColor/* + "FF"*/);
            polygon.options.set("fillColor", polygon.metaDataProperty.FillColor/* + "40"*/);
            //var StyleName = polygon.getOptions().style;
            //var style = YMaps.Styles.get(StyleName);
            //style.polygonStyle.strokeColor = polygon.metaDataProperty.LineColor + "FF";
            //style.polygonStyle.fillColor = polygon.metaDataProperty.FillColor + "40";
            //polygon.setOptions({ style: StyleName });
        }

        function yandex2_CreateNewArea(lat, lng, num, dist, clrBord, clrFill, Descr, SessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex2_CreateNewArea");

            var ind = -1;
            var pts = [];
            var minLat = lat;
            var maxLat = lat;
            var minLon = lng;
            var maxLon = lng;
            var llat = 0;
            var llng = 0;
            //var pts = ""
            for (i = 0; i < num; i++) {
                angle = (360 / num) * i * Math.PI / 180;
                delta = [Math.cos(angle), Math.sin(angle)];
                pt = ymaps.coordSystem.geo.solveDirectProblem([lat, lng], delta, dist).endPoint;
                //pts = pts + pt[0] + "," + pt[1] + ';'
                llat = pt[0];
                llng = pt[1];
                if (llat > maxLat) { maxLat = llat };
                if (llat < minLat) { minLat = llat };
                if (llng > maxLon) { maxLon = llng };
                if (llng < minLon) { minLon = llng };
                pts.push(pt);
            }
            //pts = pts.substring(0, pts.length - 1);
            //ind = yandex_CreatePolygon(pts, clrBord, clrFill, Descr, Descr, "0", "1", "0", Descr, "3", "0", "1111111", SessionID);
            ind = yandex_CreatePolygonNew(pts, clrBord, clrFill, Descr, Descr, "0", "1", "0", Descr, "3", "0", "1111111", SessionID);
            if (ind > -1) {
                var xml = yandex_PolygonAbout(PolygonList[ind]);
                SetValueOf("AreaXML", xml);
                //PolygonList[ind].startEditing();
                map.setBounds([[minLat, minLon], [maxLat, maxLon]]);
                PolygonList[ind].editor.startEditing();
            }
            //event.preventMapEvent();
        }

        function yandex_CreatePolygonNew(aPts, aBorderColor, aFillColor, aShortDescr, aFullDescr, aID, aRecordState, aParentID, aName, aLevel, aRouteNum, aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreatePolygonNew");

            try {
                var res = -1;
                if (aPts.length == 0) return res
                var polygon = new ymaps.Polygon([aPts],
                    { hintContent: aShortDescr },
                    {
                        fill: true,
                        stroke: true,
                        strokeWidth: 1,
                        strokeColor: aBorderColor,
                        fillColor: aFillColor,
                        zIndex: 100,
                        opacity: 0.33
                    });

                var ind = PolygonList.length;
                var md =
                {
                    _index: ind ? ind : 0
                    , ID: aID ? aID : 0
                    , RecordState: aRecordState ? aRecordState : 0
                    , ParentID: aParentID ? aParentID : 0
                    , Name: aName ? aName : aFullDescr
                    , Level: aLevel ? aLevel : 3
                    , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                    , LineColor: aBorderColor ? aBorderColor : "FF0000"
                    , FillColor: aFillColor ? aFillColor : "FFFF00"
                    , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
                };
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;

                if (map && polygon) {
                    map.geoObjects.add(polygon);
                    polygon.events.add("click", yandex_PolygonClick);
                }
                if (polygon) {
                    PolygonList.push(polygon);
                    polygon.metaDataProperty._index = PolygonList.length - 1;
                    res = polygon.metaDataProperty._index;
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { return res; }


            /*  try {
                var res = -1;
                var GeoPoints = [];
                for (var pt = 0; pt < aPts.length; pt++) { GeoPoints.push(new YMaps.GeoPoint(aPts[pt].lng, aPts[pt].lat)); }
                if (GeoPoints.length == 0) { return res; };
                var ind = PolygonList.length;
                var md =
                {
                    _index: ind ? ind : 0
                    , ID: aID ? aID : 0
                    , RecordState: aRecordState ? aRecordState : 0
                    , ParentID: aParentID ? aParentID : 0
                    , Name: aName ? aName : aFullDescr
                    , Level: aLevel ? aLevel : 3
                    , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                    , LineColor: aBorderColor ? aBorderColor : "FF0000"
                    , FillColor: aFillColor ? aFillColor : "FFFF00"
                    , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
                };
                var polygon = new YMaps.Polygon(GeoPoints, { style: yandex_GetPolygonStyle(md.ID, aBorderColor, aFillColor), hasHint: 1, hasBalloon: 0, interactive: YMaps.Interactivity.INTERACTIVE, zIndex: 0 });
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;
                YMaps.Events.observe(polygon, polygon.Events.Click, yandex_PolygonClick);
                YMaps.Events.observe(polygon, polygon.Events.PositionChange, yandex_PolygonInfo);
                if ((map) && (polygon)) { map.addOverlay(polygon) };
                if (polygon) {
                    PolygonList.push(polygon);
                    polygon.metaDataProperty._index = PolygonList.length - 1;
                    res = polygon.metaDataProperty._index;
                }
            }
            catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message) }
            finally { return res; }*/
        }


        /* << ???????????? ??????? */

        //https://msdn.microsoft.com/en-us/library/ms536951%28v=vs.85%29.aspx
        //https://msdn.microsoft.com/en-us/library/aa703876%28v=vs.85%29.aspx

        function yandex_GetGeoPointList(aGMPointArray, GeoPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_GetGeoPointList");

            var points = [];
            var LatLon = [];
            points = aGMPointArray.split(';');
            for (var pt = 0; pt < points.length; pt++) {
                LatLon = points[pt].split(',');
                GeoPoints.push(new YMaps.GeoPoint(LatLon[1], LatLon[0]));
            }
        }

        function yandex_GetPolygonStyle(aID, aBorderColor, aFillColor) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_GetPolygonStyle");

            var StyleName = "polygon#" + aID;
            var style = new YMaps.Style("default#greenSmallPoint");
            style.polygonStyle = new YMaps.PolygonStyle();
            style.polygonStyle.fill = 1;
            style.polygonStyle.outline = 1;
            style.polygonStyle.strokeWidth = 1;
            style.polygonStyle.strokeColor = aBorderColor + "FF";
            style.polygonStyle.fillColor = aFillColor + "40";
            YMaps.Styles.add(StyleName, style);
            return StyleName;
        }

        // ----
        function yandex_CreatePolygon(aPath, aBorderColor, aFillColor, aShortDescr, aFullDescr, aID, aRecordState, aParentID, aName, aLevel, aRouteNum, aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreatePolygon");

            var res = -1;
            var GeoPoints = [];
            var area_DblClick = null;
            var ind = PolygonList.length;
            var id = aID;
            var md = {
                _index: ind ? ind : 0
                , ID: aID ? aID : 0
                , RecordState: aRecordState ? aRecordState : 0
                , ParentID: aParentID ? aParentID : 0
                , Name: aName ? aName : aFullDescr
                , Level: aLevel ? aLevel : 3
                , RouteNum: aRouteNum ? aRouteNum : aID ? aID : 0
                , LineColor: aBorderColor ? aBorderColor : "FF0000"
                , FillColor: aFillColor ? aFillColor : "FFFF00"
                , SessionID: aSessionID ? aSessionID : "index_" + PolygonList.length
            };
            var interact;
            interact = YMaps.Interactivity.INTERACTIVE;
            yandex_GetGeoPointList(aPath, GeoPoints);
            if (GeoPoints.length != 0) {
                var polygon = new YMaps.Polygon(GeoPoints,
                    { style: yandex_GetPolygonStyle(id, aBorderColor, aFillColor), hasHint: 1, hasBalloon: 0, interactive: interact, zIndex: 0 });
                polygon.id = md.ID;
                polygon.name = aShortDescr;
                polygon.description = aFullDescr;
                polygon.metaDataProperty = md;

                YMaps.Events.observe(polygon, polygon.Events.Click, yandex_PolygonClick);
                YMaps.Events.observe(polygon, polygon.Events.PositionChange, yandex_PolygonInfo);
                if ((map) && (polygon)) { map.addOverlay(polygon) };
            }
            if (polygon) {
                PolygonList.push(polygon);
                polygon.metaDataProperty._index = PolygonList.length - 1;
                res = polygon.metaDataProperty._index;
            }
            return res;
        }


        // -- ? ??? ?? ????? ??????? ?? ???????? (?.?. ????? ??????? ?????? ?????? ?? ?????????? ?????)
        //function SendToBack(obj){
        //	obj.setOptions({zIndex:-999});
        //}


        function yandex_CreateMarker(aLatitude, aLongitude, aDescription, aCorner) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_CreateMarker");

            var aCurStyle = GreenMarkerIcon;
            if (aDescription.lastIndexOf(")*") != -1) { aCurStyle = RedMarkerIcon; }
            if (aCorner) { aCurStyle = BlueMarkerIcon; }

            var marker = new YMaps.Placemark(new YMaps.GeoPoint(aLongitude, aLatitude),
                {
                    draggable: 0,
                    hideIcon: false,
                    interactive: YMaps.Interactivity.INTERACTIVE,
                    hintOptions: { maxWidth: 250, showTimeout: 200, offset: new YMaps.Point(5, 5) },
                    balloonOptions: { maxWidth: 250, hasCloseButton: true, mapAutoPan: 1 }
                });
            marker.description = aDescription;
            var MarkerStyle = new YMaps.Style();
            MarkerStyle.iconStyle = new YMaps.IconStyle();
            MarkerStyle.iconStyle.size = new YMaps.Point(10, 10); // -data-
            MarkerStyle.iconStyle.offset = new YMaps.Point(-5, -5);
            MarkerStyle.iconStyle.href = aCurStyle;
            marker.setStyle(MarkerStyle);
            //YMaps.Events.observe(marker, marker.Events.BalloonOpen,SendToBack);
            map.addOverlay(marker);
            MarkerList.push(marker);
        }

        function yandex_RoutePack(aObj, aIndex, aWPArray) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_RoutePack");

            var pt = new YMaps.GeoPoint(aObj.lng, aObj.lat);
            var wp = null;
            for (var i = 0; i < aWPArray.length; i++) {
                if (aWPArray[i].getGeoPoint().toString() == pt.toString()) {
                    aWPArray[i].metaDataProperty.Caption = aWPArray[i].metaDataProperty.Caption + "," + (aIndex + 1);
                    aWPArray[i].description = aWPArray[i].description +/*'<tr><td>'+*/"<div class='fi80red'>\u0422\u043E\u0447\u043A\u0430\u0020\u2116" + (aIndex + 1) + "</div>" + aObj.descr/*+'</td></tr>'*/;
                    return;
                }
            }
            wp = new YMaps.WayPoint(pt);
            wp.metaDataProperty.Caption = "" + (aIndex + 1);
            wp.description = "<div class='fi80red'>\u0422\u043E\u0447\u043A\u0430\u0020\u2116" + (aIndex + 1) + "</div>" + aObj.descr;
            aWPArray.push(wp);
        }

        function yandex_Route(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_Route");

            try {
                if (route) { map.removeOverlay(route); route = null };
                rs = new YMaps.Style();
                rs.lineStyle = new YMaps.LineStyle();
                rs.lineStyle.strokeColor = "000000";
                rs.lineStyle.strokeWidth = 2;
                rs.hideIcon = false;
                YMaps.Styles.add("router#RouteLine", rs);
                var points = []
                var waypoints = []
                var params = [];
                var wp = null;
                for (var i = 0; i < aPoints.length; i++) { yandex_RoutePack(aPoints[i], i, waypoints); }
                for (var i = 0; i < waypoints.length; i++) { points.push(waypoints[i].getGeoPoint()) }
                route = new YMaps.Router(points, [], { viewAutoApply: true });
                route.setStyle(rs);
                route.metaDataProperty.Source = aPoints;
                route.metaDataProperty.WayPoints = waypoints;
                YMaps.Events.observe(route, route.Events.Load, function () {
                    for (var pt = 0; pt < points.length; pt++) {
                        wp = route.getWayPoint(pt);
                        wp.setStyle("default#nightSmallPoint");
                        wp.setIconContent(waypoints[pt].metaDataProperty.Caption);
                        wp.setOptions({ hideIcon: false });
                        //var descr='<table>'+waypoints[pt].description+'</table>';
                        wp.setBalloonContent(waypoints[pt].description);
                        wp.setBalloonOptions({ maxWidth: 200, hasCloseButton: true, mapAutoPan: 1 });
                    }
                });
                map.addOverlay(route);
            } catch (e) { SendMessage('ERROR|' + getFnName(arguments.callee) + ': ' + e.message); }
        }




        function yandex_DeleteArea(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "yandex_DeleteArea");

            var polygon = PolygonList[aIndex];
            var del = PolygonList.splice(aIndex, 1);
            for (var i = 0; i < del.length; i++) {
                del[i].metaDataProperty.ID = Math.abs(del[i].metaDataProperty.ID) * -1;
                DeletedPolygonList.push(del[i]);
            };
            map.removeOverlay(polygon);
            var Result = yandex_PolygonAbout(DeletedPolygonList[DeletedPolygonList.length - 1]);
            SetValueOf("AreaXML", Result);
        }

        // ----------------------------------------------------------------------------------


        function SetArrayOfPolygon(aPolygons) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfPolygon");

            ClearPolygonList();
            var StrPolygons = aPolygons.split(AreaDelimiter);
            var Params = []
            var ind = 0;
            var nm = "";
            var desc = "";
            for (var i = 0; i < StrPolygons.length; i++) {
                Params = StrPolygons[i].split(GroupDelimiter);
                ind = i + 1;
                nm = "\u0420\u0435\u0433\u0438\u043E\u043D ?" + ind;
                if (Params[3]) nm = Params[3];
                desc = nm;
                if (Params[4]) desc = Params[4];
                yandex_CreatePolygon(Params[0], Params[1].substring(1, 10), Params[2].substring(1, 10), nm, desc, Params[5], Params[6], Params[7], Params[8], Params[9], Params[10], Params[11]);
            }
        }

        function SetArrayOfMarker(aPoints) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SetArrayOfMarker");

            ClearMarkerList();
            for (var i = 0; i < aPoints.length; i++) {
                yandex_CreateMarker(aPoints[i].lat, aPoints[i].lng, aPoints[i].descr);
            }
            SetBoundsForPoints(aPoints);
        }

        function CreateRoute(aMarkers) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "CreateRoute");

            yandex_Route(aMarkers);
            SetBoundsForPoints(aMarkers);
        }

        function ChangeProps_Value(aIndex, aProp, aValue) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "ChangeProps_Value");

            yandex_ChangeProps_Value(aIndex, aProp, aValue)
        }


        function DeleteAreaByIndex(aIndex) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "DeleteAreaByIndex");

            yandex_DeleteArea(aIndex)
        }

        function DeleteAreaBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "DeleteAreaBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { DeleteAreaByIndex(ind); }
        }

        function EditAreaBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "EditAreaBySessionID" + "~" + aSessionID);

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_PolygonStartEditing(ind); }
        }

        function SaveAreaBySessionID(aSessionID, AreaID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SaveAreaBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    ind = i;
                    break;
                }
            }
            if (ind != -1) { yandex_PolygonStopEditing(ind, AreaID); }
        }

        function PolygonAboutBySessionID(aSessionID) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "PolygonAboutBySessionID");

            var ind = -1;
            for (var i = 0; i < PolygonList.length; i++) {
                if (PolygonList[i].metaDataProperty.SessionID == aSessionID) {
                    yandex_PolygonAbout(PolygonList[i]);
                    return;
                }
            }
        }


        // --- common utils functions ---------------------------------------------------------------------
        function GetObjectProps(aObj, Level) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "GetObjectProps");

            var Result = ""; for (var key in aObj) { Result = Result + key + ":" + aObj[key] + '\n' } return Result;
        }
        function SetValueOf(aName, aValue) {
            if (typeof this[aName] != "undefined") { this[aName].value = aValue; if (this[aName].id != "forDebug") SendMessage(aName); } else { }
        }
        function SendMessage(aText) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "SendMessage" + aText);

            try { window.navigate("#" + aText); } catch (e) { var url = "#" + aText; location.href = url; }/*finally{alert(aText);}*/
        }
        function getFnName(fn) {
            //SetValueOf("forDebug", document.getElementById("forDebug").value + " | " + "getFnName");

            return fn.toString().match(/function ([^(]*)\(/)[1];
        } //http://javascript.ru/forum/misc/4895-uznat-imya-funkcii.html
        // ------------------------------------------------------------------------
    </script>
</head>
<body onload="yandex_initialize()">
    <div id="map" style="width:100%; height:100%"></div>
    <input type="hidden" id="AreaXML" value="">
    <input type="hidden" id="ClickCoord" value="">
    <input type="hidden" id="forDebug" value="" style="width: 98%;" />
</body>
</html> 