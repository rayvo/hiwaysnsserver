<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"%>
<%@ include file="../common/config.jsp"%>
<%@	page import ="java.util.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@ page import="java.text.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"	%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page"/>
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />

<%

int logs [] = {  
		 359733, 
		 359749, 
		 359762, 
		 354747, 
		 359766, 
		 359768, 
		 359769, 
		 359771, 
		 359773, 
		 359776, 
		 359567, 
		 359783, 
		 359785, 
		 359787, 
		 359282, 
		 359789, 
		 359790, 
		 359798, 
		 359805, 
		 359777, 
		 359809, 
		 359817, 
		 359818, 
		 359819, 
		 359824, 
		 359822, 
		 359826, 
		 359829, 
		 359834, 
		 359832, 
		 359835, 
		 359836, 
		 359840, 
		 359841, 
		 359848, 
		 359851, 
		 359850, 
		 359854, 
		 359861, 
		 359862, 
		 359860, 
		 359863, 
		 359864, 
		 359865, 
		 359867, 
		 359877, 
		 359881, 
		 359884, 
		 359895, 
		 359903, 
		 359905, 
		 359906, 
		 359912, 
		 359914, 
		 359913, 
		 359915, 
		 359916, 
		 359924, 
		 359922, 
		 359925, 
		 359928, 
		 359932, 
		 359937, 
		 359941, 
		 359947, 
		 359949, 
		 359952, 
		 359954, 
		 359956, 
		 359955, 
		 359590, 
		 359963, 
		 359966, 
		 359970, 
		 359971, 
		 359972, 
		 359975, 
		 359978, 
		 359979, 
		 275670, 
		 359994, 
		 359998, 
		 346624, 
		 360010, 
		 360013, 
		 360014, 
		 360017, 
		 360025, 
		 360031, 
		 360032, 
		 360033, 
		 360038, 
		 360039, 
		 360041, 
		 357116, 
		 360047, 
		 360048, 
		 360046, 
		 360049, 
		 358502, 
		 360056, 
		 360057, 
		 360059, 
		 360060, 
		 360061, 
		 360065, 
		 360069, 
		 360071, 
		 360073, 
		 360074, 
		 360078, 
		 360077, 
		 360083, 
		 329208, 
		 360086, 
		 360091, 
		 360093, 
		 360096, 
		 360098, 
		 360099, 
		 360101, 
		 360102, 
		 360108, 
		 360110, 
		 360115, 
		 360116, 
		 360112, 
		 360122, 
		 360123, 
		 360126, 
		 360132, 
		 360134, 
		 360136, 
		 360143, 
		 360149, 
		 360151, 
		 360152, 
		 360154, 
		 360156, 
		 360159, 
		 360160, 
		 360164, 
		 360165, 
		 360166, 
		 360169, 
		 360170, 
		 360174, 
		 358837, 
		 358434, 
		 359191, 
		 360182, 
		 360184, 
		 360192, 
		 348906, 
		 360201, 
		 360203, 
		 360205, 
		 360207, 
		 360208, 
		 360210, 
		 360211, 
		 354442, 
		 360213, 
		 360220, 
		 360221, 
		 360222, 
		 360226, 
		 360229, 
		 360230, 
		 360231, 
		 360232, 
		 354418, 
		 360235, 
		 360239, 
		 360241, 
		 360245, 
		 360244, 
		 360246, 
		 360250, 
		 360251, 
		 360257, 
		 360258, 
		 360267, 
		 360275, 
		 360279, 
		 359507, 
		 360285, 
		 360288, 
		 360289, 
		 360294, 
		 356170, 
		 360296, 
		 360300, 
		 356421, 
		 360302, 
		 360306, 
		 360311, 
		 360312, 
		 360315, 
		 360318, 
		 360320, 
		 360321, 	 
};

int tag=0;
int userCounts = logs.length;
String templat="", templng="",tempspeed="";
int splitedCounts = userCounts;

out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");

////////////////////// 데이터 읽어 오는 부분///////////////////////S

try{
			
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

			double loc_lat1=0, loc_lat2, loc_lng1=0, loc_lng2;
			int loc_speed1=0, loc_speed2;
			long time_log1=0, time_log2;
			
			
			strQuery = "SELECT time_log, loc_lat, loc_lng, speed";
			strQuery = strQuery + " FROM " + strTroasisLog;
			strQuery = strQuery + " WHERE log_id = " + logs[i]; 
			strQuery = strQuery + " AND speed>0 ";
			strQuery	= strQuery + " ORDER BY log_id DESC";
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
						if(distance_lat>0.05 || distance_lat<-0.05 || distance_lng>0.05 || distance_lng<-0.05) 
						{
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
				out.println("<input type=hidden id='maxCount"+i+"' value='"+String.valueOf(j)+"'>");
			}
		}

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
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko" lang="ko">
<head>
<title>Ajax XMLHttpRequest!</title>
<meta http-equiv="content-type" content="text/html; charset=euc-kr" />
</head>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>	
<script language="javascript">
<!--
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
  		templat = "tempLOClat"+i+"_"+j;
  		templng = "tempLOClng"+i+"_"+j;	
  		tempspeed="tempSpeed"+i+"_"+j;
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
for(i =0;i<counts;i++){
  		for(j=0;j<Max_Count[i]-1;j++){
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
	var httpReq = null;
	
	function getInstance(){
		var httpReq = null;
	
		try{
			httpReq = new ActiveXObject("Msxml2.XMLHTTP");	
		} catch(Ex) {
			try{
				httpReq = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (Ex2) {
				httpReq = null;
			}
		}
		return httpReq;	
	}
	
	function sendData(){
	
		httpReq = getInstance();			
		var users =document.getElementById("userid").value;			
		httpReq.open("GET", "test6.jsp?userid="+users, true);
		httpReq.onreadystatechange = handleStateChange;
		httpReq.send();		
	
	}
	function handleStateChange(){
		if (httpReq.readyState==4) {
		
			
			if(window.ActiveXObject){   
		      		xmlDocument = new ActiveXObject('Microsoft.XMLDOM');
		      		xmlDocument.async = false;
		      		xmlDocument.loadXML(httpReq.responseText);
		   	} else if (window.XMLHttpRequest) {   
		      		xmlParser = new DOMParser();
		      		xmlDocument = xmlParser.parseFromString(httpReq.responseText, 'text/xml');
		   	} else {
		      		return null;
		   	}	   	
		   			   		   	
			var myLatLng = new google.maps.LatLng(37.433244, 126.643224);
			 var myOptions = {
	  			      zoom: 16,
	  			      center: myLatLng,
	  			      mapTypeId: google.maps.MapTypeId.ROADMAP
	  			 };

	  		var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); 	   	 	 						   			   				
			var personList = xmlDocument.getElementsByTagName("user")[0];
			var person = personList.childNodes[0];
			var writeStr = "";
			var UserPathCount = personList.childNodes.length;
			var loc_lat = new Array();
  	   		var loc_lng = new Array();
  	   		var loc_speed = new Array();								
			for(i = 0; i < UserPathCount; i++){
				person  = personList.childNodes[i];	
				loc_lat[i] = person.getElementsByTagName("lat")[0].childNodes[0].nodeValue;											
				loc_lng[i] = person.getElementsByTagName("lng")[0].childNodes[0].nodeValue;								
				loc_speed[i] = person.getElementsByTagName("speeds")[0].childNodes[0].nodeValue;							
			}
			var coordinate = new Array();
	  		for(j=0;j<UserPathCount;j++){
	  			coordinate[j] = new google.maps.LatLng(loc_lat[j],loc_lng[j]);
	  		}
	  		var colors="";
	  		for(j=0;j<UserPathCount-1;j++){
		   			colors="";
		   			if(loc_speed[j]<40)
						colors = "#FF0000";
					else if(loc_speed[j]<60)
						colors = "#FF8C00";
					else if(loc_speed[j]<80)
						colors = "#9ACD32";
					else
						colors = "#6B8E23";
		   		var coordinatePath = [coordinate[j],coordinate[j+1]];

				var flightPath = new google.maps.Polyline({

					path: coordinatePath,
					strokeColor: colors,
					strokeOpacity: 1.0,
					strokeWeight: 3
					});
				
					flightPath.setMap(map);
					}			
																							
			//document.getElementById('myDiv').innerHTML = writeStr;
		}
	}				
//-->
</script>


<body onLoad="mapview();">
<form name="myForm" method="post">
<input type="text" name="userid" id="userid">
	<input type="button" name="myname" onClick="sendData()" value="Send">
	</form>

<div id="map_canvas" style="position:relative;float:left;width:120%;height:120%;"></div>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
</body>
</html>
