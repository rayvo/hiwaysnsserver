<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * FTMS Agent 정보 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[FTMS INFO LIST] Request received!" );
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
										{ "option_2", "" },
										{ "step", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_OPTION_1		= INDEX_POS_LNG + 1;
		int		INDEX_OPTION_2		= INDEX_OPTION_1 + 1;
		int		INDEX_STEP			= INDEX_OPTION_2 + 1;

		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		int		nStep			= 0;
		if ( inputList[INDEX_STEP][1].length() > 0 )
			nStep	= param.get_param_int( inputList[INDEX_STEP][1] );

		
		/*
		 * 예외조건 검사.
		 */
		//FTMS 교통정보.
		int		count_agents	= 0;

		List<String>	list_ftms_id			= new ArrayList<String>();		
		List<Long>		list_ftms_timestamp		= new ArrayList<Long>();
	 	List<Integer>	list_ftms_inc_speed		= new ArrayList<Integer>();
		List<String>	list_ftms_inc_info		= new ArrayList<String>();
		List<String>	list_inc_info_speed		= new ArrayList<String>();
	 	List<Integer>	list_ftms_dec_speed		= new ArrayList<Integer>();
		List<String>	list_ftms_dec_info		= new ArrayList<String>();
		List<String>	list_dec_info_speed		= new ArrayList<String>();
	
		//VMS 교통정보.
		int		count_vms	= 0;

		List<String>	list_vms_id				= new ArrayList<String>();		
		List<Long>		list_vms_timestamp		= new ArrayList<Long>();
	 	List<Integer>	list_vms_pos_lat		= new ArrayList<Integer>();
	 	List<Integer>	list_vms_pos_lng		= new ArrayList<Integer>();
		List<String>	list_vms_road_name		= new ArrayList<String>();
	 	List<Integer>	list_vms_road_no		= new ArrayList<Integer>();
	 	List<Integer>	list_vms_cnt			= new ArrayList<Integer>();
		List<String>	list_vms_data			= new ArrayList<String>();
		List<String>	list_vms_updown			= new ArrayList<String>();

	
	
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		
		//if ( db.isValidUser(strActiveID, strUserID, nPosLat, nPosLng) == false )
		if ( db.isValidActiveID(strUserID, strActiveID) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else
		{
			int		my_road_no		= db.mRoadNo;
			long	my_link_id		= db.mLinkeID;
			int		my_direction	= db.mDirection;
			int		my_agent_id		= 0;
			if ( my_link_id >= 100000 )
				Integer.parseInt( String.valueOf(my_road_no) +  String.valueOf(my_link_id).substring(0, 5) );
			int		my_access_count	= db.mAccessCount;
			//System.out.println( "my_access_count=" + my_access_count );
			
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();

		 	long	currentTime	= db.getCurrentTimestamp();
		 	String	strTimelog	= db.getTimestampLog( currentTime );

			String	strQuery;
			String	strTableActive		= "troasis_active";
			String	strTableFtmsAgent	= "troasis_ftms_traffic";

			/*
			 * FTMS 정보목록 수집.
			 */
			// Match Making을 위한 Group의 범위 설정.
			db.findFtmsRange(nPosLat, nPosLng);
						
			//Match Making을 통해, 그룹에 소속된 FTMS Agent 교통정보들의 목록 검색.
			//
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableFtmsAgent;
			//strQuery	= strQuery + " WHERE time_log > 0";
			strQuery	= strQuery + " WHERE time_log >= '" + strTimelog + "'";
			if ( ( nPosLat != 0 || nPosLng != 0 ) && (my_access_count % 10) > 0 )
			{
				strQuery	= strQuery + " AND loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
				strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to;
			}
			/*
			if ( my_link_id > 0 )		//고속도로에 존재하는 경우.
			{
				if ( my_direction > 0 )			//고속도로 Link ID가 증가하는 방향으로 이동하는 경우.
				{
					//나와 다른 고속도로에 있거나(JC를 고려해서)
					strQuery	= strQuery + "  AND ( (road_no <> " + my_road_no + ")";
					//또는  나와 같은 고속도로의 전방에 존재하는 경우
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND agent_id >= " + my_agent_id + ") )";
				}
				else if ( my_direction < 0 )	//고속도로 Link ID가 감소하는 방향으로 이동하는 경우.
				{
					//나와 다른 고속도로에 있거나(JC를 고려해서)
					strQuery	= strQuery + "  AND ( (road_no <> " + my_road_no + ")";
					//또는  나와 같은 고속도로의 후방에 존재하는 경우
					strQuery	= strQuery + "  OR (road_no = " + my_road_no  + " AND agent_id <= " + my_agent_id + ") )";
				}
				else							//주행방향을 알 수 없는 경우.
				{
					//(1) 주어진 영역에 존재하는 FTMS Agent를 대상으로 교통정보 목록 수집.
				}
			}
			else						//고속도로 이외의 도록에 존재하는 경우.
			{
				//(1) 주어진 영역에 존재하는 FTMS Agent를 대상으로 교통정보 목록 수집.
			}
			*/
			strQuery	= strQuery + " ORDER BY agent_id ASC";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_query( strQuery );
			
			count_agents	= 0;
			//++2011.01.19 by s.yoo: iPhone에서 한번에 모든 VMS 데이터 수신이 불가능한 문제해결을 위해, 1번에 200개씩 단위로 전달.
			int		nPackSize	= 200;
			if ( nStep > 0 )
			{
				int		nSkipCount	= nPackSize * (nStep - 1);
				//System.out.println( "nSkipCount=" + nSkipCount );
				for ( int i = 0; i < nSkipCount && db.mDbRs.next(); i++ );
			}
			//++2011.01.19 by s.yoo: iPhone에서 한번에 모든 VMS 데이터 수신이 불가능한 문제해결을 위해, 1번에 200개씩 단위로 전달.			
			while ( db.mDbRs.next() )
			{
				if ( nStep > 0 && count_agents >= nPackSize )	break;
				
				list_ftms_id.add( db.mDbRs.getString( "agent_id" ) );
				list_ftms_timestamp.add( db.mDbRs.getLong( "time_log" ) );
				list_ftms_inc_speed.add( db.mDbRs.getInt( "inc_speed" ) );
				list_ftms_inc_info.add( db.mDbRs.getString( "inc_info" ) );
				list_inc_info_speed.add( db.mDbRs.getString( "inc_info_speed" ) );
				list_ftms_dec_speed.add( db.mDbRs.getInt( "dec_speed" ) );
				list_ftms_dec_info.add( db.mDbRs.getString( "dec_info" ) );
				list_dec_info_speed.add( db.mDbRs.getString( "dec_info_speed" ) );

				//FTMS Agent 개수 증가.
				//System.out.println( "agent_id=" + db.mDbRs.getString( "agent_id" ) );
				count_agents++;
			}
			//System.out.println( "count_agents=" + count_agents );
			
			//FTMS 접근회수 증가.
			//트랜잭션 시작.
			db.tran_begin();
			
			strQuery	= "UPDATE";
			strQuery	= strQuery + " " + strTableActive + " SET access_count = access_count + 1";
			strQuery	= strQuery + " WHERE id ='" + strActiveID + "'";
			strQuery	= strQuery + " AND flag_deleted = 0";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_update( strQuery );
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
	<ftms_agent_count><%=count_agents%></ftms_agent_count>
	<ftms_info_list>
<%
	for ( int i = 0; i < count_agents; i++ )
	{
%>
		<ftms_info>
			<ftms_agent_id><%=list_ftms_id.get(i)%></ftms_agent_id>
			<ftms_timestamp><%=list_ftms_timestamp.get(i)%></ftms_timestamp>
			<ftms_inc_speed><%=list_ftms_inc_speed.get(i)%></ftms_inc_speed>
			<ftms_inc_info><%=list_ftms_inc_info.get(i)%></ftms_inc_info>
			<ftms_dec_speed><%=list_ftms_dec_speed.get(i)%></ftms_dec_speed>
			<ftms_dec_info><%=list_ftms_dec_info.get(i)%></ftms_dec_info>
		</ftms_info>
<%
	}
%>
	</ftms_info_list>
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
		System.out.println( "[FTMS INFO LIST]" + status_msg );
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