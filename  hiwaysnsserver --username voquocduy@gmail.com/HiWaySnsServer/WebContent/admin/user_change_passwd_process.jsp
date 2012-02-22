<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"  %>
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
	 
	String	userID			= loginManager.getUserID( session.getId() );
	String	userPW			= request.getParameter("user_passwd");
	userPW	= LoginManager.getMD5Str(userPW);
	//System.out.println( "user_id=" + userID + ", user_passwd=" + userPW);

	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer		db	= new HiWayDbServer( mServerListDB[i] );		
		try
		{
			//DB 연결.
			db.db_open();
	 		long	currentTime	= db.getCurrentTimestamp();
	
			//트랜잭션 시작.
			db.tran_begin();
			
			//사용자 등록.
			String	strQuery;
			String	strTableUsers	= "troasis_admin_users";
	
			strQuery	= "UPDATE";
			strQuery	= strQuery + " " + strTableUsers + " SET";
			strQuery	= strQuery + " user_passwd = '" + userPW + "'";
			strQuery	= strQuery + " WHERE user_id = '" + userID + "'";
			strQuery	= strQuery + " AND flag_deleted = 0";
	
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

	response.sendRedirect("../admin/index.jsp");
%>
