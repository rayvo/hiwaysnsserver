<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"%>

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

<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false )	//세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<%
	request.setCharacterEncoding("utf-8");

	int is_popup = 0;
	int is_valid =1;
	String created_date = "";
	int message_id = 0;
	
	String	title	 = request.getParameter("title");
	String	content = request.getParameter("content");
	int year = Integer.parseInt(request.getParameter("n_year_sel"));
	int month = Integer.parseInt(request.getParameter("n_month_sel"));
	int date = Integer.parseInt(request.getParameter("n_date_sel"));
	int hour = Integer.parseInt(request.getParameter("n_hour_sel"));
	String	popup = new String(request.getParameter("is_popup").getBytes("ISO8859_1"),"GBK");
	
	Calendar	calDate	= Calendar.getInstance();
	calDate.set (year, month, date, hour, 0, 0);

	long	expire_date	= calDate.getTimeInMillis() / 1000;

	
	Calendar cal = Calendar.getInstance();  
	String DATE_FORMAT_NOW = "yyyy-MM-dd HH:mm:ss";
	SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
	created_date = sdf.format(cal.getTime());
	
	if (popup.equals("yes"))
	{
		is_popup= 1;				
	}
	else
	{
		is_popup= 0;				
	}

	 
	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer	db = new HiWayDbServer( mServerListDB[i] );
		try {
			//DB 연결.
			db.db_open();

			String	strQuery;
			String	strTableNoticeMsgInfo	= "message";
	 		
			long	currentTime	= db.getCurrentTimestamp();
			
			String query1="";			
			query1 = "SELECT MAX(message_id)";
			query1 =  query1 + " FROM " + strTableNoticeMsgInfo;	
			db.exec_query( query1 );			
			while( db.mDbRs.next() )
			{
				message_id = db.mDbRs.getInt( 1 ) + 1;
			}
								
			//공지사항 메시지 입력.
	 		strQuery	= "INSERT";
			strQuery	= strQuery + " INTO " + strTableNoticeMsgInfo + "(";
			strQuery	= strQuery + " message_id";
			strQuery	= strQuery + ", title";
			strQuery	= strQuery + ", content";
			strQuery	= strQuery + ", created_date";
			strQuery	= strQuery + ", expire_date";
			strQuery	= strQuery + ", is_popup";	
			strQuery	= strQuery + ", is_valid";
			strQuery	= strQuery + ")";
			
			strQuery	= strQuery + " VALUES(";
			strQuery	= strQuery + message_id + "";
			strQuery	= strQuery + ", '" + title + "'";
			strQuery	= strQuery + ", '"  + content + "'";
			strQuery	= strQuery + ", '"+ created_date + "'";
			strQuery	= strQuery + ", " + expire_date;
			strQuery	= strQuery + ", " + is_popup;
			strQuery	= strQuery + ", " + is_valid;
			strQuery	= strQuery + ")";
			db.exec_update( strQuery );
			//트랜잭션 Commit.
			db.tran_commit();

		}
		catch( Exception e )
		{
			//트랜잭션 Rollback.
			db.tran_rollback();
			
			//오류 메시지 출력.
			System.out.println( e.toString() );
		}
		finally
		{
			//DB 연결 닫기.
			try
			{
				db.db_close();
			}
			catch( Exception e ) { }
			finally { }
		}
	}
	
	response.sendRedirect("admin_notification_msg.jsp");
%>
