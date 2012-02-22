<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.ArrayList"	%>
<%@	page	import ="java.util.List"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisPosLog"	%>

<%
	/*
	 * 단말기의 주행기록에 대한 로그 관리....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[POS LOG] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "user_id", "" },
										{ "pos_log_count", "" }
									};
		int		INDEX_USER_ID		= 0;
		int		INDEX_LOG_COUT		= INDEX_USER_ID + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );


		//주행기록록그 추출.
		String[]	listPosLog		=	{
											"timestamp",
											"pos_lat",
											"pos_lng",
											"speed",
											"speed_avg"
										};
		int		INDEX_TIMESTAMP		= 0;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_SPEED			= INDEX_POS_LNG + 1;
		int		INDEX_SPEED_AVG		= INDEX_SPEED + 1;
		
		//응답 메시지 파싱.
		List<TrOasisPosLog>		mListPosLog		= new ArrayList<TrOasisPosLog>();
		List<String[]>	listPosLogValue	= xmlGen.parseMemberXML( strInputXml, "pos_log", listPosLog );
		//Log.i("[POS_LOG LIST]", "listPosLogValue.size()=" + listPosLogValue.size() );
		
		TrOasisPosLog	posLog;
		for ( int i = 0; i < listPosLogValue.size(); i++ )
		{
			posLog	= new TrOasisPosLog();
			//for ( int j = 0; j < listPosLog.length; j++ )	Log.i("[MEMBER]", "(" + i + ") " + listPosLog[j] + "=" + listPosLogValue.get(i)[j] );

			posLog.mTimestamp	= Long.parseLong( listPosLogValue.get(i)[INDEX_TIMESTAMP] );
			posLog.mPosLat		= Integer.parseInt( listPosLogValue.get(i)[INDEX_POS_LAT] );
			posLog.mPosLng		= Integer.parseInt( listPosLogValue.get(i)[INDEX_POS_LNG] );
			posLog.mSpeed		= Integer.parseInt( listPosLogValue.get(i)[INDEX_SPEED] );
			posLog.mSpeedAvg	= Integer.parseInt( listPosLogValue.get(i)[INDEX_SPEED_AVG] );
			
			mListPosLog.add( posLog );
		}

		
		/*
		 * 예외조건 검사.
		 */
		String	strUserID	= inputList[INDEX_USER_ID][1];

		//(1) User ID가 unique 하지 않은 경우.
		int		nActiveID = 0;
		
		if ( db.isValidUserID(strUserID) == false )
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
	
			String	strQuery;
			String	strTableActive	= "troasis_active";
			String	strTablePosLog	= "troasis_pos_log";
			
			//Log를 등록한다.
			for ( int i = 0; i < listPosLogValue.size(); i++ )
			{
				posLog	= mListPosLog.get(i);

				strQuery	= "INSERT";
				strQuery	= strQuery + " INTO " + strTablePosLog + "(";
				strQuery	= strQuery + " user_id";
				strQuery	= strQuery + ", time_log";
				strQuery	= strQuery + ", loc_lat";
				strQuery	= strQuery + ", loc_lng";
				strQuery	= strQuery + ", speed";
				strQuery	= strQuery + ", speed_avg";
				strQuery	= strQuery + ", flag_deleted";
				strQuery	= strQuery + ", time_inserted";
				strQuery	= strQuery + ", time_last_updated";
				strQuery	= strQuery + ", time_deleted)";
		
				strQuery	= strQuery + " VALUES(";
				strQuery	= strQuery + " '" + inputList[INDEX_USER_ID][1] + "'";
				strQuery	= strQuery + ", " + posLog.mTimestamp + "";
				strQuery	= strQuery + ", " + posLog.mPosLat + "";
				strQuery	= strQuery + ", " + posLog.mPosLng + "";
				strQuery	= strQuery + ", " + posLog.mSpeed + "";
				strQuery	= strQuery + ", " + posLog.mSpeedAvg + "";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", 0)";
				db.exec_update( strQuery );
			}
		}
		
		//응답 메시지 정보.
//		if ( status_code != 0 )	System.out.println( status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
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
		System.out.println( "[POS LOG]" + status_msg );
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