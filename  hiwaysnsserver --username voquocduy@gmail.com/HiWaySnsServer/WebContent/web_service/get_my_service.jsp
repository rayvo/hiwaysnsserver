<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%
	/*
	 * SNS 서버의  IP 주소 목록
	 */
	String[]	myServerList	=	{
										//"dogong.hscdn.com",		//효성 ITX 도메인.
/*		
										"dogong1.hscdn.com",	//효성 ITX 도메인.
										"dogong2.hscdn.com",	//효성 ITX 도메인.
										"dogong3.hscdn.com",	//효성 ITX 도메인.
*/
										"2.2.14.103",		//TODO CEWIT 개발서버.	
										//"211.56.151.87",		//TODO CEWIT 도공 서버.
										//"61.106.57.234",		//집-고정 IP.
										//"122.32.134.53",		//집-가변 IP.
									};





	/*
	 * 단말기의 주기적인 위치정보 갱신....
	 */
	int			status_code		= 0;		//작업처리결과 코드.
	String		status_msg		= "";		//작업처리결과 메시지.
	String		my_server		= "";		//SNS 서버의 IP 주소.
	int			count_polygon	= 0;		//서비스 영역 Polygon의 좌표 개수.
	
	try
	{
		/*
		 * 입력정보 처리.
		 */
		//Request 수신.
		System.out.println( "[GET MY SERVICE] Request received!" );
		//request.setCharacterEncoding( "utf-8" );
		String	strInputXml	= param.get_input_param( request.getParameter("xml") );

		//Request 메시지 필드목록.
		String[][]	inputList	=	{
										{ "user_id", "" },
										{ "timestamp", "" },
										{ "pos_lat", "" },
										{ "pos_lng", "" },
										{ "nickname", "" }
									};
		int		INDEX_USER_ID		= 0;
		int		INDEX_TIMESTAMP		= INDEX_USER_ID + 1;
		int		INDEX_POS_LAT		= INDEX_TIMESTAMP + 1;
		int		INDEX_POS_LNG		= INDEX_POS_LAT + 1;
		int		INDEX_NICKNAME		= INDEX_POS_LNG + 1;
	
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
		//(1) User ID가 unique 하지 않은 경우.
		String	strUserID	= inputList[INDEX_USER_ID][1];
		//System.out.println( "strActiveID=" + strActiveID + ", nPosLat=" + nPosLat + ", nPosLng=" + nPosLng );
		
		if ( db.isValidUserID(strUserID) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else
		{
			//DB 연결.
			db.db_open();

	 		long	currentTime	= db.getCurrentTimestamp();

			/*
			 * 주어진 User ID의 사용자가 존재하는지 검사한다.
			 */
			
			 
			/*
			 * 단말기 사용자에 할당되는 SNS 서버의  IP 주소 배정.
			 */
			int		countServers	= myServerList.length;
			int		pos				= (int)(currentTime % countServers);
			my_server	= myServerList[pos];
			
			//트랜잭션 시작.
			//db.tran_begin();
		}
		
		//응답 메시지 정보.
		String[][]	outputList	=	{
				/*
										{ "loc_lat", "1" },
										{ "loc_lng", "1" },
				 */
									};
//		if ( status_code != 0 )	System.out.println( status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<my_server><%=my_server%></my_server>
	<count_polygon><%=count_polygon%></count_polygon>
<%
	for ( int i = 0; i < outputList.length; i += 2 )
	{
%>
	<service_area_polygon>
		<<%=outputList[i][0]%>><%=outputList[i][1]%></<%=outputList[i][0]%>>
		<<%=outputList[i+1][0]%>><%=outputList[i+1][1]%></<%=outputList[i+1][0]%>>
	</service_area_polygon>
<%
	}
%>
</troasis>
<%
		//트랜잭션 Commit.
		//db.tran_commit();
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		//db.tran_rollback();
		
		//오류 메시지 출력.
		status_msg	= e.toString();
		System.out.println( "[GET MY SERVICE]" + status_msg );
%>
<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code>2</status_code>
	<status_msg><%=status_msg%></status_msg>
	<my_server><%=my_server%></my_server>
	<count_polygon>0</count_polygon>
</troasis>
<%
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>