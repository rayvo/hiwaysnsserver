<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * FTMS Agent 목록 제공....
	 */
	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[FTMS AGENT LIST] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		
		/*
		 * 예외조건 검사.
		 */
		int		count_agents	= 0;

		List<String>	list_agent_id			= new ArrayList<String>();		
		List<String>	list_agent_name			= new ArrayList<String>();
	 	List<Integer>	list_road_no			= new ArrayList<Integer>();
		List<String>	list_road_name			= new ArrayList<String>();
		List<Integer>	list_agent_pos_lat		= new ArrayList<Integer>();
		List<Integer>	list_agent_pos_lng		= new ArrayList<Integer>();

	
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		
		//if ( db.isValidUser(strActiveID, strUserID, nPosLat, nPosLng) == false )
		//if ( db.isValidActiveID(strUserID, strActiveID) == false )
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
			String	strTableActive		= "troasis_active";
			String	strTableFtmsAgent	= "troasis_ftms_traffic";
			
			/*
			 * FTMS Agent 목록 수집.
			 */
			//Match Making을 통해, 그룹에 소속된 교통정보들의 목록 검색..	
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableFtmsAgent;
			strQuery	= strQuery + " ORDER BY agent_id ASC";
			db.exec_query( strQuery );
			
			count_agents	= 0;
			
			while ( db.mDbRs.next() )
			{
				list_agent_id.add( db.mDbRs.getString( "agent_id" ) );
				list_agent_name.add( db.mDbRs.getString( "agent_name" ) );
				list_road_no.add( db.mDbRs.getInt( "road_no" ) );
				list_road_name.add( db.mDbRs.getString( "road_name" ) );
				list_agent_pos_lat.add( db.mDbRs.getInt( "loc_lat" ) );
				list_agent_pos_lng.add( db.mDbRs.getInt( "loc_lng" ) );

				//FTMS Agent 개수 증가.
				count_agents++;
			}
			//System.out.println( "count_agents=" + count_agents );
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
	<ftms_agent_list>
<%
	for ( int i = 0; i < count_agents; i++ )
	{
%>
		<ftms_agent>
			<ftms_agent_id><%=list_agent_id.get(i)%></ftms_agent_id>
			<ftms_agent_name><%=list_agent_name.get(i)%></ftms_agent_name>
			<ftms_agent_road_no><%=list_road_no.get(i)%></ftms_agent_road_no>
			<ftms_agent_road_name><%=list_road_name.get(i)%></ftms_agent_road_name>
			<ftms_agent_pos_lat><%=list_agent_pos_lat.get(i)%></ftms_agent_pos_lat>
			<ftms_agent_pos_lng><%=list_agent_pos_lng.get(i)%></ftms_agent_pos_lng>
		</ftms_agent>
<%
	}
%>
	</ftms_agent_list>
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
		System.out.println( "[FTMS AGENT LIST]" + status_msg );
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