<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.io.*"	%>
<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 사용자 메시지 등록....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[USER MSG NEW] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "message", "" },
										{ "parent_id", "" },
										{ "nickname", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_MESSAGE		= INDEX_POS_LNG + 1;
		int		INDEX_PARENT_ID		= INDEX_MESSAGE + 1;
		int		INDEX_NICKNAME		= INDEX_PARENT_ID + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		int		nParentID		= param.get_param_int( inputList[INDEX_PARENT_ID][1] );

		
		/*
		 * 예외조건 검사.
		 */
		int		paren_log_id	= 0;				//답글의 경우 원본 메시지의 작성자 Active ID.
		String	paren_user_id	= "";
		Integer	strMsgID		= 0;
		
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		
		if ( db.isValidUser(strActiveID, strUserID, nPosLat, nPosLng) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else
		{
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();

	 		long	currentTime	= db.getCurrentTimestamp();

			//사용자 정보 추출.
			String	strNickname	= db.mNickname;
			if ( inputList[INDEX_NICKNAME][1] != null
					&&inputList[INDEX_NICKNAME][1].length() > 0
					&& inputList[INDEX_NICKNAME][1].compareToIgnoreCase("null") != 0 )	strNickname = inputList[INDEX_NICKNAME][1];
			
			//주어진 User ID의 사용자가 존재하는지 검사한다.	
			String	strQuery;
			String	strTableUserMsg	= "troasis_user_msg";
			
			//임시 키 생성.
			String	strTmpKey	= "";
			File	tf1	= File.createTempFile("~TrOasis", ".tmp");
			strTmpKey	= tf1.getName();
			tf1.deleteOnExit();
			
			
			//부모글의 사용자 Log ID 검색.
			if ( nParentID > 0 )
			{
				strQuery	= "SELECT log_id, user_id";
				strQuery	= strQuery + " FROM " + strTableUserMsg;
				strQuery	= strQuery + " WHERE id = " + nParentID + "";
				db.exec_query( strQuery );
				
				if ( db.mDbRs.next() )
				{
					paren_log_id	= db.mDbRs.getInt( "log_id" );
					paren_user_id	= db.mDbRs.getString( "user_id" );
				}
			}
						
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
			strQuery	= strQuery + ", '" + nTimestamp + "'";
			strQuery	= strQuery + ", " + nPosLat + "";
			strQuery	= strQuery + ", " + nPosLng + "";
			strQuery	= strQuery + ", " + strActiveID + "";
			strQuery	= strQuery + ",  '" + strUserID + "'";
			strQuery	= strQuery + ", '" + strNickname + "'";
			strQuery	= strQuery + ", " + nParentID + "";
			strQuery	= strQuery + ", " + paren_log_id + "";
			strQuery	= strQuery + ", '" + paren_user_id + "'";
			strQuery	= strQuery + ", ''";
			strQuery	= strQuery + ", '" + inputList[INDEX_MESSAGE][1] + "'";
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
				
			//사용자가 등록한 메시지의 ID 검색.
			strQuery	= "SELECT id";
			strQuery	= strQuery + " FROM " + strTableUserMsg;
			strQuery	= strQuery + " WHERE flag_deleted = 0";
			strQuery	= strQuery + " AND log_id = " + strActiveID + "";
			strQuery	= strQuery + " AND user_id = '" + strUserID + "'";
			strQuery	= strQuery + " AND tmp_key = '" + strTmpKey + "'";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_query( strQuery );
			
			strMsgID	= 0;				//메시지 ID.
			if ( db.mDbRs.next() )
			{
				strMsgID	= db.mDbRs.getInt( "id" );
			}
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", strActiveID },
										{ "message_id", String.valueOf(strMsgID) }
									};
//		if ( status_code != 0 )	System.out.println( status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
<%
	for ( int i = 0; i < outputList.length; i++ )
	{
%>
	<<%=outputList[i][0]%>><%=outputList[i][1]%></<%=outputList[i][0]%>>
<%
	}
%>
</troasis>
<%
		//트랜잭션 Commit.
		db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();
		
		//오류 메시지 출력.
		status_msg	= e.toString();
		System.out.println( "[USER MSG NEW]" + status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
</troasis>
<%
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>