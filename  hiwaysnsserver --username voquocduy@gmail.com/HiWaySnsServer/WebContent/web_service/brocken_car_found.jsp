<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 사고등록....
	 */
	int			status_code		= 0;		//작업처리결과 코드.
	String		status_msg		= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[BROCKEN_CAR FOUND] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "speed", "" },
										{ "direction", "" },
										{ "nickname", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_SPEED			= INDEX_POS_LNG + 1;
	 	int		INDEX_DIRECTION		= INDEX_SPEED + 1;
		int		INDEX_NICKNAME		= INDEX_DIRECTION + 1;

		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		int		nSpeed			= param.get_param_int( inputList[INDEX_SPEED][1] );
		int		nDirection		= param.get_param_int( inputList[INDEX_DIRECTION][1] );

		
		/*
		 * 예외조건 검사.
		 */
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
			//Default 결과.
			String	strContents	= "";
			//strContents	= "(위치) 위도: " + (nPosLat / 1000000.0) + ", 경도: " + (nPosLng / 1000000.0);
				
			//DB 연결.
			db.db_open();

		 	long	currentTime	= db.getCurrentTimestamp();
		 	
			//사용자 정보 추출.
			String	strNickname	= db.mNickname;
			if ( inputList[INDEX_NICKNAME][1] != null
					&&inputList[INDEX_NICKNAME][1].length() > 0
					&& inputList[INDEX_NICKNAME][1].compareToIgnoreCase("null") != 0 )	strNickname = inputList[INDEX_NICKNAME][1];

		 	//Map matching - 정보 위치에 해당하는 Link 검색.
		 	int		direction	= db.mDirection;		//사용자의 진행방향.
		 	long	link_id		= db.buildLocationInfo( nPosLat, nPosLng, direction );
		 	int		road_no		= db.mRoadNo;

		 	/*
		 	if ( link_id <= 0 )
		 	{
				status_code	= 0;
				status_msg	= "정보의 위치가 유효하지 않습니다.";
		 	}
		 	else
		 	*/
		 	{
			 	if ( link_id > 0 )	strContents	= db.mMapLink.location_msg;
		 	
			 	//사용자의 진행방향과 사용자가 전달한 방향을 고려해, 정보의 방향을 결정.
				if ( nDirection < 0 ) direction *= -1;		//사용자의 진행방향과 반대방향의 정보인 경우.
		
				//사용자의 고장차량알림정보 등록.
				String	strQuery;
				String	strTableTraffic	= "troasis_user_msg";
				
				strQuery	= "INSERT";
				strQuery	= strQuery + " INTO " + strTableTraffic + "(";
				strQuery	= strQuery + " type_level_1";
				strQuery	= strQuery + ", type_level_2";
				strQuery	= strQuery + ", type_level_3";
				strQuery	= strQuery + ", time_log";
				strQuery	= strQuery + ", log_id";
				strQuery	= strQuery + ", user_id";
				strQuery	= strQuery + ", nickname";
				strQuery	= strQuery + ", loc_lat";
				strQuery	= strQuery + ", loc_lng";
				strQuery	= strQuery + ", road_no";
				strQuery	= strQuery + ", link_id";
				strQuery	= strQuery + ", direction";
				strQuery	= strQuery + ", speed";
				strQuery	= strQuery + ", subject";
				strQuery	= strQuery + ", contents";
				strQuery	= strQuery + ", flag_deleted";
				strQuery	= strQuery + ", time_inserted";
				strQuery	= strQuery + ", time_last_updated";
				strQuery	= strQuery + ", time_deleted)";
	
				strQuery	= strQuery + " VALUES(";
				strQuery	= strQuery + "" + TrOasisConstants.TYPE_1_BROCKEN_CAR + "";
				strQuery	= strQuery + "," + TrOasisConstants.TYPE_2_BROCKEN_CAR_FOUND + "";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + nTimestamp + "";
				strQuery	= strQuery + ", " + strActiveID + "";
				strQuery	= strQuery + ", '" + strUserID + "'";
				strQuery	= strQuery + ", '" + strNickname + "'";
				strQuery	= strQuery + ", " + nPosLat + "";
				strQuery	= strQuery + ", " + nPosLng + "";
				strQuery	= strQuery + ", " + road_no + "";
				strQuery	= strQuery + ", " + link_id + "";
				strQuery	= strQuery + ", " + direction + "";
				strQuery	= strQuery + ", " + nSpeed + "";
				strQuery	= strQuery + ", '[고장차량 알림]'";
				strQuery	= strQuery + ", '" + strContents + "'";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", 0)";
	
				db.exec_update( strQuery );
		 	}
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", strActiveID }
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
		System.out.println( "[BROCKEN_CAR FOUND]" + status_msg );
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