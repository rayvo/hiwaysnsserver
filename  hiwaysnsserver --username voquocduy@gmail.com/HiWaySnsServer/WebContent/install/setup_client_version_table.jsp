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
	<title>클라이언트 버전 관리 테이블 생성</title>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"	%>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 

<%

try
{
	//DB 연결.
	db.db_open();

	//트랜잭션 시작.
	db.tran_begin();
			
	/*
	 * 기존 테이블을 삭제하고, 신규로 테이블 생성.
	 */
	String	query;
	
		try
		{
			query	= "DROP TABLE client_version_info";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> client_version_info." );
		}
		catch( Exception e ) { };


		query	= "CREATE TABLE client_version_info(";
		query	= query + "ID			int(11) NOT NULL PRIMARY KEY auto_increment";
		query	= query + ", ver_code			INTEGER DEFAULT 0";			//버전 코드
		query	= query + ", ver_name			VARCHAR(14) DEFAULT ''";		//버전이름
		query	= query + ", deployed_date		VARCHAR(14) DEFAULT ''";	//버전 실시 시간
		query	= query + ", is_Android			SMALLINT DEFAULT 0";				//안드로이드 여부 체크
		query	= query + ", is_latest			SMALLINT DEFAULT 0";
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> client_version_info." );
		
				
		//트랜잭션 Commit.
		db.tran_commit();

		//완료 메시지.
		out.println( "<br><br>성공적으로 클라이언트 버전 관리 테이블 생성했습니다." );
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();

		//완료 메시지.
		out.println( "<br><br> 클라이언트 버전 관리 테이블 생성 과정에서 오류가 발생 했습니다.<br><br>" );
		out.println( e.toString() );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
