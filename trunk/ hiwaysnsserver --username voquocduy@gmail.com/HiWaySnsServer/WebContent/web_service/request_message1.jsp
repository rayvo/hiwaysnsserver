<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%
	request.setCharacterEncoding("utf-8");
%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="java.text.SimpleDateFormat"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 공지사항 리스트 제공...
	 */

	int status_code = 0; //작업처리결과 코드.
	String status_msg = ""; //작업처리결과 메시지.
	int message_count = 0;

	try

	{
		/*
		 * 입력정보 처리.
		 */

		//Request 수신.
		//System.out.println( "[REQUEST MSG CHANGE] Request received!" );
		//request.setCharacterEncoding( "utf-8" );

		String strInputXml = param.get_input_param(request.getParameter("xml"));
		//Request 메시지 필드목록.

		String[][] inputList = { 	{ "active_id", "" },
									{ "user_id", "" }, 
									{ "message_id", "" }, 
								};

		int INDEX_ACTIVE_ID = 0;
		int INDEX_USER_ID = INDEX_ACTIVE_ID + 1;
		int INDEX_MESSAGE_ID = INDEX_USER_ID + 1;

		//Request 메시지 파싱.
		System.out.println("xml=" + strInputXml);
		inputList = xmlGen.parseInputXML(strInputXml, inputList);
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		String strUserID = inputList[INDEX_USER_ID][1];
		String strActiveID = inputList[INDEX_ACTIVE_ID][1];
		String last_message_id = inputList[INDEX_MESSAGE_ID][1];

		List<String> list_message_id 	= new ArrayList<String>();
		List<String> list_title 		= new ArrayList<String>();
		List<String> list_created_date 	= new ArrayList<String>();
		List<String> list_content 		= new ArrayList<String>();
		List<Integer> list_is_popup 	= new ArrayList<Integer>();

			String strQuery;
			String strTableNotificationMsginfo = "notification_msg_info";
			int new_message =0;
			int last_message = 0;
			//if (last_message_id != null && !last_message_id.equals("")) 
			//{
			//	last_message = Integer.parseInt(last_message_id);
				
				db.db_open();
				long	currentTime	= db.getCurrentTimestamp();
				
				strQuery = "SELECT count(*)";
				strQuery = strQuery + " FROM "+ strTableNotificationMsginfo;
				strQuery = strQuery + " WHERE message_id > " + last_message;
				strQuery = strQuery + " AND is_valid = 1";
				db.exec_query(strQuery);
				
			    if (db.mDbRs.next()) 
				{
			    	new_message = db.mDbRs.getInt(1);
				}
			    
			    if(new_message==0)
			    {
					status_msg = "There is no new message!";
			    }
			    else
			    {
											
					strQuery = "SELECT message_id, title, content, created_date, is_popup";
					strQuery = strQuery + " FROM "+ strTableNotificationMsginfo;
					strQuery = strQuery + " WHERE message_id > " + last_message;
					strQuery = strQuery + " AND is_valid = 1";
					db.exec_query(strQuery);
		
					while (db.mDbRs.next()) 
					{
						message_count++;
						String message_id = "";
						int is_popup = 0;
						
						String title = "";
						String content = "";
						String created_date = "";
	
						message_id = db.mDbRs.getString("message_id");
						title = db.mDbRs.getString("title");
						content = db.mDbRs.getString("content");
						created_date = db.mDbRs
								.getString("created_date");
						is_popup = db.mDbRs.getInt("is_popup");
	
						list_message_id.add(message_id);
						list_title.add(title);
						list_content.add(content);
						list_created_date.add(created_date);
						list_is_popup.add(is_popup);
					}
			
				} 

%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<active_id><%=strActiveID%></active_id>
	<message_count><%=message_count%></message_count>
	<message_list>
<%
	for (int i = 0; i < message_count; i++) {
%>

		<message>
			 <message_id><%=list_message_id.get(i)%></message_id>      
             <title><%=list_title.get(i)%></title>
             <content><%=list_content.get(i)%></content>
             <created_date><%=list_created_date.get(i)%></created_date>
             <is_popup><%=list_is_popup.get(i)%></is_popup>                                            
		</message>

<%
	}
%>


	</message_list>
</troasis>
<%
	//트랜잭션 Commit.
		db.tran_commit();
	} catch (Exception e) {
		//트랜잭션 Rollback.
		db.tran_rollback();
		//오류 메시지 출력.
		status_msg = e.toString();
		System.out.println("[NOTIFICATION FUNCTION ERROR : ]" + status_msg);
%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
</troasis>

<%
	} finally

	{
		//DB 연결 닫기.
		db.db_close();
	}
%>