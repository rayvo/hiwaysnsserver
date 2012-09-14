<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@ page import="java.text.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%
//TODO: For NAVER
	int status_code = 0; //작업처리결과 코드
	String status_msg = ""; //작업처리결과 메시지.
	String key = "";
	String user_name="";
	String password="";
	
	boolean flag=true;
	
	try {

			String strInputXml = param.get_input_param(request.getParameter("xml"));
			
			//Request 수신.
			String[][] inputList = { { "user_name", "" }, 
									 { "password", ""}  };
			
			int INDEX_USER_NAME = 0;
			int INDEX_PASSWORD  = INDEX_USER_NAME +1;
			
			//Request 메시지 파싱.
			//System.out.println("xml=" + strInputXml);
			inputList = xmlGen.parseInputXML(strInputXml, inputList);
			//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );
	
			
			if (inputList[INDEX_USER_NAME][1].equals(""))
			{
				if(inputList[INDEX_PASSWORD][1].equals(""))
				{
				status_msg = "Please input your user name and password!";
				flag = false;
				}
			}
			
			else
				
			{

				db.db_open();
		
				String strQuery;
				String strTableAuth = "naver_auth";
				
				if(inputList[INDEX_USER_NAME][1].equals("NnaverAdmin"))
				{
					if(inputList[INDEX_PASSWORD][1].equals("troasis4naver")) 
					{
						strQuery = "SELECT user_name, auth_key";
						strQuery = strQuery + " FROM " + strTableAuth;
						strQuery = strQuery + " WHERE id=1";
						db.exec_query(strQuery);
					}
				}
				else
				{
						status_msg = "authentication process has been failed~!";
						flag = false;
				}
			}				
			
			
			//데이터베이스 내용 출력
			if (flag) 
			{
	
				while (db.mDbRs.next()) 
				{
	
					key = db.mDbRs.getString("auth_key");
					user_name = db.mDbRs.getString("user_name");
				}	
			
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis> 
<status_code>0</status_code> 
<key><%=key%></key> 
<user_name><%=user_name%></user_name>

</troasis>
<%		}
			else
			{
				%>
				<?xml version="1.0" encoding="UTF-8"?>
				<troasis> 
				<status_code>2</status_code> 
				<status_msg><%=status_msg%></status_msg>
				</troasis>
				<%
			}
	//트랜잭션 Rollback Commit.
	db.tran_commit();
			
	} 
	catch (Exception e) {
		//트랜잭션 Rollback.
		db.tran_rollback();

		//오류 메시지 출력.
		status_msg = e.toString();
		System.out.println("[ERROR : ]" + status_msg);
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis> 
<status_code>2</status_code> 
<status_msg><%=status_msg%></status_msg>
</troasis>
<%
	} 
	finally {
		//DB 연결 닫기.
		db.db_close();
	}
%>

