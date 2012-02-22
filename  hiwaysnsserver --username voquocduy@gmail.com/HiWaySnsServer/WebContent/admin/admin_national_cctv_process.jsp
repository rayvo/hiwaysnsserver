<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"%>
<%@	page	import ="kr.co.ex.hiwaysns.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
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

	String	cctv_id		= request.getParameter("cctv_id");
	String	cctv_url	= request.getParameter("cctv_url");
	String	xcoord		= request.getParameter("x_coord");
	int		loc_lat		= Integer.parseInt(xcoord);
	String	ycoord		= request.getParameter("y_coord");
	int		loc_lng		= Integer.parseInt(ycoord);
	int	road_no		= Integer.parseInt(request.getParameter("road_no"));
	String	cctv_loc	= request.getParameter("location");
	String	address		= request.getParameter("address");
	
	int changed_type =1;
	int changed_number=1;
	String updated_time="";
	
	Calendar cal = Calendar.getInstance();  
	String DATE_FORMAT_NOW = "yyyy-MM-dd";
	SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
	updated_time = sdf.format(cal.getTime());
	
	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer	db = new HiWayDbServer( mServerListDB[i] );
		try {
			//DB 연결.
			db.db_open();

			String	strQuery;
			String	strTableNatioanlCCTV	= "national_cctv_info";
			String	strTableCCTVmodificationLog	= "cctv_modification_log";

	 		long	currentTime	= db.getCurrentTimestamp();

			//CCTV 등록.
			strQuery	= "INSERT";
			strQuery	= strQuery + " INTO " + strTableNatioanlCCTV + "(";
			strQuery	= strQuery + " cctv_id";
			strQuery	= strQuery + ", road_no";
			strQuery	= strQuery + ", cctv_loc";
			strQuery	= strQuery + ", cctv_lng";
			strQuery	= strQuery + ", cctv_lat";
			strQuery	= strQuery + ", cctv_url";
			strQuery	= strQuery + ", cctv_address)";

			strQuery	= strQuery + " VALUES(";
			strQuery	= strQuery + "'" + cctv_id + "'";
			strQuery	= strQuery + ",  " + road_no ;
			strQuery	= strQuery + ", '" + cctv_loc + "'";
			strQuery	= strQuery + ", " + loc_lat ;
			strQuery	= strQuery + ", " + loc_lng ;
			strQuery	= strQuery + ", '" + cctv_url + "'";
			strQuery	= strQuery + ", '" + address + "'";
			strQuery	= strQuery + ")";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_update( strQuery );

			strQuery	= "SELECT MAX(changed_number)";
			strQuery	= strQuery + " FROM " + strTableCCTVmodificationLog;
			db.exec_query( strQuery );
			
			if(db.mDbRs.next())
			{
				changed_number= db.mDbRs.getInt(1)+1;
			}
			
			strQuery	= "INSERT";
			strQuery	= strQuery + " INTO " + strTableCCTVmodificationLog + "(";
			strQuery	= strQuery + " cctv_id";
			strQuery	= strQuery + ", changed_number";
			strQuery	= strQuery + ", changed_type";
			strQuery	= strQuery + ", updated_time)";


			strQuery	= strQuery + " VALUES(";
			strQuery	= strQuery + "'" + cctv_id + "'";
			strQuery	= strQuery + ",  " + changed_number ;
			strQuery	= strQuery + ", " + changed_type ;
			strQuery	= strQuery + ", '" + updated_time + "'";
			strQuery	= strQuery + ")";
			//System.out.println( "strQuery=" + strQuery );
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
	response.sendRedirect("admin_national_cctv.jsp");
%>
