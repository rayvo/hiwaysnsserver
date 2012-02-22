<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/list_server_db.jsp"  %>
<%@	page	import ="kr.co.ex.hiwaysns.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<%
	request.setCharacterEncoding("utf-8");
	 
	String	userID			= request.getParameter("user_id");
	String	userPW			= request.getParameter("user_passwd");
	userPW	= LoginManager.getMD5Str(userPW);
	String	userName		= request.getParameter("user_name");
	String	userContact		= request.getParameter("user_contact");
	int		userRole		= Integer.parseInt( request.getParameter("user_role") );
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
	
			strQuery	= "INSERT";
			strQuery	= strQuery + " INTO " + strTableUsers + "(";
			strQuery	= strQuery + " user_id";
			strQuery	= strQuery + ", user_passwd";
			strQuery	= strQuery + ", user_name";
			strQuery	= strQuery + ", mobile";
			strQuery	= strQuery + ", role";
			strQuery	= strQuery + ", flag_deleted";
			strQuery	= strQuery + ", time_inserted";
			strQuery	= strQuery + ", time_last_updated";
			strQuery	= strQuery + ", time_deleted)";
	
			strQuery	= strQuery + " VALUES(";
			strQuery	= strQuery + "  '" + userID + "'";
			strQuery	= strQuery + ", '" + userPW + "'";
			strQuery	= strQuery + ", '" + userName + "'";
			strQuery	= strQuery + ", '" + userContact + "'";
			strQuery	= strQuery + ", " + userRole + "";
			strQuery	= strQuery + ", 0";
			strQuery	= strQuery + ", " + currentTime;
			strQuery	= strQuery + ", " + currentTime;
			strQuery	= strQuery + ", 0)";
	
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
