<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer"
	scope="page" />
<jsp:useBean id="param"
	class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc"
	scope="page" />

<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>

<%
	int status_code = 0; //작업처리결과 코드
	String status_msg = ""; //작업처리결과 메시지.
	try {

		//		System.out.println( "[USER MSG NEW] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String strInputXml = param.get_input_param(request
				.getParameter("xml"));

		//Request 수신.
		String[][] inputList = { { "client_type", "" }, };
		int INDEX_CLIENT_TYPE = 0;

		//Request 메시지 파싱.
		//System.out.println("xml=" + strInputXml);
		inputList = xmlGen.parseInputXML(strInputXml, inputList);
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		db.db_open();

		String strQuery;
		String strTableVer = "client_version_info";

		String client_type = inputList[INDEX_CLIENT_TYPE][1];
		boolean flag = true;
		
		//System.out.println( "client_type=" + client_type );
		if (inputList[INDEX_CLIENT_TYPE][1].equals("Android")
				|| inputList[INDEX_CLIENT_TYPE][1].equals("android")) {
			//Android 사용자
			strQuery = "SELECT ver_code, ver_name";
			strQuery = strQuery + " FROM " + strTableVer;
			strQuery = strQuery + " WHERE is_latest = 1";
			strQuery = strQuery + " AND is_Android = 1"; // Android

			//System.out.println( "strQuery=" + strQuery );
			db.exec_query(strQuery);
		} else if (inputList[INDEX_CLIENT_TYPE][1].equals("iphone")
				|| inputList[INDEX_CLIENT_TYPE][1].equals("iPhone")) {
			//iPhone 사용자
			strQuery = "SELECT ver_code, ver_name";
			strQuery = strQuery + " FROM " + strTableVer;
			strQuery = strQuery + " WHERE is_latest = 1";
			strQuery = strQuery + " AND is_Android = 0"; // iPhone

			//System.out.println( "strQuery=" + strQuery );
			db.exec_query(strQuery);
		} else {
			status_msg = "Platform is not supported~!";
			flag = false;
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis> <status_code>2</status_code> <status_msg><%=status_msg%></status_msg>
</troasis>

<%
	}
		//데이터베이스 내용 출력
		if (flag) {
			int msg_i = 0;
			int version_code = 0;
			String version_name = "";
			while (db.mDbRs.next()) {
				version_code = db.mDbRs.getInt("ver_code");
				version_name = db.mDbRs.getString("ver_name");
				msg_i++;
			}
			System.out.println("version_code, version_name, msg_i"
					+ version_code + "," + version_name + "," + msg_i);
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis> 
<status_code>0</status_code> 
<version_code><%=version_code%></version_code>
<version_name><%=version_name%></version_name> 
</troasis>
<%
	//트랜잭션 Rollback Commit.
			db.tran_commit();
		}
	} catch (Exception e) {
		//트랜잭션 Rollback.
		db.tran_rollback();

		//오류 메시지 출력.
		status_msg = e.toString();
		System.out.println("[USER MSG NEW]" + status_msg);
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis> <status_code>2</status_code> <status_msg><%=status_msg%></status_msg>
</troasis>
<%
	} finally {
		//DB 연결 닫기.
		db.db_close();
	}
%>