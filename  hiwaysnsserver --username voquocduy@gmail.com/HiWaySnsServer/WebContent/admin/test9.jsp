<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page	import ="java.util.*,java.sql.*"%>

<%
	Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
	String url = "jdbc:odbc:Sample_Parkmi";
	Connection con = DriverManager.getConnection(url,"parkmi","parkmi77");
	Statement st = con.createStatement();
	String names [] = {"user1","user2"};

	int tag=0;
	int userCounts =names.length;
	String templat="", templng="",tempspeed="";
	ResultSet count;
	out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");
	
	for(int i=0;i<userCounts;i++)
	{
		count = st.executeQuery("select * from location_info where user_id='"+names[i]+"'");
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
	var httpReq = null;
	
	function getInstance()
	{
		var httpReq = null;
	
		try
		{
			httpReq = new ActiveXObject("Msxml2.XMLHTTP");	
		} 
		catch(Ex) 
		{
			try
			{
				httpReq = new ActiveXObject("Microsoft.XMLHTTP");
			} 
			catch (Ex2) 
			{
				httpReq = null;
			}
		}
		return httpReq;	
	}
	
	function sendData()
	{
		httpReq = getInstance();			
		var users =document.getElementById("userid").value;			
		httpReq.open("GET", "Ajax2.jsp?userid="+users, true);
		httpReq.onreadystatechange = handleStateChange;
		httpReq.send();		
	
	}
	
	function handleStateChange()
	{
		if (httpReq.readyState==4) 
		{
				
			if(window.ActiveXObject)
			{   
		      		xmlDocument = new ActiveXObject('Microsoft.XMLDOM');
		      		xmlDocument.async = false;
		      		xmlDocument.loadXML(httpReq.responseText);
		   	} 
			else if (window.XMLHttpRequest) 
			{   
		      		xmlParser = new DOMParser();
		      		xmlDocument = xmlParser.parseFromString(httpReq.responseText, 'text/xml');
		   	} 
			else 
			{
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
			
  	   		for(i = 0; i < UserPathCount; i++)
  	   		{
				person  = personList.childNodes[i];	
				loc_lat[i] = person.getElementsByTagName("lat")[0].childNodes[0].nodeValue;											
				loc_lng[i] = person.getElementsByTagName("lng")[0].childNodes[0].nodeValue;								
				loc_speed[i] = person.getElementsByTagName("speeds")[0].childNodes[0].nodeValue;							
			}
			
  	   		var coordinate = new Array();
	  		for(j=0;j<UserPathCount;j++)
	  		{
	  			coordinate[j] = new google.maps.LatLng(loc_lat[j],loc_lng[j]);
	  		}
	  		
	  		var colors="";
	  		for(j=0;j<UserPathCount-1;j++)
	  		{
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