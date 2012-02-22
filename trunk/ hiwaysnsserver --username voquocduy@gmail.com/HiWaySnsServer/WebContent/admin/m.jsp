<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page	import ="java.util.*,java.sql.*"%>
<%
Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
String url = "jdbc:odbc:Sample_Parkmi";
Connection con = DriverManager.getConnection(url,"parkmi","parkmi77");
Statement st = con.createStatement();
String names [] = {"user1","user2"};

int tag=0;
int userCounts = names.length;
String templat="", templng="",tempspeed="";

out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");

for(int i=0;i<userCounts;i++)
{
	ResultSet count = st.executeQuery("select * from location_info where user_id='"+names[i]+"'");
	
	while(count.next())
	{
		tag = count.getRow();
	}
	
	out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(tag)+"'>");
	count.close();
	
	ResultSet rs = st.executeQuery("select loc_lat,loc_lng,loc_speed from location_info where user_id='"+names[i]+"'");
	
	int j=0;
	float [][] loc_lat = new float[userCounts][tag];
	float [][] loc_lng = new float[userCounts][tag];
	String [][] loc_speed = new String[userCounts][tag];
	
	while(rs.next())
	{
		loc_lat[i][j] = rs.getFloat("loc_lat");
		loc_lng[i][j] = rs.getFloat("loc_lng");
		loc_speed[i][j] = rs.getString("loc_speed");
		out.println("<input type=hidden id='tempLOClat"+i+j+"' value='"+loc_lat[i][j]+"'>");
		out.println("<input type=hidden id='tempLOClng"+i+j+"' value='"+loc_lng[i][j]+"'>");
		out.println("<input type=hidden id='tempSpeed"+i+j+"' value='"+loc_speed[i][j]+"'>");
		j++;
	}	
	rs.close();
}

%>
<html>
<head>
		<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
		<link href="http://code.google.com/apis/maps/documentation/javascript/examples/default.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="http://www.google.com/jsapi"></script>
		<title>TrOASIS 사용자 경로 보여주기</title>
		<style type="text/css">
			html 
			{
				height: 100%
			}
			body 
			{
				height: 100%;
				margin: 0px;
				padding: 0px
			}
		</style>
		<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>		
		<script type="text/javascript">
  		function mapview() 
  		{
		    var myLatLng = new google.maps.LatLng(37.433244, 126.643224);
		    var myOptions = {
		      zoom: 16,
		      center: myLatLng,
		      mapTypeId: google.maps.MapTypeId.ROADMAP
		 };

   		var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
   		
   		var loc_lat = new Array();
   		var loc_lng = new Array();
   		var loc_speed = new Array();
   		var Max_Count = new Array();
   		var templat,templmg,tempspeed,tempMax,counts;
   		var counts=document.getElementById("users").value;
   		
   		for(i=0;i<counts;i++){
   	   		tempMax = "maxCount"+i;
   	   		Max_Count[i] = document.getElementById(tempMax).value;
   		}
   		
   		for(i =0;i<counts;i++){
   			loc_lat[i] = new Array();
   	   		loc_lng[i] = new Array();
   	   		loc_speed[i] = new Array();
   	   		for(j=0;j<Max_Count[i];j++){
   	   		templat = "tempLOClat"+i+j;
   	   		templng = "tempLOClng"+i+j;	
   	   		tempspeed="tempSpeed"+i+j;
   	   		loc_lat[i][j] = document.getElementById(templat).value;
			loc_lng[i][j] = document.getElementById(templng).value;
			loc_speed[i][j] = document.getElementById(tempspeed).value;
   	   		}
   		}

   		var coordinate = new Array();
   		for(i =0;i<counts;i++){
   	   		coordinate[i] = new Array();
   	   		for(j=0;j<Max_Count[i];j++){
   	   			coordinate[i][j] = new google.maps.LatLng(loc_lat[i][j],loc_lng[i][j]);
   	   		}
   		}
   		
		var colors="";
		for(i =0;i<counts;i++)
		{
   	   		for(j=0;j<Max_Count[i]-1;j++)
   	   		{
   	   			colors="";
   	   			if(loc_speed[0][j]<40)
   					colors = "#FF0000";
   				else if(loc_speed[0][j]<60)
   					colors = "#FF8C00";
   				else if(loc_speed[0][j]<80)
   					colors = "#9ACD32";
   				else
   					colors = "#6B8E23";
   	   		
   	   			var coordinatePath = [coordinate[i][j],coordinate[i][j+1]];

   				var flightPath = new google.maps.Polyline({

   				path: coordinatePath,
   				strokeColor: colors,
   				strokeOpacity: 1.0,
   				strokeWeight: 3
   				});
   			
   				flightPath.setMap(map);
   				}
   	   		}
		}
   		
</script>
</head>

<%

st.close();
con.close();
%>
<body onLoad="mapview()">
	<div id="map_canvas" style="position:relative;float:left;width:120%;height:120%;"></div>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
	
</body>
</html>
