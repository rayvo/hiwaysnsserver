<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
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
	<title>데이터베이스 초기화</title>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 

<body topmargin='20' leftmargin='20'>
<%
	out.println( "데이터베이스 Upgrade!<br><br>" );

	try
	{
		//DB 연결.
		db.db_open();
		
	
		/*
		 * 기존 테이블을 삭제하고, 신규로 테이블 생성.
		 */
		String	query;
		
		
		
		//(1) 운영자 테이블
		//(1-1) 테이블 troasis_admin_users : 운영자 계정 테이블
		try
		{
			query	= "DROP TABLE troasis_admin_users";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> troasis_admin_users." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE troasis_admin_users("; 
		query	= query + "  user_id					VARCHAR(258) NOT NULL PRIMARY KEY";	//사용자 ID.	
		query	= query + ", user_passwd				VARCHAR(258) DEFAULT ''";			//사용자 비밀번호.	
		query	= query + ", user_name					VARCHAR(258) DEFAULT ''";			//사용자 이름.	
		query	= query + ", mobile						VARCHAR(258) DEFAULT ''";			//휴대폰 연락처.	
		query	= query + ", role						INT DEFAULT 0";						//사용자 권한.
		query	= query + ", approved					INT DEFAULT 0";						//사용자 권한.

		//레코드 관리 정보.
		query	= query + ", flag_deleted				SMALLINT DEFAULT 0";		//튜플 삭제표시: 0=valid, 1=invalid(deleted).
		query	= query + ", time_inserted				BIGINT DEFAULT 0";			//튜플 생성시각.
		query	= query + ", time_last_updated			BIGINT DEFAULT 0";			//튜플의 최종 갱신시각.
		query	= query + ", time_deleted				BIGINT DEFAULT 0";			//튜플 삭제시각.
		query	= query + ", INDEX (user_id)";
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> troasis_admin_users." );

		
		//(1-2) 시스템 관리자 계정 등록.
		try
		{
			query	= "DELTE FROM troasis_admin_users WHERE user_id='admin'";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>시스템 관리자 계정 삭제." );
		}
		catch( Exception e ) { };

		query	= "INSERT INTO troasis_admin_users(user_id, user_passwd, user_name, role, approved, flag_deleted) VALUE('admin', '" + LoginManager.getMD5Str("exits2010") + "', '시스템관리자', 2, 1, 0)";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>시스템 관리자 계정 등록." );
		
		
		
		
		//트랜잭션 Commit.
		db.tran_commit();
		
		//완료 메시지.
		out.println( "<br>성공적으로 데이터베이스를 Upgrade 했습니다." );
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		
		//완료 메시지.
		out.println( "<br>데이터베이스를 Upgrade 하는 과정에서 오류가 발생 했습니다." );
		out.println( e.toString() );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
	<br><br>
	<a href="setup_db_main.jsp">돌아가기</a>
</body>
</html>