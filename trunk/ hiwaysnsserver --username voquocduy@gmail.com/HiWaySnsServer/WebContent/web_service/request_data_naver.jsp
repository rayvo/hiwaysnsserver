<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@ page import="java.text.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%

	/*
	 * FTMS Agent 정보 목록 제공....
	 */

	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	
	//오늘 날짜 구하기.
	Calendar	ctoday	= Calendar.getInstance();
	int		n_year_today	= ctoday.get(Calendar.YEAR);
	int		n_month_today	= ctoday.get(Calendar.MONTH);
	int		n_date_today	= ctoday.get(Calendar.DATE);
	int		n_hour_today	= ctoday.get(Calendar.HOUR_OF_DAY);
	
	

	//입력인자 수신.
	int		n_year_sel = 0, n_month_sel = 0, n_date_sel = 0;
	int		n_hour_sel	= 0;

	if ( request.getParameter("n_year_sel") != null )
		n_year_sel	= Integer.parseInt( request.getParameter("n_year_sel") );
	if ( request.getParameter("n_month_sel") != null )
		n_month_sel	= Integer.parseInt( request.getParameter("n_month_sel") );
	if ( request.getParameter("n_date_sel") != null )
		n_date_sel	= Integer.parseInt( request.getParameter("n_date_sel") );
	if ( request.getParameter("n_hour_sel") != null )
		n_hour_sel	= Integer.parseInt( request.getParameter("n_hour_sel") );

	//입력이 없는 경우, 오늘 날짜.
	if ( n_year_sel < 1 || n_month_sel < 1 )
	{
		n_year_sel	= n_year_today;
		n_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	}
	if ( n_date_sel < 1 )	n_date_sel = n_date_today;
	if ( n_hour_sel < 1 )	n_hour_sel = n_hour_today;

	//숫자 형식. 
	NumberFormat	nf	= NumberFormat.getNumberInstance();
	
	//통계 데이터.
	int			nSizeStatistics	= 60;
	int			nCountDB		= 10;
	
	//시간대별 날짜 정보 구하기.
	Calendar	calDate	= Calendar.getInstance();
	calDate.set(n_year_sel, n_month_sel - 1, n_date_sel, n_hour_sel, 0, 0);

	long	nTimeInSecToday		= 0;
	//calDate.add( Calendar.MINUTE, 1 );
	long	nTimeInSecTomorrow	= calDate.getTimeInMillis() / 1000;
	
	
	//입력정보 수신.
	int		count		= 0;
	int		page_no		= 1;
	int		page_size	= 20;
	
	String	strParam	= "";
	strParam	= param.get_input_param( request.getParameter("page_no") );
	if ( strParam.length() > 0 )	page_no = Integer.parseInt(strParam);
	strParam	= param.get_input_param( request.getParameter("page_size") );
	if ( strParam.length() > 0 )	page_size = Integer.parseInt(strParam);
	
	try

	{

		String	strInputXml	= param.get_input_param( request.getParameter("xml") );
		//Request 메시지 필드목록.
		
		String[][]	inputList	=	{
										{ "user_name", "" },
										{ "key", "" },
										{ "year", "" },
										{ "month", "" },
										{ "date", "" },
										{ "hour", "" },
									};

		int		INDEX_USER_NAME		= 0;
		int		INDEX_KEY		= INDEX_USER_NAME + 1;
		int     INDEX_YEAR		= INDEX_KEY + 1;
		int 	INDEX_MONTH		= INDEX_YEAR + 1;
		int 	INDEX_DATE      = INDEX_MONTH + 1;
		int 	INDEX_HOUR		= INDEX_DATE + 1;


		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		/*
		 * 예외조건 검사.
		 */
		//FTMS 교통정보.

		int		count_log	= 0;

		List<String>	list_time_inserted		= new ArrayList<String>();		
		List<String>	list_time_log			= new ArrayList<String>();
	 	List<Integer>	list_loc_lat			= new ArrayList<Integer>();
	 	List<Integer>	list_loc_lng			= new ArrayList<Integer>();
		List<Integer>	list_speed          	= new ArrayList<Integer>();
		List<String>	list_user_id     		= new ArrayList<String>();

		//if ( db.isValidUser(strActiveID, strUserID, nPosLat, nPosLng) == false )
		//if ( db.isValidActiveID(strUserID, strActiveID) == false )
		//{
		//	status_code	= db.status_code;
		//	status_msg	= db.status_msg;
		//}
		//else
		
		//{

			db.db_open();

			String	strQuery;
			String	strTableTroasisLog	= "troasis_log";
			
			strQuery = "SELECT user_id, time_log, loc_lat, loc_lng, speed, time_inserted ";
			strQuery = strQuery + " FROM " + strTableTroasisLog;
//			strQuery = strQuery + " WHERE cctv_id = " + changed_cctv_id ;
			strQuery = strQuery + " WHERE nickname = 'a'" ;

			db.exec_query( strQuery );
			
			while ( db.mDbRs.next() )
			{	
				if (count_log>8) break;
				
				String user_id = "";
				int loc_lat = 0;
				int loc_lng =0;
				int speed = 0;
				String time_inserted="";
				String time_log="";
				
				
				user_id			= db.mDbRs.getString( "user_id");
				loc_lat			= db.mDbRs.getInt( "loc_lat" );
				loc_lng			= db.mDbRs.getInt( "loc_lng" );
				speed	    	=  db.mDbRs.getInt( "speed") ;
				time_inserted	= db.getTimestampString ( db.mDbRs.getLong( "time_inserted"));
				time_log		= db.getTimestampString ( db.mDbRs.getLong( "time_log" ));
		
				
				list_user_id.add( user_id );
				list_speed.add( speed );
				list_loc_lng.add( loc_lng );
				list_loc_lat.add( loc_lat );
				list_time_inserted.add( time_inserted );
				list_time_log.add( time_log );
				
				count_log ++;
			}

		//System.out.println( "count_agents=" + count_agents );
		//String[][]	outputList	=	{
		//								{ "active_id", strActiveID }
		//							};
		//}
			if ( status_code != 0 )	System.out.println( status_msg );

%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<troasis_log_list>
<%
	for ( int i = 0; i < count_log; i++ )
	{
%>
		<troasis_log>
		<time_inserted><%=list_time_inserted.get(i)%></time_inserted>
		<time_log><%=list_time_log.get(i)%></time_log> 
		<user_id><%=list_user_id.get(i)%></user_id>
		<speed><%=list_speed.get(i)%></speed> 
		<loc_lng><%=list_loc_lng.get(i)%></loc_lng> 
		<loc_lat><%=list_loc_lat.get(i)%></loc_lat> 
		</troasis_log>
<%
	}
%>
	</troasis_log_list>
</troasis>
<%
		//트랜잭션 Commit.
		db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		//오류 메시지 출력.
		status_msg	= e.toString();
		System.out.println( "[TROASIS LOG LIST]" + status_msg );
%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
</troasis>

<%
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>