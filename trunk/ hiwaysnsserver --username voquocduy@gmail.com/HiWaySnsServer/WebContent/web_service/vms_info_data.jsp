<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * VMS Agent 정보 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[VMS INFO DATA] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "vms_agent_id", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_AGENT_ID		= INDEX_POS_LNG + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		String	strAgentID		= param.get_input_param( inputList[INDEX_AGENT_ID][1] );

		
		/*
		 * 예외조건 검사.
		 */
		int		count_vms	= 0;

		List<String>	list_vms_id				= new ArrayList<String>();		
		List<String>	list_vms_tp				= new ArrayList<String>();		
		List<Long>		list_vms_timestamp		= new ArrayList<Long>();
	 	List<Integer>	list_vms_pos_lat		= new ArrayList<Integer>();
	 	List<Integer>	list_vms_pos_lng		= new ArrayList<Integer>();
		List<String>	list_vms_road_name		= new ArrayList<String>();
	 	List<Integer>	list_vms_road_no		= new ArrayList<Integer>();
	 	List<Integer>	list_vms_cnt			= new ArrayList<Integer>();
		List<String>	list_vms_data			= new ArrayList<String>();
		List<String>	list_vms_updown			= new ArrayList<String>();
		List<String>	list_reserved1			= new ArrayList<String>();		
		List<String>	list_reserved2			= new ArrayList<String>();		
		
	
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
			/*
			 * 응답 메시지 구성.
			 */
			//DB 연결.
			db.db_open();

			long	currentTime	= db.getCurrentTimestamp();
		 	String	strTimelog	= db.getTimestampLog( currentTime );

			String	strTableVmsAgent	= "troasis_vms_data";

			/*
			 * VMS Agent 정보목록 수집.
			 */
			//Match Making을 통해, 그룹에 소속된 VMS Agent 교통정보들의 목록 검색.
			//
			String	strQuery;
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableVmsAgent;
			//strQuery	= strQuery + " WHERE time_log > 0";
			strQuery	= strQuery + " WHERE time_log >= '" + strTimelog + "'";
			strQuery	= strQuery + " AND vms_id ='" + strAgentID + "'";
			strQuery	= strQuery + " ORDER BY vms_id ASC";
			//System.out.println( "strQuery=" + strQuery );
			db.exec_query( strQuery );
			
			String	strVmsData, strVmsUpdown;
			count_vms	= 0;
			while ( db.mDbRs.next() )
			{
				list_vms_id.add( db.mDbRs.getString( "vms_id" ) );
				list_vms_tp.add( db.mDbRs.getString( "vms_tp" ) );
				list_vms_timestamp.add( db.mDbRs.getLong( "time_log" ) );
				/*
				list_vms_pos_lat.add( db.mDbRs.getInt( "loc_lng" ) );		//DB에 위경도 값이 반대로 입력되고 있어서...
				list_vms_pos_lng.add( db.mDbRs.getInt( "loc_lat" ) );		//DB에 위경도 값이 반대로 입력되고 있어서...
				*/
				list_vms_pos_lat.add( db.mDbRs.getInt( "loc_lat" ) );
				list_vms_pos_lng.add( db.mDbRs.getInt( "loc_lng" ) );
				list_vms_road_name.add( db.mDbRs.getString( "road_name" ) );
				list_vms_road_no.add( db.mDbRs.getInt( "road_no" ) );
				list_vms_cnt.add( db.mDbRs.getInt( "vms_cnt" ) );
				strVmsData	= db.mDbRs.getString( "vms_data" );
				strVmsData	= strVmsData.replace( '^', '\n' );
				list_vms_data.add( strVmsData );
				strVmsUpdown	= db.mDbRs.getString( "vms_updown" );
				strVmsUpdown	= strVmsUpdown.replace( '^', '\n' );
				strVmsUpdown	= strVmsUpdown.replace( '\n', ' ' );
				strVmsUpdown	= strVmsUpdown.trim();
				list_vms_updown.add( strVmsUpdown );
				list_reserved1.add( db.mDbRs.getString( "reserved1" ) );
				list_reserved2.add( db.mDbRs.getString( "reserved2" ) );

				//VMS Agent 개수 증가.
				//System.out.println( "vms_id=" + db.mDbRs.getString( "vms_id" ) );
				count_vms++;
			}
			//System.out.println( "count_vms=" + count_vms );
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
	<vms_agent_count><%=count_vms%></vms_agent_count>
	<vms_info_list>
<%
	for ( int i = 0; i < count_vms; i++ )
	{
%>
		<vms_info>
			<vms_agent_id><%=list_vms_id.get(i)%></vms_agent_id>
			<vms_tp><%=list_vms_tp.get(i)%></vms_tp>
			<vms_timestamp><%=list_vms_timestamp.get(i)%></vms_timestamp>
			<vms_pos_lat><%=list_vms_pos_lat.get(i)%></vms_pos_lat>
			<vms_pos_lng><%=list_vms_pos_lng.get(i)%></vms_pos_lng>
			<vms_road_name><%=list_vms_road_name.get(i)%></vms_road_name>
			<vms_road_no><%=list_vms_road_no.get(i)%></vms_road_no>
			<vms_cnt><%=list_vms_cnt.get(i)%></vms_cnt>
			<vms_data><%=list_vms_data.get(i)%></vms_data>
			<vms_updown><%=list_vms_updown.get(i)%></vms_updown>
			<reserved1><%=list_reserved1.get(i)%></reserved1>
			<reserved2><%=list_reserved2.get(i)%></reserved2>
		</vms_info>
<%
	}
%>
	</vms_info_list>
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
		System.out.println( "[VMS INFO DATA]" + status_msg );
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