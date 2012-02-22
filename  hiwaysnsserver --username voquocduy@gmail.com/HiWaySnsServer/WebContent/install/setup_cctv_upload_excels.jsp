<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
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
	<title>CCTV 데이터 엑셀 파일 등록</title>
	<meta http-equiv= "Content-Type" content="text/html; charset=utf-8">
</head>

<%@ page import	= "java.net.*" %>
<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.util.Date" %>
<%@ page import = "jxl.*" %>
<%@ page import = "jxl.write.*" %>
<%@ page import = "jxl.format.*" %>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 

<% request.setCharacterEncoding( "utf-8" ); %>
<body topmargin='20' leftmargin='20'>
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

		
		
		/*
		 * CCTV 데이터 테이블.
		 */
		//(2-1) 테이블 troasis_cctv_node : CCTV Node 테이블
		try
		{
			query	= "DROP TABLE troasis_cctv_node";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> troasis_cctv_node." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE troasis_cctv_node("; 
		query	= query + "id					INT NOT NULL PRIMARY KEY AUTO_INCREMENT";
		query	= query + ", cctv_id			BIGINT DEFAULT 0";			//CCTV Unique id.
		query	= query + ", road_no			INT DEFAULT 0";				//도로 번호.
		query	= query + ", road_name			VARCHAR(258) DEFAULT ''";	//도로 이름.
		query	= query + ", loc_lng			INT DEFAULT 0";				//노드의 경도 좌표 (WGS84)
		query	= query + ", loc_lat			INT DEFAULT 0";				//노드의 위도 좌표 (WGS84)
		query	= query + ", url_iphone			VARCHAR(1024) DEFAULT ''";	//iPhone용 URL.	
		query	= query + ", url_android		VARCHAR(1024) DEFAULT ''";	//Android용 URL.	
		query	= query + ", remark				VARCHAR(512) DEFAULT ''";	//비고.	
		
		query	= query + ", flag_deleted		SMALLINT DEFAULT 0";		//튜플 삭제표시: 0=valid, 1=invalid(deleted).
		query	= query + ", time_inserted		BIGINT DEFAULT 0";			//튜플 생성시각.
		query	= query + ", time_last_updated	BIGINT DEFAULT 0";			//튜플의 최종 갱신시각.
		query	= query + ", time_deleted		BIGINT DEFAULT 0";			//튜플 삭제시각.
		query	= query + ", INDEX (cctv_id)";
		query	= query + ", INDEX (road_no)";
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> troasis_cctv_node." );

		 
		//트랜잭션 Commit.
		db.tran_commit();

		
		
		//완료 메시지.
		out.println( "<br><br>성공적으로 데이터베이스를 초기화 했습니다." );
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();

		//완료 메시지.
		out.println( "<br><br>데이터베이스를 초기화 하는 과정에서 오류가 발생 했습니다." );
		out.println( e.toString() );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}











	//등록할 Excel 파일 목록.
	String[]	list_file_names	= { "cctv_data.xls" };

	//Excel 파일들이 위치하는 폴더 경로명
	String	file_path	= "";
	String	query	= "";

	//Excel 파일 등록.
	PreparedStatement	db_pstmt	= null;
	for ( int key = 0; key < list_file_names.length; key++ )
	{
		/*
		 * 기존의 테이블 자료 삭제.
		 */
		try
		{
			//DB 연결.
			db.db_open();

			//기존 자료 삭제.
			query	= "";
			if ( list_file_names[key] == "cctv_data.xls" )		query = "DELETE FROM troasis_cctv_node";
			db.exec_update( query );

			//Commit the transaction.
			db.tran_commit();
			out.println( "<br><br>" + "DELETE Table " + list_file_names[key] );
		}
		catch( Exception ex )
		{
			out.println( "<br><br>" + "ERROR-DELETE[" + (key + 1) + "] " + ex.getMessage() );
			db.tran_rollback();			//Rollback the transaction.
			db.db_close();				//DB 연결 해제.
			return;
		}
		finally
		{
			//DB 연결 해제.
			db.db_close();
		}

		
		/*
		 * Excel 파일의 내용을 DB 테이블에 등록.
		 */
		try
		{
			file_path	= path_folder + list_file_names[key];
			query		= "";
			if ( list_file_names[key] == "cctv_data.xls" )
				query = "INSERT INTO troasis_cctv_node(cctv_id, road_no, road_name, loc_lng, loc_lat, url_iphone, url_android, remark, flag_deleted) VALUES(?, ?, ?, ?, ?, ?, ?, ?, 0)";
			
			//DB 연결.
			db.db_open();
			db_pstmt	= db.mDbConnection.prepareStatement( query );

			String		cell_value;
			int			count		= 0;
			System.out.println( "file_path=" + file_path );
			Workbook	workbook	= Workbook.getWorkbook( new File(file_path) );
			Sheet		sheet		= workbook.getSheet( 0 );				//첫번째 쉬트
			System.out.println( "sheet.getColumns()=" + sheet.getColumns() );
			System.out.println( "sheet.getRows()=" + sheet.getRows() );
			for ( int i = 0; i < sheet.getRows(); i++ )						//엑셀의 row 번호 (1번 row 부터 ~ n번째 row 까지). 첫 row 가 0번이다
			{
				db_pstmt.clearParameters();
				db_pstmt.setInt( 1, i );									//레코드 ID.
				for ( int j = 0; j < sheet.getColumns(); j++ )
				{
					cell_value	= sheet.getCell(j, i).getContents();
					//out.println( "<br>[" + i + "] cell_value=" + cell_value + "," + cell_value.length() );
					if ( cell_value.equalsIgnoreCase("null")
							|| cell_value.length() < 1
							|| cell_value.equalsIgnoreCase("-") )	cell_value = "";
					//out.println( "<br>[" + i + "] cell_value=" + cell_value + "," + cell_value.length() );
					cell_value	= URLDecoder.decode( cell_value, "utf-8" );
					//out.println( "<br>[" + i + "] cell_value=" + cell_value + "," + cell_value.length() );

					if ( list_file_names[key] == "cctv_data.xls" )
					{
						switch( j )
						{
						case 0	:
						 	//out.println( "<br>cell_value=" + cell_value);
							break;
						case 1	:	//Road no.
							if ( cell_value.length() < 1 )	cell_value = "0";
							break;
						case 3	:	//위경도 좌표.
						case 4	:
						 	//out.println( "<br>cell_value=" + cell_value);
						 	//cell_value	= String.valueOf( (int)(Double.parseDouble(cell_value) * 1000000.0) );
						 	cell_value	= String.valueOf( (int)(Double.parseDouble(cell_value)) );
						 	//out.println( "<br>cell_value=" + cell_value);
							break;
						default	:
							break;
						}
					}

					db_pstmt.setString( j + 1, cell_value );				//sql문장의 물음표 j번째 - A cell : 0번 cell
				}
				count	+= db_pstmt.executeUpdate();
			}
%>
	<br/>성공[<%=(key + 1) %>] 파일 <%=list_file_names[key] %> - <%=count%> 개의 항목 등록.<br>
<%
			//Commit the transaction.
			db.tran_commit();
		}
		catch( Exception ex )
		{
			out.println( "<br><br>" + "ERROR-INSERT[" + (key + 1) + "] " + ex.getMessage() );
			db.tran_rollback();			//Rollback the transaction.
			if ( db_pstmt != null )	try { db_pstmt.close(); } catch(SQLException ex2) { };
			db_pstmt	= null;
			db.db_close();				//DB 연결 해제.
			return;
		}
		finally
		{
			if ( db_pstmt != null )	try { db_pstmt.close(); } catch(SQLException ex) { };
			db_pstmt	= null;

			//DB 연결 해제.
			db.db_close();
		}
	}
%>
	<br><br>
	<a href="setup_db_main.jsp">돌아가기</a>
</body>
</html>