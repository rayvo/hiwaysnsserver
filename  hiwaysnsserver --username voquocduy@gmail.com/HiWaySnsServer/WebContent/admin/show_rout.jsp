<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"%>
<%@ include file="../common/config.jsp"%>
<%@	page	import ="java.util.*"%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page"/>

<%
	String names [] = {"290681"};

	int tag=0;
	int userCounts = names.length;
	String templat="", templng="",tempspeed="";
	
	out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");
	
	////////////////////// 데이터 읽어 오는 부분///////////////////////S
	
	try{
				
			for(int i=0;i<userCounts;i++)
			{
				
				db.db_open();
		
				String	strQuery;
				String	strLocationInfo	= "location_info";
		
				strQuery = "SELECT count(*)";
				strQuery = strQuery + " FROM " + strLocationInfo;
				strQuery = strQuery + " WHERE user_id = '" + names[i] + "'"; 
				db.exec_query( strQuery );
				
				while(db.mDbRs.next())
				{
					tag = db.mDbRs.getInt(1);
				}
				
				out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(tag)+"'>");
				
		
				strQuery = "SELECT loc_lat, loc_lng, loc_speed";
				strQuery = strQuery + " FROM " + strLocationInfo;
				strQuery = strQuery + " WHERE user_id = '" + names[i] + "'"; 
				db.exec_query( strQuery );
				
				int j=0;
				float [][] loc_lat = new float[userCounts][tag];
				float [][] loc_lng = new float[userCounts][tag];
				String [][] loc_speed = new String[userCounts][tag];
				
				while(db.mDbRs.next())
				{
					loc_lat[i][j] = db.mDbRs.getFloat("loc_lat");
					loc_lng[i][j] = db.mDbRs.getFloat("loc_lng");
					loc_speed[i][j] = db.mDbRs.getString("loc_speed");
					out.println("<input type=hidden id='tempLOClat"+i+j+"' value='"+loc_lat[i][j]+"'>");
					out.println("<input type=hidden id='tempLOClng"+i+j+"' value='"+loc_lng[i][j]+"'>");
					out.println("<input type=hidden id='tempSpeed"+i+j+"' value='"+loc_speed[i][j]+"'>");
					j++;
				}	
			}
	
	///////////////////////////////////////////////////////////////E
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
		    var myLatLng = new google.maps.LatLng(37.377261, 126.666869);
		    var myOptions = 
		    {
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
	   		
	   		for(i=0;i<counts;i++)
	   		{
	   	   		tempMax = "maxCount"+i;
	   	   		Max_Count[i] = document.getElementById(tempMax).value;
	   		}
	   		
	   		for(i =0;i<counts;i++)
	   		{
	   			loc_lat[i] = new Array();
	   	   		loc_lng[i] = new Array();
	   	   		loc_speed[i] = new Array();
	   	   		
	   	   		for(j=0;j<Max_Count[i];j++)
	   	   		{
		   	   		templat = "tempLOClat"+i+j;
		   	   		templng = "tempLOClng"+i+j;	
		   	   		tempspeed="tempSpeed"+i+j;
		   	   		loc_lat[i][j] = document.getElementById(templat).value;
					loc_lng[i][j] = document.getElementById(templng).value;
					loc_speed[i][j] = document.getElementById(tempspeed).value;
	   	   		}
	   		}
	
	   		var coordinate = new Array();
	   		for(i =0;i<counts;i++)
	   		{
	   	   		coordinate[i] = new Array();
	   	   		for(j=0;j<Max_Count[i];j++)
	   	   		{
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
      db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		//오류 메시지 출력.
		System.out.println( "[CHANGED CCTV INFO LIST]" + e.toString());
	}
	finally	
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>

<body onload="mapview()">
	<div id="map_canvas" style="position:relative;float:left;width:120%;height:120%;"></div>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
</body>
</html>
