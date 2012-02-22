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
	<title>VMS Agent 데이터 엑셀 파일 등록</title>
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
		 * VMS Agent 데이터 테이블.
		 */
		//(2) VMS 연계 테이블들
		//(2-1) 테이블 troasis_vms_data : VMS 교통정보 테이블
		try
		{
			query	= "DROP TABLE troasis_vms_data";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> troasis_vms_data." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE troasis_vms_data (";
		query	= query + "id				int(11) NOT NULL PRIMARY KEY auto_increment";
		query	= query + ", vms_id			varchar(12) NOT NULL";
		query	= query + ", vms_tp			varchar(2) default '0'";
		query	= query + ", road_name		varchar(258) default ''";
		query	= query + ", road_no		int(11) default '0'";
		query	= query + ", loc_lat		int(11) default '0'";
		query	= query + ", loc_lng		int(11) default '0'";
		query	= query + ", time_log		bigint(20) default '0'";
		query	= query + ", vms_cnt		int(11) default '0'";
		query	= query + ", vms_data		varchar(1000) default ''";
		query	= query + ", vms_updown		varchar(300) default ''";
		query	= query + ", reserved1		varchar(200) default ''";
		query	= query + ", reserved2		varchar(200) default ''";
		query	= query + ") ENGINE=MyISAM AUTO_INCREMENT=565 DEFAULT CHARSET=utf8;";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성  --> troasis_vms_data." );

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
	String[]	list_file_names	= { "VMS_node_data.xls" };

	//Excel 파일들이 위치하는 폴더 경로명
	String	file_path	= "";
	String	query		= "";

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
			if ( list_file_names[key] == "VMS_node_data.xls" )		query = "DELETE FROM troasis_vms_data";
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
			if ( list_file_names[key] == "VMS_node_data.xls" )
				query = "INSERT INTO troasis_vms_data(vms_id, vms_tp, road_name, road_no, loc_lng, loc_lat, vms_cnt, vms_data, vms_updown, reserved2) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			
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

					if ( list_file_names[key] == "VMS_node_data.xls" )
					{
						switch( j )
						{
						case 0	:	//Agent ID
						 	//out.println( "<br>cell_value=" + cell_value);
							break;
						case 3	:	//도로번호.
							if ( cell_value.length() < 1 )	cell_value = "0";
							break;
						case 4	:	//위경도 좌표.
						case 5	:
						 	//out.println( "<br>cell_value=" + cell_value);
						 	//cell_value	= String.valueOf( (int)(Double.parseDouble(cell_value) * 1000000.0) );
						 	cell_value	= String.valueOf( (int)(Double.parseDouble(cell_value)) );
						 	//out.println( "<br>cell_value=" + cell_value);
							break;
						case 6	:	//Count.
							if ( cell_value.length() < 1 )	cell_value = "0";
							break;
						case 7	:	//교통정보.
							if ( cell_value.compareToIgnoreCase("VMS_INFO") == 0 )	cell_value = "";
							break;
						case 8	:	//상하행.
							if ( cell_value.compareToIgnoreCase("VMS_DIRECTION_UNDEFINED") == 0 )	cell_value = "";
							break;
						default	:
							break;
						}
						//out.println( "<br>[" + j + "] 2.cell_value=" + cell_value + "," + cell_value.length() );
					}

					db_pstmt.setString( j + 1, cell_value );				//sql문장의 물음표 j번째 - A cell : 0번 cell
				}
				count	+= db_pstmt.executeUpdate();
			}

		//(3) 데이터 업테이트.
		query	= "update troasis_vms_data set vms_tp='1'";
		out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>VMS 보정 --> VMS 정보유형 업데이트." );
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