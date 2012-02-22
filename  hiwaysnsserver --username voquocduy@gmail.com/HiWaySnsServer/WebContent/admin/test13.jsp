
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko" lang="ko">
<head>
<title>Ajax XMLHttpRequest!</title>
<meta http-equiv="content-type" content="text/html; charset=euc-kr" />
</head>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>	
<script language="javascript">
<!--

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
		}
	}
	function getData(){
		
		httpReq = getInstance();					
		httpReq.open("POST", "Ajax3.jsp", true);
		httpReq.onreadystatechange = handleStateChange2;
		httpReq.send();		
	
	}
	function handleStateChange2(){
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
			var personList = xmlDocument.getElementsByTagName("TROPath")[0];
			var Counting = personList.childNodes[0];
			var counts = Counting.childNodes[0].nodeValue;
			var person = personList.childNodes[1];
			var UserPathCount = person.childNodes.length;
			//alert(personList.childNodes[1].nodeName); //user
			//alert(personList.childNodes.length);
			var loc_lat = new Array();
  	   		var loc_lng = new Array();
  	   		var loc_speed = new Array();								
			for(i = 0; i <counts; i++){
				person = personList.childNodes[i+1];
				loc_lat[i] = new Array();
				loc_lng[i] = new Array();
				loc_speed[i] = new Array();
				for(j=0;j<UserPathCount;j++){
				var users  = person.childNodes[j];	
				loc_lat[i][j] = users.getElementsByTagName("lat")[0].childNodes[0].nodeValue;											
				loc_lng[i][j] = users.getElementsByTagName("lng")[0].childNodes[0].nodeValue;								
				loc_speed[i][j] = users.getElementsByTagName("speeds")[0].childNodes[0].nodeValue;
				}							
			}
			//alert(loc_lat[0][0]);
			var coordinate = new Array();
	  		for(i=0;i<counts;i++){
		  		coordinate[i] = new Array();
		  		for(j=0;j<UserPathCount;j++){
	  			coordinate[i][j] = new google.maps.LatLng(loc_lat[i][j],loc_lng[i][j]);
		  		}
	  		}
	  		
	  		var colors="";
	  		for(i=0;i<counts;i++){
		  		for(j=0;j<UserPathCount-1;j++)
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
						strokeWeight: 4
						});
					
						flightPath.setMap(map);
						}
		  		}
	  		
		}
	}
					
//-->
</script>
<body onLoad="getData();">
<form name="myForm" method="post">
<input type="text" name="userid" id="userid">
	<input type="button" name="myname" onClick="sendData()" value="Send">
	</form>

<div id="map_canvas" style="position:relative;float:left;width:120%;height:120%;"></div>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
</body>
</html>
