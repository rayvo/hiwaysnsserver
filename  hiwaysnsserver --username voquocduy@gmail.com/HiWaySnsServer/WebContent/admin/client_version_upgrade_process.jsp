<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<% LoginManager loginManager = LoginManager.getInstance(); %>


<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@	page import="java.util.Calendar"%>
<%@	page import="java.text.SimpleDateFormat"%>

<%
	if( loginManager.isLogin(session.getId()) == false 	//시스템 관리자가 로그인 중이 아니라면
		|| loginManager.mRole < 1 )
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>
<title>클라이언트 최신버전 업데이트</title>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer"scope="page" />
<jsp:setProperty name="db" property="*" />

<body topmargin='20' leftmargin='20'>


	<%
	request.setCharacterEncoding("utf-8");
	int version_code = 0;
	int is_Android = 0;

	String	version_name = request.getParameter("ver_name");
	String	deployed_date = request.getParameter("deployed_date");
	String	client_type = new String(request.getParameter("client_type").getBytes("ISO8859_1"),"GBK"); 
	int is_latest = 1;
	String	strQuery;
	String query_u="";
	String	strTableVer	= "client_version_info";

			//DB 연결.
			db.db_open();
			
			if (client_type.equals("Android"))
			{
				is_Android = 1;				
			}
			else
			{
				is_Android = 0; 
			}			
			String query_s="";			
			query_s = "SELECT ver_code";
			query_s =  query_s + " FROM " + strTableVer;
			query_s =  query_s + " WHERE is_latest = 1";
			query_s =  query_s + " AND is_Android = " + is_Android;				
			db.exec_query( query_s );			
			while( db.mDbRs.next() )
			{
				version_code = db.mDbRs.getInt( 1 ) + 1;
			}		
				
			query_u = "UPDATE " + strTableVer; 
			query_u =  query_u + " SET is_latest = 0 ";
			query_u =  query_u + " WHERE is_Android = " + is_Android;
			query_u =  query_u + " AND is_latest = 1";				
			db.exec_update( query_u );			
				
			
			if (deployed_date.equals(""))
			{
				Calendar cal = Calendar.getInstance();  
				String DATE_FORMAT_NOW = "yyyy-MM-dd";
				SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
				deployed_date = sdf.format(cal.getTime());
			}
			
					strQuery	= "INSERT";
					strQuery	= strQuery + " INTO " + strTableVer + "(";
					strQuery	= strQuery + " ver_code";
					strQuery	= strQuery + ", ver_name";
					strQuery	= strQuery + ", deployed_date";
					strQuery	= strQuery + ", is_Android";
					strQuery	= strQuery + ", is_latest)";
			
					strQuery	= strQuery + " VALUES(";
					strQuery	= strQuery +  version_code;
					strQuery	= strQuery + ", '"+ version_name + "'"; 
					strQuery	= strQuery + ", '"+ deployed_date + "'";
					strQuery	= strQuery + ", " + is_Android;
					strQuery	= strQuery + ", 1)";
		
					System.out.println(strQuery);
					db.exec_update( strQuery );
		
					//System.out.println( "you have updated all data in client_version_info table!!!" );
					db.tran_commit();

		response.sendRedirect("../admin/client_version_upgrade.jsp");
	
%>

</body>
</html>



