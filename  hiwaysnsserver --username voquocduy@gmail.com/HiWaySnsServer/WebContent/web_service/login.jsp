<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>
<%
	/*
	 * 사용자 로그인....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[LOGIN] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

    	//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "phone", "" },
										{ "email", "" },
										{ "twitter", "" },
										{ "destination", "" },
										{ "purpose", "" },
										{ "nickname", "" },
										{ "icon", "" },
										{ "style", "" },
										{ "level", "" }
									};
    	int		INDEX_USER_ID		= 0;
    	int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
    	int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
    	int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
    	int		INDEX_PHONE			= INDEX_POS_LNG + 1;
    	int		INDEX_EMAIL			= INDEX_PHONE + 1;
    	int		INDEX_TWITTER		= INDEX_EMAIL + 1;
    	int		INDEX_DESTINATION	= INDEX_TWITTER + 1;
    	int		INDEX_PURPOSE		= INDEX_DESTINATION + 1;
    	int		INDEX_NICKNAME		= INDEX_PURPOSE + 1;
    	int		INDEX_ICON			= INDEX_NICKNAME + 1;
    	int		INDEX_STYLE			= INDEX_ICON + 1;
    	int		INDEX_LEVEL			= INDEX_STYLE + 1;
    	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		int		nDestination	= param.get_param_int( inputList[INDEX_DESTINATION][1] );
		int		nPurpose		= param.get_param_int( inputList[INDEX_PURPOSE][1] );
		int		nIcon			= param.get_param_int( inputList[INDEX_ICON][1] );
		int		nStyle			= param.get_param_int( inputList[INDEX_STYLE][1] );
		int		nLevel			= param.get_param_int( inputList[INDEX_LEVEL][1] );
		//System.out.println( "nTimestamp=" + nTimestamp );
		
		/*
		 * 예외조건 검사.
		 */
		//Default Return 값 설정.
		int		nActiveID 		= 0;
			
		//대표 User ID 선정: 전화번호 -> e-mail -> Twitter 계정 순서.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		if ( strUserID.length() < 1 )		strUserID	= inputList[INDEX_PHONE][1];
		else if ( strUserID.length() < 1 )	strUserID	= inputList[INDEX_EMAIL][1];
		else if ( strUserID.length() < 1 )	strUserID	= inputList[INDEX_TWITTER][1];

		//(1) User ID가 unique 하지 않은 경우.
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
	    	
			//주어진 User ID의 사용자가 존재하는지 검사한다.
			String	strQuery;
			String	strTableActive	= "troasis_active";
			
			strQuery	= "SELECT COUNT(id)";
			strQuery	= strQuery + " FROM " + strTableActive;
			strQuery	= strQuery + " WHERE user_id = '" + strUserID + "'";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_query( strQuery );
			
			int	nCountUsers	= 0;
			if( db.mDbRs.next() )
				nCountUsers	= db.mDbRs.getInt( 1 );
			//System.out.println( "nCountUsers=" + nCountUsers );
			
			//트랜잭션 시작.
			db.tran_begin();
			
			//사용자 Login 정보 등록 및 Login 작업 처리.	
			String	strNickname	= inputList[INDEX_NICKNAME][1];
			if ( strNickname.length() < 1 )	strNickname = strUserID;
			if ( strNickname.length() < 1
					|| strUserID.compareTo(strNickname) == 0 )	strNickname = TrOasisConstants.NICKNAME_NOBODY;

			if ( nCountUsers > 0 )
			{
				//존재하는 경우, Login 정보를 갱신한다.			
				strQuery	= "UPDATE";
				strQuery	= strQuery + " " + strTableActive + " SET";
				strQuery	= strQuery + " phone = '" + inputList[INDEX_PHONE][1] + "'";
				strQuery	= strQuery + ", email = '" + inputList[INDEX_EMAIL][1] + "'";
				strQuery	= strQuery + ", twitter = '" + inputList[INDEX_TWITTER][1] + "'";
				strQuery	= strQuery + ", destination = " + nDestination + "";
				strQuery	= strQuery + ", purpose = " + nPurpose + "";
				strQuery	= strQuery + ", nickname = '" + strNickname + "'";
				strQuery	= strQuery + ", icon = " + nIcon + "";
				strQuery	= strQuery + ", style = " + nStyle + "";
				strQuery	= strQuery + ", level = " + nLevel + "";
				strQuery	= strQuery + ", road_no = 0";
				strQuery	= strQuery + ", link_id = 0";
				strQuery	= strQuery + ", direction = " + TrOasisConstants.DIRECT_NONE;
				strQuery	= strQuery + ", distance = 0";
				strQuery	= strQuery + ", time_log_start = " + nTimestamp + "";
				strQuery	= strQuery + ", start_loc_lat = " + nPosLat + "";
				strQuery	= strQuery + ", start_loc_lng = " + nPosLng + "";
				strQuery	= strQuery + ", time_log_last = " + nTimestamp + "";
				strQuery	= strQuery + ", loc_lat = " + nPosLat + "";
				strQuery	= strQuery + ", loc_lng = " + nPosLng + "";
				strQuery	= strQuery + ", speed = 0";
				strQuery	= strQuery + ", flag_deleted = 0";
				strQuery	= strQuery + ", time_last_updated = " + currentTime;
				strQuery	= strQuery + " WHERE user_id = '" + strUserID + "'";
				strQuery	= strQuery + " AND flag_deleted = 0";
			}
			else
			{
				//존재하지 않는 경우에는, Login 정보를 사용해 등록한다.
				strQuery	= "INSERT";
				strQuery	= strQuery + " INTO " + strTableActive + "(";
				strQuery	= strQuery + " user_id";
				strQuery	= strQuery + ", phone";
				strQuery	= strQuery + ", email";
				strQuery	= strQuery + ", twitter";
				strQuery	= strQuery + ", destination";
				strQuery	= strQuery + ", purpose";
				strQuery	= strQuery + ", nickname";
				strQuery	= strQuery + ", icon";
				strQuery	= strQuery + ", style";
				strQuery	= strQuery + ", level";
				strQuery	= strQuery + ", road_no";
				strQuery	= strQuery + ", link_id";
				strQuery	= strQuery + ", direction";
				strQuery	= strQuery + ", distance";
				strQuery	= strQuery + ", time_log_start";
				strQuery	= strQuery + ", start_loc_lat";
				strQuery	= strQuery + ", start_loc_lng";
				strQuery	= strQuery + ", time_log_last";
				strQuery	= strQuery + ", loc_lat";
				strQuery	= strQuery + ", loc_lng";
				strQuery	= strQuery + ", speed";
				strQuery	= strQuery + ", flag_deleted";
				strQuery	= strQuery + ", time_inserted";
				strQuery	= strQuery + ", time_last_updated";
				strQuery	= strQuery + ", time_deleted)";
	
				strQuery	= strQuery + " VALUES(";
				strQuery	= strQuery + "  '" + strUserID + "'";
				strQuery	= strQuery + ", '" + inputList[INDEX_PHONE][1] + "'";
				strQuery	= strQuery + ", '" + inputList[INDEX_EMAIL][1] + "'";
				strQuery	= strQuery + ", '" + inputList[INDEX_TWITTER][1] + "'";
				strQuery	= strQuery + ", " + nDestination + "";
				strQuery	= strQuery + ", " + nPurpose + "";
				strQuery	= strQuery + ", '" + strNickname + "'";
				strQuery	= strQuery + ", " + nIcon + "";
				strQuery	= strQuery + ", " + nStyle + "";
				strQuery	= strQuery + ", " + nLevel + "";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + nTimestamp + "";
				strQuery	= strQuery + ", " + nPosLat + "";
				strQuery	= strQuery + ", " + nPosLng + "";
				strQuery	= strQuery + ", " + nTimestamp + "";
				strQuery	= strQuery + ", " + nPosLat + "";
				strQuery	= strQuery + ", " + nPosLng + "";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", 0)";
			}
			db.exec_update( strQuery );
	
			//Login 사용자의 Active 사용자 ID 검색.
			strQuery	= "SELECT id";
			strQuery	= strQuery + " FROM " + strTableActive;
			strQuery	= strQuery + " WHERE user_id ='" + strUserID + "'";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_query( strQuery );
			
			if( db.mDbRs.next() )
				nActiveID = db.mDbRs.getInt( "id" );
			//System.out.println( "nActiveID=" + nActiveID );
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
										{ "active_id", String.valueOf(nActiveID) }
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
		System.out.println( "[LOGIN]" + status_msg );
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