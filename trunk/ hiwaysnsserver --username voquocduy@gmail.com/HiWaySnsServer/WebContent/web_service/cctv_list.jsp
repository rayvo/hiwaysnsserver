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
//		System.out.println( "[CCTV LIST] Request received!" );
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
		int		nCountCCTVs	= 0;

		List<Long	>	list_cctv_id			= new ArrayList<Long>();
		List<Integer>	list_cctv_lat			= new ArrayList<Integer>();
		List<Integer>	list_cctv_lng			= new ArrayList<Integer>();
		List<String>	list_url_iphone			= new ArrayList<String>();
		List<String>	list_url_android		= new ArrayList<String>();
	
	
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
			String	strTableCctv	= "troasis_cctv_node";
			
			/*
			 * 교통정보 수집.
			 */
			// Match Making을 위한 Group의 범위 설정.
			db.setGeoPtRange( db.RADIUS_CCTV_MATCH, nPosLat, nPosLng );		//CCTV 거리.
	
			//Match Making을 통해, 그룹에 소속된 교통정보들의 목록 검색..	
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableCctv;
			strQuery	= strQuery + " WHERE loc_lat >= " + db.mRange_lat_from + " AND loc_lat <= " + db.mRange_lat_to;
			strQuery	= strQuery + " AND loc_lng >= " + db.mRange_lng_from + " AND loc_lng <= " + db.mRange_lng_to;
			strQuery	= strQuery + " AND flag_deleted = 0";
			db.exec_query( strQuery );

			nCountCCTVs	= 0;
			
			long	cctv_id			= 0;
			int		cctv_pos_lat	= 0;
			int		cctv_pos_lng	= 0;
			String	url_iphone		= "";
			String	url_android		= "";
			while ( db.mDbRs.next() )
			{
				cctv_id			= db.mDbRs.getLong( "cctv_id" );
				cctv_pos_lat	= db.mDbRs.getInt( "loc_lat" );
				cctv_pos_lng	= db.mDbRs.getInt( "loc_lng" );
				url_iphone		= db.mDbRs.getString( "url_iphone" );
				url_android		= db.mDbRs.getString( "url_android" );

				list_cctv_id.add( cctv_id );
				list_cctv_lat.add( cctv_pos_lat );
				list_cctv_lng.add( cctv_pos_lng );
				list_url_iphone.add( url_iphone );
				list_url_android.add( url_android );

				//교통정보 개수 증가.
				nCountCCTVs++;
			}
			//System.out.println( "nCountCCTVs=" + nCountCCTVs );
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
	<cctv_count><%=nCountCCTVs%></cctv_count>
	<cctv_list>
<%
	for ( int i = 0; i < nCountCCTVs; i++ )
	{
%>
		<cctv>
			<cctv_id><%=list_cctv_id.get(i)%></cctv_id>
			<cctv_pos_lat><%=list_cctv_lat.get(i)%></cctv_pos_lat>
			<cctv_pos_lng><%=list_cctv_lng.get(i)%></cctv_pos_lng>
			<url_iphone><%=list_url_iphone.get(i)%></url_iphone>
			<url_android><%=list_url_android.get(i)%></url_android>
		</cctv>
<%
	}
%>
	</cctv_list>
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
		System.out.println( "[CCTV LIST]" + status_msg );
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