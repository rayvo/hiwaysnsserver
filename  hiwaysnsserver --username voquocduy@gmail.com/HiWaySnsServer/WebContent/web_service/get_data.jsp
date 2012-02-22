<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
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
<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />


<%

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


	n_year_sel	= n_year_today;
	n_month_sel	= ctoday.get(Calendar.MONTH) + 1;
	n_date_sel = n_date_today;
	n_hour_sel = n_hour_today;

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
	
	List<String>	list_time_inserted	    = new ArrayList<String>();
	List<String>    list_time_log           = new ArrayList<String>();
 	List<Integer>	list_loc_lat	        = new ArrayList<Integer>();
 	List<Integer>	list_loc_lng	     	= new ArrayList<Integer>();
	List<String>	list_user_id            = new ArrayList<String>();
 	List<Integer>	list_speed  	        = new ArrayList<Integer>();

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
			
		int log_count=0;
		
		for ( int i = 0; i < nSizeStatistics; i++ )
		{
			calDate.add( Calendar.MINUTE, -1 );
			nTimeInSecToday	= calDate.getTimeInMillis() / 1000;
			
			//DB 연결.
			db.db_open();

			//데이터베이스에서 사용자 로그 목록의 개수 읽어오기.
			String	query;
			query	= "SELECT COUNT(*) FROM troasis_log";

			db.exec_query( query );

			if( db.mDbRs.next() )	count = db.mDbRs.getInt( 1 );

			//데이터베이스에서사용자 로그 목록을 읽어와서 출력한다.
			query	= "SELECT * FROM troasis_log";
			query	= query + " WHERE time_log >= " + nTimeInSecToday;		
			query	= query + " AND time_log < " + nTimeInSecTomorrow;
			query	= query + " ORDER BY time_log DESC, id DESC ";
		
			//이전 페이지 내용 Skip!
			int		index_start	= page_size * (page_no - 1);
			query	= query + "  LIMIT " + index_start + ", " + page_size;
			db.exec_query( query );
			
			for ( int k = 0; k < page_size && db.mDbRs.next(); k++ )		
			{
				int		no	= count - index_start - k;
				
				list_user_id.add( db.mDbRs.getString( "user_id" ) );
				list_time_log.add( db.mDbRs.getString( "time_log" ) );
				list_time_inserted.add( db.mDbRs.getString( "time_inserted" ) );
				list_loc_lat.add( db.mDbRs.getInt( "loc_lat" ) );
				list_loc_lng.add( db.mDbRs.getInt( "loc_lng" ) );				
				list_speed.add( db.mDbRs.getInt( "speed" ) );
				
				log_count++;
			}
			System.out.println( "count = " + log_count );
		
%>



<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	</troasis_log>
<%
	for ( int j = 0; j < log_count; j++ )
	{
%>
		<troasis_log>
		<time_inserted><%=list_time_inserted.get(i)%></time_inserted>
		<time_log><%=list_time_log.get(i)%></time_log> 
		<user_id><%=list_user_id.get(i)%></user_id>
		<speed><%=list_speed.get(i)%></speed> 
		<loc_lng><%=list_loc_lng.get(i)%></loc_lng> 
		<loc_lat><%=list_loc_lat.get(i)%></loc_lat> 
<%
	}
%>
	</troasis_log>
</troasis>
<%
		}
		//트랜잭션 Commit.
		db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		
		//오류 메시지 출력.
		status_msg	= e.toString();
		System.out.println( "[VMS INFO LIST]" + status_msg );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>

