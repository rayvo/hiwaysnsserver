<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"%>
<%@	page	import ="kr.co.ex.hiwaysns.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
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

	String	vms_id	 = request.getParameter("vms_id");
	String	vms_data = request.getParameter("vms_data");

	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer	db = new HiWayDbServer( mServerListDB[i] );
		try {
			String	strQuery;
			String	strTableUserMsg	= "troasis_vms_data";

	 		long	currentTime	= db.getCurrentTimestamp();

			//VMS 관리자의 메시지 갱신.
				strQuery	= "UPDATE";
				strQuery	= strQuery + " " + strTableUserMsg + " SET";
				strQuery	= strQuery + " vms_tp = '2'";
				strQuery	= strQuery + ", time_log = " + currentTime + "";
				strQuery	= strQuery + ", vms_cnt = '1'";
				strQuery	= strQuery + ", vms_data = '" + vms_data + "'";
				strQuery	= strQuery + ", time_last_updated = " + currentTime;
				strQuery	= strQuery + " WHERE vms_id = '" + vms_id + "'";
				System.out.println( "strQuery=" + strQuery );
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
	response.sendRedirect("admin_vms_msg.jsp");
%>
