<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"%>
<%@ include file="../common/config.jsp"%>
<%@	page	import ="java.util.*"%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page"/>

<%
double EARTH_RADIUS = 6378.137;

int logs [] = {  
		 322161 ,
		 321917 ,
		 321061 ,
		 322165 ,
		 322173 ,
		 322177 ,
		 322178 ,
		 322179 ,
		 322181 ,
		 322187 ,
		 322191 ,
		 322192 ,
		 322195 ,
		 322084 ,
		 322203 ,
		 322206 ,
		 322209 ,
		 322211 ,
		 322210 ,
		 322214 ,
		 322216 ,
		 322217 ,
		 322227 ,
		 322229 ,
		 322231 ,
		 322234 ,
		 322235 ,
		 322236 ,
		 322240 ,
		 322244 ,
		 311717 ,
		 322250 ,
		 322254 ,
		 322266 ,
		 
};

int tag=0;
int userCounts = logs.length;
String templat="", templng="",tempspeed="";
//int flag=0;
int splitedCounts = userCounts;

//out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");

////////////////////// 데이터 읽어 오는 부분///////////////////////S

try{
	
	out.println("<input type=hidden id='users' value='"+String.valueOf(splitedCounts)+"'>");
	
		for(int i=0;i<splitedCounts;i++)
		{			
			db.db_open();
	
			String	strQuery;
			String	strTroasisLog	= "troasis_log";

			strQuery = "SELECT count(*)";
			strQuery = strQuery + " FROM " + strTroasisLog;
			strQuery = strQuery + " WHERE log_id = " + logs[i]; 
			strQuery = strQuery + " AND speed>0 ";
			db.exec_query( strQuery );
			
			while(db.mDbRs.next())
			{
				tag = db.mDbRs.getInt(1);
			}
			
			//out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(tag)+"'>");


			/*
			double [][] loc_lat = new double[userCounts][tag];
			double [][] loc_lng = new double[userCounts][tag];
			int [][] loc_speed = new int [userCounts][tag];
			long[][] time_log = new long [userCounts][tag];
			*/
			double loc_lat1=0, loc_lat2, loc_lng1=0, loc_lng2;
			int loc_speed1=0, loc_speed2;
			long time_log1=0, time_log2;
			
			
			strQuery = "SELECT time_log, loc_lat, loc_lng, speed";
			strQuery = strQuery + " FROM " + strTroasisLog;
			strQuery = strQuery + " WHERE log_id = " + logs[i]; 
			strQuery = strQuery + " AND speed>0 ";
			strQuery	= strQuery + " ORDER BY id DESC";
			db.exec_query( strQuery );
			
			int j=0;
			while(db.mDbRs.next())
			{
				time_log2 =  db.mDbRs.getInt("time_log");
				loc_lat2  = (double)(db.mDbRs.getInt("loc_lat"))/1000000.00;
				loc_lng2 = (double)(db.mDbRs.getInt("loc_lng"))/1000000.00;
				loc_speed2 = db.mDbRs.getInt("speed");

				if(j>0)
				{
					double distance_lat = loc_lat2-loc_lat1;
					double distance_lng = loc_lng2-loc_lng1;
					double speed_lat = distance_lat/(time_log2-time_log1);
					double speed_lng = distance_lng/(time_log2-time_log1);
					
					if(speed_lat>0.0006||speed_lat<-0.0006||speed_lng>0.0006||speed_lat<-0.0006)
					{
						//flag++;
						if(distance_lat>0.05 || distance_lat<-0.05 || distance_lng>0.05 || distance_lng<-0.05) {
							out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(j)+"'>");
							i++;
							j=0;
							out.println("<input type=hidden id='tempLOClat"+i+"_"+j+"' value='"+loc_lat2+"'>");
							out.println("<input type=hidden id='tempLOClng"+i+"_"+j+"' value='"+loc_lng2+"'>");
							out.println("<input type=hidden id='tempSpeed"+i+"_"+j+"' value='"+loc_speed2+"'>");						
							time_log1 = time_log2;
							loc_lat1 = loc_lat2;
							loc_lng1 = loc_lng2;
							loc_speed1 = loc_speed2;
							//flag=0;
							j++;
						}
					} else {
						out.println("<input type=hidden id='tempLOClat"+i+"_"+j+"' value='"+loc_lat2+"'>");
						out.println("<input type=hidden id='tempLOClng"+i+"_"+j+"' value='"+loc_lng2+"'>");
						out.println("<input type=hidden id='tempSpeed"+i+"_"+j+"' value='"+loc_speed2+"'>");						
						time_log1 = time_log2;
						loc_lat1 = loc_lat2;
						loc_lng1 = loc_lng2;
						loc_speed1 = loc_speed2;
						//flag=0;
						j++;
					}
				}
				else
				{
					out.println("<input type=hidden id='tempLOClat"+i+"_"+j+"' value='"+loc_lat2+"'>");
					out.println("<input type=hidden id='tempLOClng"+i+"_"+j+"' value='"+loc_lng2+"'>");
					out.println("<input type=hidden id='tempSpeed"+i+"_"+j+"' value='"+loc_speed2+"'>");
					time_log1 = time_log2;
					loc_lat1 = loc_lat2;
					loc_lng1 = loc_lng2;
					loc_speed1 = loc_speed2;		
					j++;
				}		
			}
			out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(j)+"'>");
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
		    var myLatLng = new google.maps.LatLng(37.392918, 127.026438);
		    var myOptions = 
		    {
		      zoom: 12,
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
		   	   		templat = "tempLOClat"+i+"_"+j;
		   	   		templng = "tempLOClng"+i+"_"+j;	
		   	   		tempspeed="tempSpeed"+i+"_"+j;
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
	   	   			if(loc_speed[i][j]<40)
	   					colors = "#FF0000";
	   				else if(loc_speed[i][j]<60)
	   					colors = "#FF8C00";
	   				else if(loc_speed[i][j]<80)
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
		System.out.println( "[ERROR : ]" + e.toString());
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
