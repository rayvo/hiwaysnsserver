<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 
<%
	//request.setCharacterEncoding( "utf-8" );
	String	strName	= request.getParameter( "xml" );
	try
	{
		//DB 연결.
		db.db_open();

		System.out.println( "1." + strName );
		strName	= new String( strName.getBytes("8859_1"), "utf-8" );
		System.out.println( "2." + strName );
		
		//사용자의 메시지 등록.
		long	currentTime	= System.currentTimeMillis() / 1000;
	
		String	strQuery;
		String	strTableUserMsg	= "troasis_user_msg";
			
		strQuery	= "INSERT";
		strQuery	= strQuery + " INTO " + strTableUserMsg + "(";
		strQuery	= strQuery + " type_level_1";
		strQuery	= strQuery + ", type_level_2";
		strQuery	= strQuery + ", type_level_3";
		strQuery	= strQuery + ", time_log";
		strQuery	= strQuery + ", log_id";
		strQuery	= strQuery + ", loc_lat";
		strQuery	= strQuery + ", loc_lng";
		strQuery	= strQuery + ", speed";
		strQuery	= strQuery + ", subject";
		strQuery	= strQuery + ", contents";
		strQuery	= strQuery + ", type_etc";
		strQuery	= strQuery + ", link_etc";
		strQuery	= strQuery + ", flag_deleted";
		strQuery	= strQuery + ", time_inserted";
		strQuery	= strQuery + ", time_last_updated";
		strQuery	= strQuery + ", time_deleted)";

		strQuery	= strQuery + " VALUES(";
		strQuery	= strQuery + "  0";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", 1";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", ''";
		strQuery	= strQuery + ", '" + strName + "'";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", ''";
		strQuery	= strQuery + ", 0";
		strQuery	= strQuery + ", " + currentTime;
		strQuery	= strQuery + ", " + currentTime;
		strQuery	= strQuery + ", 0)";

		db.exec_update( strQuery );		
	}
	catch(Exception e)
	{
		System.out.println( "<br><br>" + e.toString() + "<br><br>" );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
<?xml version="1.0" encoding="UTF-8"?>
<hi_way_services>
	<name_answer>안녕하세요.</name_answer>
	<name_answer><%=strName %></name_answer>
</hi_way_services>
