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

	String	userID		= request.getParameter("userID");
	String	userName	= request.getParameter("userName");
	String	xcoord		= request.getParameter("x_coord");
	int		nPosLng		= Integer.parseInt(xcoord);
	String	ycoord		= request.getParameter("y_coord");
	int		nPosLat		= Integer.parseInt(ycoord);
	String	userMsg		= request.getParameter("userMsg");
	 
	for ( int i = 0; i < mServerListDB.length; i++ )
	{
		HiWayDbServer	db = new HiWayDbServer( mServerListDB[i] );
		try {
			//DB 연결.
			db.db_open();

			String	strQuery;
			String	strTableUserMsg	= "troasis_user_msg";

			int		strActiveID		= -1;
			String	strUserID		= userID;
			String	strTmpKey		= "";
			int		nParentID		= 0;
			int		paren_log_id	= 0;
			String	paren_user_id	= "";
	 		long	currentTime	= db.getCurrentTimestamp();

			//사용자의 메시지 등록.
			strQuery	= "INSERT";
			strQuery	= strQuery + " INTO " + strTableUserMsg + "(";
			strQuery	= strQuery + " type_level_1";
			strQuery	= strQuery + ", type_level_2";
			strQuery	= strQuery + ", type_level_3";
			strQuery	= strQuery + ", time_log";
			strQuery	= strQuery + ", loc_lat";
			strQuery	= strQuery + ", loc_lng";
			strQuery	= strQuery + ", log_id";
			strQuery	= strQuery + ", user_id";
			strQuery	= strQuery + ", nickname";
			strQuery	= strQuery + ", parent_id";
			strQuery	= strQuery + ", parent_log_id";
			strQuery	= strQuery + ", parent_user_id";
			strQuery	= strQuery + ", subject";
			strQuery	= strQuery + ", contents";
			strQuery	= strQuery + ", type_etc";
			strQuery	= strQuery + ", link_etc";
			strQuery	= strQuery + ", size_etc";
			strQuery	= strQuery + ", tmp_key";
			strQuery	= strQuery + ", flag_deleted";
			strQuery	= strQuery + ", time_inserted";
			strQuery	= strQuery + ", time_last_updated";
			strQuery	= strQuery + ", time_deleted)";

			strQuery	= strQuery + " VALUES(";
			strQuery	= strQuery + "" + TrOasisConstants.TYPE_1_USER + "";
			strQuery	= strQuery + "," + TrOasisConstants.TYPE_2_USER_SNS + "";
			strQuery	= strQuery + ", 0";
			strQuery	= strQuery + ", '" + currentTime + "'";
			strQuery	= strQuery + ", " + nPosLat + "";
			strQuery	= strQuery + ", " + nPosLng + "";
			strQuery	= strQuery + ", " + strActiveID + "";
			strQuery	= strQuery + ",  '" + strUserID + "'";
			strQuery	= strQuery + ", '" + userName + "'";
			strQuery	= strQuery + ", " + nParentID + "";
			strQuery	= strQuery + ", " + paren_log_id + "";
			strQuery	= strQuery + ", '" + paren_user_id + "'";
			strQuery	= strQuery + ", ''";
			strQuery	= strQuery + ", '" + userMsg + "'";
			strQuery	= strQuery + ", " + TrOasisConstants.TYPE_ETC_NONE + "";
			strQuery	= strQuery + ", ''";
			strQuery	= strQuery + ", 0";
			strQuery	= strQuery + ", '" + strTmpKey + "'";
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
	response.sendRedirect("admin_user_msg.jsp");
%>
