<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%
	/*
	 * 사용자 로그아웃....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[LOGOUT] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

    	//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" }
									};
    	int		INDEX_ACTIVE_ID		= 0;
    	int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
    	int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
    	int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
    	int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
    	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );

		
		/*
		 * 예외조건 검사.
		 */
		//(1) Valid 하지 않은 Active ID가 전달된 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		int		nActiveID = 0;
		
		if ( db.isValidActiveID(strUserID, strActiveID) == false )
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
	
			//주어진 Active ID의 사용자 삭제.
			String	strQuery;
			String	strTableActive	= "troasis_active";
			String	strTableLog		= "troasis_log";

			///*
			//Active 테이블에 삭제 Flag 설정.
			strQuery	= "UPDATE";
			strQuery	= strQuery + " " + strTableActive + " SET";
			strQuery	= strQuery + " time_log_last = " + nTimestamp + "";
			strQuery	= strQuery + ", loc_lat = " + nPosLat + "";
			strQuery	= strQuery + ", loc_lng = " + nPosLng + "";
			strQuery	= strQuery + ", flag_deleted = 1";
			strQuery	= strQuery + ", time_deleted = " + currentTime;
			strQuery	= strQuery + " WHERE id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_update( strQuery );

			//Log 테이블에 삭제 Flag 설정.
			strQuery	= "UPDATE";
			strQuery	= strQuery + " " + strTableLog + " SET";
			strQuery	= strQuery + " flag_deleted = 1";
			strQuery	= strQuery + ", time_deleted = " + currentTime;
			strQuery	= strQuery + " WHERE log_id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_update( strQuery );
			//*/
			/*
			//Active 테이블 삭제.
			strQuery	= "DELETE";
			strQuery	= strQuery + " FROM " + strTableActive;
			strQuery	= strQuery + " WHERE id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_update( strQuery );

			//Log 테이블 삭제.
			strQuery	= "DELETE";
			strQuery	= strQuery + " FROM " + strTableLog;
			strQuery	= strQuery + " WHERE log_id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_update( strQuery );
			*/
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", String.valueOf(strActiveID) }
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
		//System.out.println( status_msg );
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