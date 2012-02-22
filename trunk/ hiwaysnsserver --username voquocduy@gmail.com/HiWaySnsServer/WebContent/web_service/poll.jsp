<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * 단말기의 주기적인 위치정보 갱신....
	 */
	int			status_code		= 0;		//작업처리결과 코드.
	String		status_msg		= "";		//작업처리결과 메시지.
	String		location_msg	= "";		//Map Matching 결과 메시지.
	int			my_direction	= 0;		//자차의 진행방향.
	int			my_road_no		= 0;		//자차의 주행도로 번호.
	
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
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
//		System.out.println( "[POLL] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "speed", "" }
									};
		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_SPEED			= INDEX_POS_LNG + 1;
	
		//Request 메시지 파싱.
		//System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );

		long	nTimestamp		= param.get_param_long( inputList[INDEX_TIMESTAMP][1] );
		int		nPosLat			= param.get_param_int( inputList[INDEX_POS_LAT][1] );
		int		nPosLng			= param.get_param_int( inputList[INDEX_POS_LNG][1] );
		int		nSpeed			= param.get_param_int( inputList[INDEX_SPEED][1] );

		
		/*
		 * 예외조건 검사.
		 */
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		//System.out.println( "strActiveID=" + strActiveID + ", nPosLat=" + nPosLat + ", nPosLng=" + nPosLng );
		
		if ( db.isValidUser(strActiveID, strUserID, nPosLat, nPosLng) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else
		{
			//DB 연결.
			db.db_open();

	 		long	currentTime	= db.getCurrentTimestamp();
	
			//사용자 정보 추출.
			String	strNickname		= db.mNickname;
			my_road_no				= db.mRoadNo;
			long	my_link_id		= db.mLinkeID;
			if ( my_link_id > 0 )	my_direction = db.mDirection;

			/*
			 * 주어진 User ID의 사용자가 존재하는지 검사한다.
			 */
			String	strQuery;
			String	strTableActive		= "troasis_active";
			String	strTableLog			= "troasis_log";
			String	strTableVmsAgent	= "troasis_vms_data";

			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableActive;
			strQuery	= strQuery + " WHERE id = " + strActiveID + "";
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_query( strQuery );
			
			
			int		record_id		= 0;
			int		start_loc_lat	= 0;
			int		start_loc_lng	= 0;
			int		prev_road_no	= 0;
			long	prev_link_id	= 0;
			int		prev_direction	= TrOasisConstants.DIRECT_NONE;
			int		prev_pos_lat	= 0;
			int		prev_pos_lng	= 0;
			long	prev_distance	= 0;
			if ( db.mDbRs.next() )
			{
				record_id		= db.mDbRs.getInt( "id" );
				start_loc_lat	= db.mDbRs.getInt( "start_loc_lat" );
				start_loc_lng	= db.mDbRs.getInt( "start_loc_lng" );
				
				prev_pos_lat	= db.mDbRs.getInt( "loc_lat" );
				prev_pos_lng	= db.mDbRs.getInt( "loc_lng" );
				prev_road_no	= db.mDbRs.getInt( "road_no" );
				prev_link_id	= db.mDbRs.getLong( "link_id" );
				prev_direction	= db.mDbRs.getInt( "direction" );
				prev_distance	= db.mDbRs.getLong( "distance" );
			}
			//System.out.println( "record_id=" + record_id );
			
			
			/*
			 * Map Matching - 사용자 위치 검출.
			 */
			/*
			double	lat1	= 35.246601;
			double	lng1	= 129.093203;
			double	lat2	= 35.253652;
			double	lng2	= 129.100001;
			double	distance	= db.distLocPts( lat1, lng1, lat2, lng2 );
			System.out.println( "1. 거리=" + distance + " M" );
			distance	= db.distVincenty( lat1, lng1, lat2, lng2 );
			System.out.println( "2. 거리=" + distance + " M" );
			distance	= db.distGeoPts( (int)(lat1*1000000), (int)(lng1*1000000), (int)(lat2*1000000), (int)(lng2*1000000) );
			System.out.println( "3. 거리=" + distance + " M" );
			*/
			long	new_link_id	= db.procMapMatching( nPosLat, nPosLng, prev_road_no, prev_link_id, prev_direction, prev_distance );
			if ( new_link_id <= 0 )
			{
				location_msg	= "고속도로에 위치하지 않음.";
			}
			else
			{
				location_msg	= db.mMapLink.location_msg;
			}
			//System.out.println( location_msg );
			
			 
			/*
			 * Map Matching 정보와 사용자 위치 Log 등록.
			 */
			//트랜잭션 시작.
			db.tran_begin();
		 
			if ( record_id > 0 )
			{
				//존재하는 경우, Active 정보를 갱신하고...
				//GPS 위치정보가 초기화되지 않은 경우에는, 이들 정보들도 초기화 한다.
				strQuery	= "UPDATE";
				strQuery	= strQuery + " " + strTableActive + " SET";
				strQuery	= strQuery + " time_log_last = " + nTimestamp + "";
				strQuery	= strQuery + ", loc_lat = " + nPosLat + "";
				strQuery	= strQuery + ", loc_lng = " + nPosLng + "";
				strQuery	= strQuery + ", speed = " + nSpeed + "";
				strQuery	= strQuery + ", time_last_updated = " + currentTime;
				
				if ( start_loc_lat == 0 && start_loc_lng == 0 )
				{
					strQuery	= strQuery + ", time_log_start = " + nTimestamp + "";
					strQuery	= strQuery + ", start_loc_lat = " + nPosLat + "";
					strQuery	= strQuery + ", start_loc_lng = " + nPosLng + "";
				}

				if ( new_link_id > 0 )
				{
					strQuery	= strQuery + ", road_no = " + db.mMapLink.road_no + "";
					strQuery	= strQuery + ", link_id = " + db.mMapLink.link_id + "";
					strQuery	= strQuery + ", direction = " + db.mMapLink.direction + "";
					strQuery	= strQuery + ", distance = " + db.mMapLink.distance + "";
				}

				strQuery	= strQuery + " WHERE id = " + strActiveID + "";
				strQuery	= strQuery + " AND flag_deleted = 0";
				db.exec_update( strQuery );
				
				//Log를 등록한다.
				strQuery	= "INSERT";
				strQuery	= strQuery + " INTO " + strTableLog + "(";
				strQuery	= strQuery + " log_id";
				strQuery	= strQuery + ", user_id";
				strQuery	= strQuery + ", nickname";
				strQuery	= strQuery + ", time_log";
				strQuery	= strQuery + ", loc_lat";
				strQuery	= strQuery + ", loc_lng";
				strQuery	= strQuery + ", speed";
				strQuery	= strQuery + ", flag_deleted";
				strQuery	= strQuery + ", time_inserted";
				strQuery	= strQuery + ", time_last_updated";
				strQuery	= strQuery + ", time_deleted)";
	
				strQuery	= strQuery + " VALUES(";
				strQuery	= strQuery + " " + strActiveID + "";
				strQuery	= strQuery + ", '" + strUserID + "'";
				strQuery	= strQuery + ", '" + strNickname + "'";
				strQuery	= strQuery + ", " + nTimestamp + "";
				strQuery	= strQuery + ", " + nPosLat + "";
				strQuery	= strQuery + ", " + nPosLng + "";
				strQuery	= strQuery + ", " + nSpeed + "";
				strQuery	= strQuery + ", 0";
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", " + currentTime;
				strQuery	= strQuery + ", 0)";
				db.exec_update( strQuery );
			}
			else
			{
				status_code	= 2;
				status_msg	= "유효하지 않은 사용자 Activity ID 사용.";
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
	<my_direction><%=my_direction%></my_direction>
	<my_road_no><%=my_road_no%></my_road_no>
	<location_msg><%=location_msg%></location_msg>
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
		System.out.println( "[POLL]" + status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
	<my_road_no>0</my_road_no>
	<my_direction>0</my_direction>
	<location_msg><%=location_msg%></location_msg>
</troasis>
<%
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>