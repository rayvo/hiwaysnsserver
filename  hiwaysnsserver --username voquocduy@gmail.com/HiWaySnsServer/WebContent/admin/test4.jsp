<!DOCTYPE html>
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
	//입력정보 수신.

	long	start_time	= 0;
	long    end_time    = 0;
	start_time = db.getCurrentTimestamp();
	
	int		search_type	= 0;
	String	search_text	= "";
	
	String	strParam	= "";

	strParam	= param.get_input_param( request.getParameter("search_text") );
	if ( strParam.length() > 0 )
	{
		search_type = Integer.parseInt(request.getParameter("search_type"));
		search_text	= param.get_input_param( request.getParameter("search_text") );
	}
	
	//오늘 날짜 구하기.
	Calendar	ctoday	= Calendar.getInstance();
	int		year_today	= ctoday.get(Calendar.YEAR);
	int		month_today	= ctoday.get(Calendar.MONTH);
	int		date_today	= ctoday.get(Calendar.DATE);
	//int     hour_today  = ctoday.get(Calendar.HOUR);
	//int     min_today   = ctoday.get(Calendar.MINUTE);
	//int	  sec_today   = ctoday.get(Calendar.SECOND);
	
	//Calendar	cTime	= Calendar.getInstance();
	//cTime.set (year_today, month_today, date_today, hour_today, min_today, sec_today);

	//long	cTime	= cTime.getTimeInMillis() / 1000;
	
	//System.out.println("ctime = "+ cTime );
	
	//입력인자 수신.
	int		f_year_sel = 0;
	int 	f_month_sel = 0;
	int 	f_date_sel = 0;


	int		t_year_sel = 0;
	int 	t_month_sel = 0;
	int 	t_date_sel = 0;

	int		k;
	
	

	//System.out.println(" dtime = "+ currentTime );

	//long DTime = currentTime-68400; 
	//long DTime = 1326621367;
	//long DTime = 1326657367;
	
	if ( request.getParameter("f_year_sel") != null )
		f_year_sel	= Integer.parseInt( request.getParameter("f_year_sel") );
	if ( request.getParameter("f_month_sel") != null )
		f_month_sel	= Integer.parseInt( request.getParameter("f_month_sel") );
	if ( request.getParameter("f_date_sel") != null )
		f_date_sel	= Integer.parseInt( request.getParameter("f_date_sel") );

	if ( request.getParameter("t_year_sel") != null )
		t_year_sel	= Integer.parseInt( request.getParameter("t_year_sel") );
	if ( request.getParameter("t_month_sel") != null )
		t_month_sel	= Integer.parseInt( request.getParameter("t_month_sel") );
	if ( request.getParameter("t_date_sel") != null )
		t_date_sel	= Integer.parseInt( request.getParameter("t_date_sel") );

	
	
	//입력이 없는 경우, 오늘 날짜.
	if ( f_year_sel < 1 || f_month_sel < 1 )
	{
		f_year_sel	= year_today;
		f_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	}
	if ( f_date_sel < 1 )	f_date_sel = date_today-1;
	
	if ( t_year_sel < 1 || t_month_sel < 1 )
	{
		t_year_sel	= year_today;
		t_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	}
	if ( t_date_sel < 1 )	t_date_sel = date_today;

	int tag=0;
	int userCounts = 0;
	String templat="", templng="",tempspeed="";

	List<Integer>	logs	= new ArrayList<Integer>();


	Calendar	FromTime	= Calendar.getInstance();
	FromTime.set (f_year_sel, f_month_sel-1, f_date_sel, 0, 0, 0);

	long	FromDate	= FromTime.getTimeInMillis() / 1000;
	long	Ftime = FromDate;
	
	Calendar	ToTime	= Calendar.getInstance();
	ToTime.set (t_year_sel, t_month_sel-1, t_date_sel, 0, 0, 0);

	long	ToDate	= ToTime.getTimeInMillis() / 1000;
	long	Ttime = ToDate;	

	//System.out.println(" Ftime = " + Ftime );
	//System.out.println(" Ttime = " + Ttime );
	
////////////////////////////////////////// 데이터 읽어 오는 부분/////////////////////////////////////////////S

	try{
			db.db_open();
			
			String	strQuery;
			String	strTroasisLog	= "troasis_log";
				
			strQuery = "SELECT count(distinct(log_id))";
			strQuery = strQuery + " FROM " + strTroasisLog;
			//strQuery = strQuery + " WHERE time_log>" + DTime;
			strQuery = strQuery + " WHERE time_log > " + Ftime;
			strQuery = strQuery + " AND time_log < " + Ttime;
			strQuery = strQuery + " AND speed > 0";
			if ( search_text.length() > 0 )
			{
				switch( search_type )
				{
					case 1	:
						strQuery = strQuery + " AND user_id = '" + search_text + "'";
						break;
					case 2	:
						strQuery = strQuery + " AND nickname = '" + search_text + "'";
						break;
					default	:
						strQuery = strQuery + " AND (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
						strQuery = strQuery + " OR (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
						break;
				}
			}
			//System.out.println(strQuery);
			db.exec_query( strQuery );
			
			while(db.mDbRs.next())
			{
				userCounts = db.mDbRs.getInt(1);
			}
			
			strQuery = "SELECT distinct(log_id)";
			strQuery = strQuery + " FROM " + strTroasisLog;
			//strQuery = strQuery + " WHERE time_log>" + DTime;
			strQuery = strQuery + " WHERE time_log > " + Ftime;
			strQuery = strQuery + " AND time_log < " + Ttime;
			strQuery = strQuery + " AND speed > 0";
			if ( search_text.length() > 0 )
			{
				switch( search_type )
				{
				case 1	:
					strQuery = strQuery + " AND user_id = '" + search_text + "'";
					break;
				case 2	:
					strQuery = strQuery + " AND nickname = '" + search_text + "'";
					break;
				default	:
					strQuery = strQuery + " AND (UPPER(user_id) LIKE UPPER('%" + search_text + "%'))";
					strQuery = strQuery + " OR (UPPER(nickname) LIKE UPPER('%" + search_text + "%'))";
					break;
				}
			}
			//System.out.println(strQuery);
			db.exec_query( strQuery );
						
			while(db.mDbRs.next())
			{
				logs.add(db.mDbRs.getInt(1));
			}

			int i2=0;
			for(int i=0;i<userCounts;i++,i2++)
			{			
				
				strQuery = "SELECT count(*)";
				strQuery = strQuery + " FROM " + strTroasisLog;
				strQuery = strQuery + " WHERE log_id = " + logs.get(i); 
				strQuery = strQuery + " AND speed>0 ";

				db.exec_query( strQuery );
				
				while(db.mDbRs.next())
				{
					tag = db.mDbRs.getInt(1);
				}
			
				if(tag!=0)
				{
					double loc_lat1=0, loc_lat2, loc_lng1=0, loc_lng2;
					int loc_speed1=0, loc_speed2;
					long time_log1=0, time_log2;
					
					
					strQuery = "SELECT time_log, loc_lat, loc_lng, speed";
					strQuery = strQuery + " FROM " + strTroasisLog;	
					strQuery = strQuery + " WHERE log_id = " + logs.get(i); 

					strQuery = strQuery + " AND speed>0 ";		
					strQuery = strQuery + " ORDER BY time_log DESC";
					
					//System.out.println(strQuery);
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
									out.println("<input type=hidden id='maxCount"+i2+"' value='"+String.valueOf(j)+"'>");
									i2++;
									j=0;
									out.println("<input type=hidden id='tempLOClat"+i2+"_"+j+"a"+"' value='"+loc_lat2+"'>");
									out.println("<input type=hidden id='tempLOClng"+i2+"_"+j+"a"+"' value='"+loc_lng2+"'>");
									out.println("<input type=hidden id='tempSpeed"+i2+"_"+j+"a"+"' value='"+loc_speed2+"'>");						
									time_log1 = time_log2;
									loc_lat1 = loc_lat2;
									loc_lng1 = loc_lng2;
									loc_speed1 = loc_speed2;
									j++;
								}
							} 
							else 
							{
								if(distance_lat>0.05 || distance_lat<-0.05 || distance_lng>0.05 || distance_lng<-0.05)
								{
									out.println("<input type=hidden id='maxCount"+i2+"' value='"+String.valueOf(j)+"'>");
									i2++;
									j=0;
									out.println("<input type=hidden id='tempLOClat"+i2+"_"+j+"a"+"' value='"+loc_lat2+"'>");
									out.println("<input type=hidden id='tempLOClng"+i2+"_"+j+"a"+"' value='"+loc_lng2+"'>");
									out.println("<input type=hidden id='tempSpeed"+i2+"_"+j+"a"+"' value='"+loc_speed2+"'>");						
									time_log1 = time_log2;
									loc_lat1 = loc_lat2;
									loc_lng1 = loc_lng2;
									loc_speed1 = loc_speed2;
									j++;
								}
								else {
									out.println("<input type=hidden id='tempLOClat"+i2+"_"+j+"a"+"' value='"+loc_lat2+"'>");
									out.println("<input type=hidden id='tempLOClng"+i2+"_"+j+"a"+"' value='"+loc_lng2+"'>");
									out.println("<input type=hidden id='tempSpeed"+i2+"_"+j+"a"+"' value='"+loc_speed2+"'>");						
									time_log1 = time_log2;
									loc_lat1 = loc_lat2;
									loc_lng1 = loc_lng2;
									loc_speed1 = loc_speed2;
									j++;
								}
							}
						}
						else
						{
							out.println("<input type=hidden id='tempLOClat"+i2+"_"+j+"a"+"' value='"+loc_lat2+"'>");
							out.println("<input type=hidden id='tempLOClng"+i2+"_"+j+"a"+"' value='"+loc_lng2+"'>");
							out.println("<input type=hidden id='tempSpeed"+i2+"_"+j+"a"+"' value='"+loc_speed2+"'>");
							time_log1 = time_log2;
							loc_lat1 = loc_lat2;
							loc_lng1 = loc_lng2;
							loc_speed1 = loc_speed2;		
							j++;
						}						
						
					}
					out.println("<input type=hidden id='maxCount"+i2+"' value='"+String.valueOf(j)+"'>");	
				 }
			 }
			out.println("<input type=hidden id='users' value='"+String.valueOf(i2)+"'>");
			
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////E
%>

<html>
<head>
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no"/>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
	<link href="http://code.google.com/apis/maps/documentation/javascript/examples/default.css" rel="stylesheet" type="text/css" />
	<script type="text/javascript" src="http://www.google.com/jsapi"></script>

	<title>TrOASIS 사용자 경로 보여주기</title>
	
	<center><h2>TrOASIS 사용자 경로 현황판  Ver. 1.00 </h2></center>

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
	
	function js_user_input()
	{
		var frm_input	= document.form_main;
		var	f_year_sel		= frm_input.f_year_sel.value;
		var	f_month_sel		= frm_input.f_month_sel.value;
		var	f_date_sel		= frm_input.f_date_sel.value;
		var	obj_param	=   "f_year_sel=" + f_year_sel
							+ "&f_month_sel=" + f_month_sel
							+ "&f_date_sel=" + f_date_sel;
		
		var	t_year_sel		= frm_input.t_year_sel.value;
		var	t_month_sel		= frm_input.t_month_sel.value;
		var	t_date_sel		= frm_input.t_date_sel.value;
		var	obj_param	=   "t_year_sel=" + n_year_sel
							+ "&t_month_sel=" + t_month_sel
							+ "&t_date_sel=" + t_date_sel;
		
		self.location.href	= location.pathname + "?" + obj_param;
		
		var time = document.getElementById("time").value;
		alert('데이터를 DB로부터 읽어오는 시간 + 필터링 : ' + time + '초');
		
		return ( true );
	}
	
	function pushbutton() 
	{ 
		alert("	1. 기본적으로 최근 하루 데이터를 보여줍니다.\n 2. 선택하신 검색방법과 입력하신 키워드 그리고 시간 조건을 동시에 만족하는 경로 데이터들을 보여줍니다.\n 3. 현재 IE9, FireFox, 크롬 등 브라우저에서는 정상 작동되고 속도면에서 다소 차이가 있을 수 있습니다.\n ");  // n 은 줄을 바꿀때 사용합니다 
	}
	
	function PleaseWait() 
	{ 
		alert(" 데이터를 읽어오고 그래팩 그림을 그리는데 시간이 오래 걸릴수 있으니 인내심을 갖고 기다려주시기 바랍니다.^_^"); 
	} 

	function mapview() 
	{
	    var myLatLng = new google.maps.LatLng(36.935348, 127.856483);
	    var myOptions = 
	    {
	      zoom: 8,
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
		  		templat = "tempLOClat"+i+"_"+j+"a";
		  		templng = "tempLOClng"+i+"_"+j+"a";	
		  		tempspeed="tempSpeed"+i+"_"+j+"a";
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
				else if(loc_speed[i][j]<80)
					colors = "#FFFF00";
				else
					colors = "#33FF33";
		
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
		var time;
  		time = document.getElementById("time").value;
		alert('데이터를 DB로부터 읽어오는 시간 + 필터링 + 그리기: ' + time + '초');
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
		out.println("<input type=hidden id='users' value='"+String.valueOf(userCounts)+"'>");
		
		end_time = db.getCurrentTimestamp();
		//System.out.println(" End = "+ end_time );

		long db_time = end_time - start_time;
		//System.out.println(" dbtime = "+ db_time );
		out.println("<input type=hidden id='time' value='"+String.valueOf(db_time)+"'>");
	}
%>	

<body onload="mapview()">
	<form name="form_main" action="test4.jsp" method="post" onsubmit="return js_user_input();">
			<td colspan="4" align="top">
				<strong>검색방법:</strong>&nbsp;
				<select id="search_type" name="search_type" style="width: 160px; color:#000000; background-color:#ffffff;">
					<option value="0" <% if ( search_type < 1) { %>selected<% } %>>전체(User ID+닉네임)</option>
					<option value="1" <% if ( search_type == 1 ) { %>selected<% } %>>User ID</option>
					<option value="2" <% if ( search_type == 2 ) { %>selected<% } %>>닉네임</option>
				</select>
				&nbsp;&nbsp;
				<label for="search_text">
				<input type="text" name="search_text" id="search_text" value="<%=search_text%>" onFocus="this.value=''" tabindex="2" /></label>
				
				<br/>From:
				<select  id="f_year_sel" name="f_year_sel" style="width: 60px; color:#000000; background-color:#ffffff;">
				<% for ( k = year_today - 3; k <= year_today + 1; k++ ) { %>
				<option value="<%=k%>" <% if ( f_year_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				년 &nbsp;&nbsp;&nbsp;
							
				<select  id="f_month_sel" name="f_month_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( k = 1; k <= 12; k++ ) { %>
				<option value="<%=k%>" <% if ( f_month_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				월 &nbsp;&nbsp;&nbsp;
					
				<select id="f_date_sel" name="f_date_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( k = 1; k <= 31; k++ ) { %>
				<option value="<%=k%>" <% if ( f_date_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				일 &nbsp;&nbsp;&nbsp;
				
				To:
				<select id="t_year_sel" name="t_year_sel" style="width: 60px; color:#000000; background-color:#ffffff;">
				<% for ( k = year_today - 20; k <= year_today + 1; k++ ) { %>
				<option value="<%=k%>" <% if ( t_year_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				년 &nbsp;&nbsp;&nbsp;
							
				<select id="t_month_sel" name="t_month_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( k = 1; k <= 12; k++ ) { %>
				<option value="<%=k%>" <% if ( t_month_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				월 &nbsp;&nbsp;&nbsp;
					
				<select  id="t_date_sel" name="t_date_sel" style="width: 40px; color:#000000; background-color:#ffffff;">
				<% for ( k = 1; k <= 31; k++ ) { %>
				<option value="<%=k%>" <% if ( t_date_sel == k  ) { %>selected<% } %>><%=k%></option>
				<% } %>
				</select>
				일 &nbsp;&nbsp;&nbsp;
			</td>
		    <input type="submit" value="검색하기" onclick="PleaseWait()"/>
			<right>작성자 연락처: esther@cewit.re.kr</right>
	</td> 
	</form>	
	<div id="map_canvas" style="position:relative;float:left;width:100%;height:100%;"></div>
	<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>
</body>
</html>
