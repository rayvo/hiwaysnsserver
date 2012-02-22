<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false )	//세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>    
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>    
	<title>사용자 메시지 등록</title>
	<!--
	[키값 목록]
	http://dogong1.hscdn.com:8080/HiWaySnsServer/	: ABQIAAAAPHCofgvl1wGGC31Ug8a5dhTzz8_U17KZau0FC9-akRneOD3HYhQAvy2snF-Shomxz4-M7shcJq04qA
	http://211.56.151.87:8080/HiWaySnsServer/		: ABQIAAAAPHCofgvl1wGGC31Ug8a5dhT0xRPMSdU-TRLbeoq1wDsHePJyJhSeVQQGuRUShBqP-9U9DR011KZltw
	http://211.56.151.87							: ABQIAAAAoVWmx6H9K9JuEn0xTiHMexRe0nybg4Tq0qfwnjHtHBKSgaEhcxSVZSMqfTpi-_Shl-P6uD9BhDz4xQ
	http://dogong.hscdn.com:8080/HiWaySnsServer/admin/admin_user_msg.jsp : ABQIAAAA6Dhy9t5cBaSxXmKt51WdlhSWjmX3i-6slNxjaObEIKxM49_E9hROfoQKImNeWBs4nRt8a-6_ITeDqg
	-->
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAA6Dhy9t5cBaSxXmKt51WdlhSWjmX3i-6slNxjaObEIKxM49_E9hROfoQKImNeWBs4nRt8a-6_ITeDqg" type="text/javascript"></script>  
	<script type="text/javascript">
		window.onload=initialize;
		window.onunload=GUnload;
		
		var map;
		var control;
		var geocoder = null;
		var bounds = new GLatLngBounds();
 
 
		// Very Basic Map setup on canvas
		function initialize() {      
			if (GBrowserIsCompatible()) {        
				map = new GMap2(document.getElementById("map_canvas"));        
				map.setCenter(new GLatLng(37.55, 126.972626), 10);
		        map.addControl(new GSmallMapControl());
		        map.addControl(new GMapTypeControl());    
				map.enableScrollWheelZoom();

		        GEvent.addListener(map,"click", function(overlay,latlng) {
		            if (overlay) {
		              return;
		            }
		            var tileCoordinate = new GPoint();
		            var tilePoint = new GPoint();
		            var currentProjection = G_NORMAL_MAP.getProjection();
		            tilePoint = currentProjection.fromLatLngToPixel(latlng, map.getZoom());
		            tileCoordinate.x = Math.floor(tilePoint.x / 256);
		            tileCoordinate.y = Math.floor(tilePoint.y / 256);
		            var myHtml = "X : " + latlng.lng() + "<br/>Y : " + latlng.lat();
		              //+ "<br/>The Tile Coordinate is:<br/> x: " + tileCoordinate.x + 
		              //"<br/> y: " + tileCoordinate.y + "<br/> at zoom level " + map.getZoom();
		            map.openInfoWindow(latlng, myHtml);
		            document.getElementById("x_coord").innerHTML = Math.floor(latlng.lng() * 1000000);
		            document.getElementById("y_coord").innerHTML = Math.floor(latlng.lat() * 1000000);
		            //  myHtml.toString();
		        });
 
				setMarkers();
			}    
		}
 
		function setMarkers() {
			bounds = new GLatLngBounds();
			geocoder = new GClientGeocoder();
			map.clearOverlays();			
 
			var chosen = "";
			var elemRadio = document.q.radio1;
			for (i = 0; i <elemRadio.length; i++) {
				if (elemRadio[i].checked)	chosen = elemRadio[i].value;
			}
 
			switch (chosen){
				case "via_GLatLng":			setMarkerByGLatLng(37.55, 126.972626);					break;
				case "via_XMLLoad1":		setDefaultMarkersByXMLLoad("r88_t.xml");					break;
				case "via_XMLLoad2":		setDefaultMarkersByXMLLoad("rkyungbu.xml");				break;
			}
		}	
 
 
		function setMarkerByGLatLng(lat,lng) {
			var point = new GLatLng(parseFloat(lat), parseFloat(lng));    
			var myHtml = point.toString() ;    
			map.openInfoWindowHtml(point,myHtml);  
 
			var marker = new GMarker(point);  
			map.addOverlay(marker);  
		}
 
 
		function setDefaultMarkersByXMLLoad(xmlLoad) {
			var markerArray = new Array();
			GDownloadUrl(xmlLoad, function(data, responseCode) {  
				var xml = GXml.parse(data);  
				var markers = xml.documentElement.getElementsByTagName("marker");  
				for (var i = 0; i < markers.length; i++) {    
					var point = new GLatLng(parseFloat(markers[i].getAttribute("lat")), parseFloat(markers[i].getAttribute("lng")));    
					var desc = markers[i].getAttribute("desc");
					markerArray[i] = new GMarker(point);  
					GEvent.addListener(markerArray[i], "click", function() 
					{    
						var myHtml = desc + "<br />" + point.toString() ;    
						markerArray[i].openInfoWindowHtml();  
					});
					map.addOverlay(markerArray[i]);  
					bounds.extend(point);
					map.setZoom(map.getBoundsZoomLevel(bounds));
					map.setCenter(bounds.getCenter());
				}
			document.getElementById("id").innerHTML = desc;
			});
		}
	</script>
</head>
 
<script type="text/javascript">
//<!--
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.x_coord.value == "" || frm_input.y_coord.value == "" )
	{
		alert( "지도 위치가 정의되지 않았습니다.\n지도에서 메시지 위치를 입력해 주세요." );
		frm_input.x_coord.focus();
		return( false );
	}
	if ( frm_input.userName.value == "" )
	{
		alert( "등록자 이름을 입력하세요." );
		frm_input.userName.focus();
		return( false );
	}
	if ( frm_input.userMsg.value == "" )
	{
		alert( "메시지 내용을 입력하세요." );
		frm_input.userMsg.focus();
		return( false );
	}
	return( true );
}
//-->
</script>
<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"%>
		<!-- 	(끝) 헤더.	-->
		
		<tr height="600">
			<!-- 	(시작) 메뉴영역.	-->
		<%
			//System.out.println( "loginManager.mRole=" + loginManager.mRole );
			if ( loginManager.mRole < 1 )
			{
				//운영자 메뉴 표현.
		%>
			<!-- 	(시작) 운영자 메뉴.	-->
			<%@ include file="../admin/common_left_menu.jsp"%>
			<!-- 	(끝) 운영자 메누.	-->

		<%
			}
			else
			{
				//관리자 메뉴 표현.
		%>
			<!-- 	(시작) 관리자 메뉴.	-->
			<%@ include file="../admin/common_left_menu_admin.jsp"%>
			<!-- 	(끝) 관리자 메누.	-->
		<%
			}
		%>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="40"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top" align="center">
<%
	String	userID		= loginManager.getUserID( session.getId() );
	String	userName	= LoginManager.mUserName;
%>
	<form name="q" action="admin_user_msg_process.jsp" method="post" onsubmit="return js_user_input();">
	<div id="map_canvas" style="margin: 1em 1em; width:800px; height: 600px; float:left"></div>
	<div id="doSomething" style="text-align:left; margin: 1em 1em; float:left;" onclick='setMarkers()'>
		<b>사용자 메시지</b><br/><br/>
		위치정보<br/>
		<div id="status"></div>
		<input type="hidden" name="userID" id="userID" value="<%=userID%>" /><br/><br/>
		<textarea id="x_coord" name="x_coord" id="x_coord"></textarea>
		<textarea id="y_coord" name="y_coord" id="y_coord"></textarea><p/>
		등록자 이름 : <input type="text" name="userName" id="userName" value="<%=userName%>" /><br/><br/>
		메시지 입력<br/>
		<textarea name="userMsg" cols="43"></textarea><br/><br/>
		<input type="submit"/>
	</div>
	</form>
			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"%>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
</html>
