<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 사용자 메시지 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[MESSAGE LIST] Request received!" );
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
		int		total_messages	= 0;				//전체 메시지 개수.
		int		count_messages	= 0;				//응답에서 전달하는 메시지 개수.

		List<Integer>	list_member_id			= new ArrayList<Integer>();		
		List<String>	list_member_nickname	= new ArrayList<String>();
	 	List<Integer>	list_msg_type			= new ArrayList<Integer>();
		List<Integer>	list_msg_id				= new ArrayList<Integer>();
		List<Long>		list_msg_timestamp		= new ArrayList<Long>();
		List<Integer>	list_msg_lat			= new ArrayList<Integer>();
		List<Integer>	list_msg_lng			= new ArrayList<Integer>();
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
			int		my_road_no		= db.mRoadNo;
			long	my_link_id		= db.mLinkeID;
			int		my_direction	= db.mDirection;
				
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();

		 	long	currentTime	= db.getCurrentTimestamp();

			String	strQuery;
			String	strTableActive	= "troasis_active";
			String	strTableUserMsg	= "troasis_user_msg";

			/*
			 * Match Making을 위한 Group의 범위 설정.
			 */
			//최소한 1명 이상의 길벗이 존재할 때까지 탐색범위 확대.
			int	count_friends	= db.setSearchRange( strActiveID, nPosLat, nPosLng );			
			
			/*
			 * 메시지 목록 구성.
			 */
			//(1) Match Making을 통해, 그룹에 소속된 회원들의 메시지 개수 검색.
			strQuery	= "SELECT COUNT(*)";
			strQuery	= strQuery + " FROM " + strTableUserMsg;
			//strQuery	= strQuery + " WHERE log_id = " + strActiveID;				//내가 쓴글.
			//strQuery	= strQuery + " OR parent_log_id = " + strActiveID;			//내글에 대한 답글.
			strQuery	= strQuery + " WHERE (user_id = '" + strUserID + "'";		//내가 쓴글.
			strQuery	= strQuery + " OR parent_user_id = '" + strUserID + "'";	//내글에 대한 답글.
			/*
			strQuery	= strQuery + " OR (loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
			strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";
			*/

			if ( my_link_id > 0 )				//고속도로에 위치하는 경우 진행방향 고려.
			{
				//(1) 주변영역의 일반 사용자 메시지
				strQuery	= strQuery + " OR (type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;
				strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";

				//또는 (2) 주어진 영역에 존재하는 교통관련 메시지들 중에서.
				strQuery	= strQuery + " OR ( (type_level_2 <> " + TrOasisConstants.TYPE_2_USER_SNS;
				strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";

				//고속도로가 아닌 도로에서 주변영역이거나
				strQuery	= strQuery + " AND ( link_id = 0 ";
				//또는 고속도로에서 나와 다른 도로에 있거나(JC를 고려해서)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + my_road_no + ")";
				//또는 고속도로에서 나와 같은 도로의 전방에 존재하는 경우
				if ( my_direction > 0 )			//고속도로 Link ID가 증가하는 방향으로 이동하는 경우.
				{
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND link_id >= " + my_link_id + ")";
				}
				else if ( my_direction < 0 )	//고속도로 Link ID가 감소하는 방향으로 이동하는 경우.
				{
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND link_id <= " + my_link_id + ")";
				}
				strQuery	= strQuery + ") )";
			}
			else								//고속도로 이외의 도로에 있는 경우.
			{
				//(1) 주어진 영역에 존재하는 메시지.
				strQuery	= strQuery + " OR (loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";
			}
			strQuery	= strQuery + ")";
			strQuery	= strQuery + " AND time_log >= " + (currentTime - TrOasisConstants.FILTER_TIME_MSG);	//1시간 이전 메시지만 해당.
			//System.out.println( "strQuery=" + strQuery );

			db.exec_query( strQuery );
			
			total_messages	= 0;				//전체 메시지 개수.
			if ( db.mDbRs.next() )
			{
				total_messages	= db.mDbRs.getInt( 1 );
			}
						 
			//(2) Match Making을 통해, 그룹에 소속된 회원들의 메시지 목록 검색.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableUserMsg;
			//strQuery	= strQuery + " WHERE log_id = " + strActiveID;
			strQuery	= strQuery + " WHERE (user_id = '" + strUserID + "'";		//내가 쓴글.
			strQuery	= strQuery + " OR parent_user_id = '" + strUserID + "'";	//내글에 대한 답글.
			/*
			strQuery	= strQuery + " OR (loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
			strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";
			*/

			if ( my_link_id > 0 )				//고속도로에 위치하는 경우 진행방향 고려.
			{
				//(1) 주변영역의 일반 사용자 메시지
				strQuery	= strQuery + " OR (type_level_2 = " + TrOasisConstants.TYPE_2_USER_SNS;
				strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";

				//또는 (2) 주어진 영역에 존재하는 교통관련 메시지들 중에서.
				strQuery	= strQuery + " OR ( (type_level_2 <> " + TrOasisConstants.TYPE_2_USER_SNS;
				strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";

				//고속도로가 아닌 도로에서 주변영역이거나
				strQuery	= strQuery + " AND ( link_id = 0 ";
				//또는 고속도로에서 나와 다른 도로에 있거나(JC를 고려해서)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + my_road_no + ")";
				//또는 고속도로에서 나와 같은 도로의 전방에 존재하는 경우
				if ( my_direction > 0 )			//고속도로 Link ID가 증가하는 방향으로 이동하는 경우.
				{
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND link_id >= " + my_link_id + ")";
				}
				else if ( my_direction < 0 )	//고속도로 Link ID가 감소하는 방향으로 이동하는 경우.
				{
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND link_id <= " + my_link_id + ")";
				}
				strQuery	= strQuery + ") )";
			}
			else								//고속도로 이외의 도로에 있는 경우.
			{
				//(1) 주어진 영역에 존재하는 메시지.
				strQuery	= strQuery + " OR (loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to + ")";
			}
			strQuery	= strQuery + ")";
			strQuery	= strQuery + " AND time_log >= " + (currentTime - TrOasisConstants.FILTER_TIME_MSG);	//1시간 이전 메시지만 해당.
			if ( nTimestamp > 0 )
			{
				strQuery	= strQuery + " AND time_log < " + nTimestamp;
			}
			strQuery	= strQuery + " ORDER BY time_log DESC";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_query( strQuery );
			
			count_messages	= 0;				//응답에서 전달하는 메시지 개수.
			String	user_id, member_nickname;
			String	contents;
			int		type_etc;
			while ( db.mDbRs.next() && count_messages < TrOasisConstants.MAX_COUNT_MESSAGE )
			{
				list_member_id.add( db.mDbRs.getInt( "log_id" ) );
				user_id			= db.mDbRs.getString( "user_id" );
				member_nickname	= db.mDbRs.getString( "nickname" );
				if ( member_nickname.length() < 1
						|| user_id.compareTo(member_nickname) == 0 )	member_nickname = TrOasisConstants.NICKNAME_NOBODY;
				//System.out.println( "member_nickname=" + member_nickname );
				list_member_nickname.add( member_nickname );
				list_msg_type.add( db.mDbRs.getInt( "type_level_2" ) );
				list_msg_id.add( db.mDbRs.getInt( "id" ) );
				list_msg_timestamp.add( db.mDbRs.getLong( "time_log" ) );
				list_msg_lat.add( db.mDbRs.getInt( "loc_lat" ) );
				list_msg_lng.add( db.mDbRs.getInt( "loc_lng" ) );
				contents	= db.mDbRs.getString( "contents" );
				type_etc	= db.mDbRs.getInt( "type_etc" );
				if ( contents == null )	contents = "";
				/*
				if ( contents.length() < 1 )
				{
					switch( type_etc )
					{
					case TrOasisConstants.TYPE_ETC_VOICE	:
						contents	= member_nickname + "님의 음성  메시지";
						break;
						
					case TrOasisConstants.TYPE_ETC_PICTURE	:
						contents	= member_nickname + "님의 카메라 사진 메시지";
						break;
						
					case TrOasisConstants.TYPE_ETC_MOTION	:
						contents	= member_nickname + "님의  동영상 메시지";
						break;

					default	:
						break;
					}
				}
				*/
				//System.out.println( "contents=" + contents );
				list_msg_contents.add( contents );
				list_msg_type_etc.add( db.mDbRs.getInt( "type_etc" ) );
				list_msg_link_etc.add( db.mDbRs.getString( "link_etc" ) );
				list_msg_size_etc.add( db.mDbRs.getInt( "size_etc" ) );
				//System.out.println( "link_etc=" + db.mDbRs.getString( "link_etc" ) );

				//메시지 개수 증가.
				count_messages++;
			}
			//System.out.println( "count_messages=" + count_messages );
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
	<total_message><%=total_messages%></total_message>
	<message_count><%=count_messages%></message_count>
	<message_list>
<%
	for ( int i = 0; i < count_messages; i++ )
	{
%>
		<message>
			<member_id><%=list_member_id.get(i)%></member_id>
			<member_nickname><%=list_member_nickname.get(i)%></member_nickname>
			<message_type><%=list_msg_type.get(i)%></message_type>
			<message_id><%=list_msg_id.get(i)%></message_id>
			<message_timestamp><%=list_msg_timestamp.get(i)%></message_timestamp>
			<message_pos_lat><%=list_msg_lat.get(i)%></message_pos_lat>
			<message_pos_lng><%=list_msg_lng.get(i)%></message_pos_lng>
			<message_contents><%=list_msg_contents.get(i)%></message_contents>
			<message_type_etc><%=list_msg_type_etc.get(i)%></message_type_etc>
			<message_link_etc><%=list_msg_link_etc.get(i)%></message_link_etc>
			<message_size_etc><%=list_msg_size_etc.get(i)%></message_size_etc>
		</message>
<%
	}
%>
	</message_list>
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
		System.out.println( "[MESSAGE LIST]" + status_msg );
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