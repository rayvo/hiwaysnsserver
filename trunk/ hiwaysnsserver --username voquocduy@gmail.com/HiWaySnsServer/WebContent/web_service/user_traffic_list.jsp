<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 회원 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[USER TRAFFIC LIST] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "option_1", "" },
										{ "option_2", "" }
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_OPTION_1		= INDEX_POS_LNG + 1;
		int		INDEX_OPTION_2		= INDEX_OPTION_1 + 1;
	
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
		int		count_traffics	= 0;

		List<Integer>	list_member_id			= new ArrayList<Integer>();		
		List<String>	list_member_nickname	= new ArrayList<String>();
	 	List<Integer>	list_msg_type			= new ArrayList<Integer>();
		List<Integer>	list_msg_id				= new ArrayList<Integer>();
		List<Long>		list_msg_timestamp		= new ArrayList<Long>();
		List<Integer>	list_msg_lat			= new ArrayList<Integer>();
		List<Integer>	list_msg_lng			= new ArrayList<Integer>();
		List<Integer>	list_msg_speed			= new ArrayList<Integer>();
		List<String>	list_msg_contents		= new ArrayList<String>();
		List<Integer>	list_msg_type_etc		= new ArrayList<Integer>();
		List<String>	list_msg_link_etc		= new ArrayList<String>();
		List<Integer>	list_msg_size_etc		= new ArrayList<Integer>();

	
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
	
			//주어진 User ID의 사용자가 존재하는지 검사한다.	
			String	strQuery;
			String	strTableActive	= "troasis_active";
			String	strTableTraffic	= "troasis_user_msg";
			
			/*
			 * 교통정보 수집.
			 */
			// Match Making을 위한 Group의 범위 설정.
			db.findTrafficRange(nPosLat, nPosLng);
					
			//Match Making을 통해, 그룹에 소속된 교통정보들의 목록 검색..	
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableTraffic;
			strQuery	= strQuery + " WHERE time_log >= " + (currentTime - TrOasisConstants.FILTER_TIME_MSG);	//1시간 이전 메시지만 해당.
			strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
			strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to;
			strQuery	= strQuery + " AND flag_deleted = 0";
			/* --2011.01.15 by s.yoo 모든 사용자의 메시지 표시.
			strQuery	= strQuery + " AND ( (type_level_2 >= " + TrOasisConstants.TYPE_2_ACCIDENT_FOUND;
			strQuery	= strQuery + " AND type_level_2 < " + TrOasisConstants.TYPE_2_USER_SNS + ")";
			strQuery	= strQuery + " OR ( type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;
			strQuery	= strQuery + " AND ( type_etc = " + TrOasisConstants.TYPE_ETC_PICTURE;
			strQuery	= strQuery + " OR type_etc = " + TrOasisConstants.TYPE_ETC_VOICE;
			strQuery	= strQuery + " OR type_etc = " + TrOasisConstants.TYPE_ETC_MOTION + ") ) )";
			*/
			db.exec_query( strQuery );
			
			count_traffics	= 0;
			
			int		msg_type		= 0;
			int		type_etc		= 0;
			String	user_id, member_nickname;
			while ( db.mDbRs.next() && count_traffics < TrOasisConstants.MAX_COUNT_USER_TRAFFIC )
			{
				list_member_id.add( db.mDbRs.getInt( "log_id" ) );
				user_id			= db.mDbRs.getString( "user_id" );
				member_nickname	= db.mDbRs.getString( "nickname" );
				if ( member_nickname.length() < 1
						|| user_id.compareTo(member_nickname) == 0 )	member_nickname = TrOasisConstants.NICKNAME_NOBODY;
				//System.out.println( "member_nickname=" + member_nickname );
				list_member_nickname.add( member_nickname );
				msg_type	= db.mDbRs.getInt( "type_level_2" );
				list_msg_id.add( db.mDbRs.getInt( "id" ) );
				list_msg_timestamp.add( db.mDbRs.getLong( "time_log" ) );
				list_msg_lat.add( db.mDbRs.getInt( "loc_lat" ) );
				list_msg_lng.add( db.mDbRs.getInt( "loc_lng" ) );
				list_msg_speed.add( db.mDbRs.getInt( "speed" ) );				
				list_msg_contents.add( db.mDbRs.getString( "contents" ) );
				type_etc	= db.mDbRs.getInt( "type_etc" );
				list_msg_type_etc.add( type_etc );
				list_msg_link_etc.add( db.mDbRs.getString( "link_etc" ) );
				list_msg_size_etc.add( db.mDbRs.getInt( "size_etc" ) );

				//사용자 멀티미디어 메시지.
				switch( type_etc )
				{
				case TrOasisConstants.TYPE_ETC_PICTURE	:
				case TrOasisConstants.TYPE_ETC_VOICE	:
				case TrOasisConstants.TYPE_ETC_MOTION	:
					msg_type	= TrOasisConstants.TYPE_2_USER_SNS;
					break;
				default									:
					break;
				}
				list_msg_type.add( msg_type );

				//교통정보 개수 증가.
				count_traffics++;
			}
			//System.out.println( "count_traffics=" + count_traffics );
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
	<active_id><%=strActiveID%></active_id>
	<traffic_count><%=count_traffics%></traffic_count>
	<traffic_list>
<%
	for ( int i = 0; i < count_traffics; i++ )
	{
%>
		<traffic>
			<member_id><%=list_member_id.get(i)%></member_id>
			<member_nickname><%=list_member_nickname.get(i)%></member_nickname>
			<message_type><%=list_msg_type.get(i)%></message_type>
			<message_id><%=list_msg_id.get(i)%></message_id>
			<message_timestamp><%=list_msg_timestamp.get(i)%></message_timestamp>
			<message_pos_lat><%=list_msg_lat.get(i)%></message_pos_lat>
			<message_pos_lng><%=list_msg_lng.get(i)%></message_pos_lng>
			<message_speed><%=list_msg_speed.get(i)%></message_speed>
			<message_contents><%=list_msg_contents.get(i)%></message_contents>
			<message_type_etc><%=list_msg_type_etc.get(i)%></message_type_etc>
			<message_link_etc><%=list_msg_link_etc.get(i)%></message_link_etc>
			<message_size_etc><%=list_msg_size_etc.get(i)%></message_size_etc>
		</traffic>
<%
	}
%>
	</traffic_list>
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
		System.out.println( "[USER TRAFFIC LIST]" + status_msg );
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