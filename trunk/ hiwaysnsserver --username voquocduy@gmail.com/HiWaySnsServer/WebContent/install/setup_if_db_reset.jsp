<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file="../common/config.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false 	//시스템 관리자가 로그인 중이 아니라면
		|| loginManager.mRole < 1 )
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>
	<title>연계서버 데이터베이스 초기화</title>
	<meta http-equiv= "Content-Type" content="text/html; charset=utf-8">
</head>

<%@ page import	= "java.net.*" %>
<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.util.Date" %>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 

<% request.setCharacterEncoding( "utf-8" ); %>
<body topmargin='20' leftmargin='20'>
<%
	try
	{
		//DB 연결.
		db.db_open();
	
		//트랜잭션 시작.
		db.tran_begin();
				
		/*
		 * 기존 테이블을 삭제하고, 신규로 테이블 생성.
		 */
		String	query;

		
		
		/*
		 * 연계서버 데이터베이스 테이블.
		 */
		/*
		//(0110) 테이블 OPM_TRAFINFO : 문자정보표출.
		try
		{
			query	= "DROP TABLE OPM_TRAFINFO";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> OPM_TRAFINFO." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE OPM_TRAFINFO("; 
		query	= query + "  HQ_ID				VARCHAR(6) DEFAULT ''";			//본부 ID.
		query	= query + ", OCCUR_DTMC			VARCHAR(14) DEFAULT ''";		//발생시각.
		query	= query + ", USER_ID			VARCHAR(8) DEFAULT ''";			//사용자 ID.
		query	= query + ", CONZONE_ID			VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", ROUTE_NO			VARCHAR(4) DEFAULT ''";			//노선번호.
		query	= query + ", ROUTE_NM			VARCHAR(30) DEFAULT ''";		//노선명.
		query	= query + ", DISPLAY_DIR_CD		VARCHAR(1) DEFAULT ''";			//표출방향코드.
		query	= query + ", SEVRTY_LVL			VARCHAR(1) DEFAULT ''";			//심각도 레벨.
		query	= query + ", INC_ID				VARCHAR(17) DEFAULT ''";		//돌발상황 ID.
		query	= query + ", INC_TP_CD			VARCHAR(2) DEFAULT ''";			//돌발유형코드.
		query	= query + ", INC_TP_DESC		VARCHAR(300) DEFAULT ''";		//돌발상황유형설명.
		query	= query + ", INC_DTL_TP_CD		VARCHAR(1) DEFAULT ''";			//돌발상세유형코드.
		query	= query + ", INC_VEHCL_TP_CD	VARCHAR(2) DEFAULT ''";			//돌발상황차량유형코드
		query	= query + ", INC_VEHCL_DESC		VARCHAR(300) DEFAULT ''";		//돌발상황차량설명.
		query	= query + ", INC_RESPND_CD		VARCHAR(20) DEFAULT ''";		//돌발대응코드.
		query	= query + ", INC_POINT_NM		VARCHAR(100) DEFAULT ''";		//돌발지점명.
		query	= query + ", OCCUR_milepost		DOUBLE DEFAULT 0";				//발생이정.
		query	= query + ", START_NODE_ID		VARCHAR(13) DEFAULT ''";		//시작노드 ID.
		query	= query + ", START_POS			VARCHAR(50) DEFAULT ''";		//시작위치내용.
		query	= query + ", END_NODE_ID		VARCHAR(13) DEFAULT ''";		//종료노드ID.
		query	= query + ", END_POS			VARCHAR(50) DEFAULT ''";		//종료위치내용.
		query	= query + ", INC_PRGS_STATUS_CD	VARCHAR(2) DEFAULT ''";			//돌발진행상태코드.
		query	= query + ", UPD_TP_CD			VARCHAR(2) DEFAULT ''";			//갱신유형코드.
		query	= query + ", SHLDROAD_YN		VARCHAR(1) DEFAULT ''";			//갓길여부.
		query	= query + ", LANE_1_YN			VARCHAR(1) DEFAULT ''";			//1차로여부.
		query	= query + ", LANE_2_YN			VARCHAR(1) DEFAULT ''";			//2차로여부.
		query	= query + ", LANE_3_YN			VARCHAR(1) DEFAULT ''";			//3차로여부.
		query	= query + ", LANE_4_YN			VARCHAR(1) DEFAULT ''";			//4차로여부.
		query	= query + ", LANE_5_YN			VARCHAR(1) DEFAULT ''";			//5차로여부.
		query	= query + ", LANE_6_YN			VARCHAR(1) DEFAULT ''";			//6차로여부.
		query	= query + ", CONGSTN_LEN		DOUBLE DEFAULT 0";				//정체길이.
		query	= query + ", CHAR_CTNT			VARCHAR(100) DEFAULT ''";		//문자내용.
		query	= query + ", CLSRE_LANE_TYPE	VARCHAR(2) DEFAULT ''";			//차로폐쇄유형.
		query	= query + ", SMALL_VEHCL_CNT	INTEGER DEFAULT 0";				//소형차량수.
		query	= query + ", LARGE_VEHCL_CNT	INTEGER DEFAULT 0";				//중대형차량수.
		query	= query + ", VEHCL_OVERTURN_YN	VARCHAR(1) DEFAULT ''";			//차량전복여부.
		query	= query + ", FALL_YN			VARCHAR(1) DEFAULT ''";			//낙하물여부.
		query	= query + ", WCOND				VARCHAR(20) DEFAULT ''";		//기상.
		query	= query + ", DAYTIME_YN			VARCHAR(1) DEFAULT ''";			//주간여부.
		query	= query + ", REG_DTM			DATE";							//등록일시.
		query	= query + ", END_DTM			DATE";							//종료일시.
		query	= query + ", USE_YN				VARCHAR(1) DEFAULT ''";			//사용여부.
		query	= query + ", IF_CREATE_DT		VARCHAR(8) DEFAULT ''";			//연계정보생성일자.
		query	= query + ", IF_SEQ				INTEGER DEFAULT 0";				//연계정보순번.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> OPM_TRAFINFO." );

		
		//(0110-1) 테이블 CMM_NODE : CON죤 노드.
		try
		{
			query	= "DROP TABLE CMM_NODE";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_NODE." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_NODE("; 
		query	= query + "  NODE_ID				VARCHAR(13) DEFAULT ''";		//노드 ID.
		query	= query + ", NODE_NM			VARCHAR(50) DEFAULT ''";		//노드명.
		query	= query + ", NODE_TP_CD			VARCHAR(1) DEFAULT ''";			//노드윺형코드.		
		query	= query + ", ROAD_MILEPOST		DOUBLE DEFAULT 0";				//도로이정.
		query	= query + ", NODE_SHORTNM		VARCHAR(30) DEFAULT ''";		//노드단축명.
		query	= query + ", LATD				DOUBLE DEFAULT 0";				//위도.
		query	= query + ", LONGD				DOUBLE DEFAULT 0";				//경도.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_NODE." );

		
		//(0120) 테이블 TSM_VMS_EQUIP_CONFIG		: VMS 장비구성.
		try
		{
			query	= "DROP TABLE TSM_VMS_EQUIP_CONFIG";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TSM_VMS_EQUIP_CONFIG." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TSM_VMS_EQUIP_CONFIG("; 
		query	= query + "  VMS_ID				VARCHAR(12) DEFAULT ''";		//VMS_ID.
		query	= query + ", ROUTE_NO			DOUBLE DEFAULT 0";				//노선번호.
		query	= query + ", AREA_HQ_ID			VARCHAR(6) DEFAULT ''";			//지역본부ID.		
		query	= query + ", BRANCH_CD			VARCHAR(6) DEFAULT ''";			//지사코드.
		query	= query + ", UPDOWN_DIV			VARCHAR(1) DEFAULT ''";			//시종점구분.
		query	= query + ", VMS_NO				DOUBLE DEFAULT 0";				//장비식별번호.
		query	= query + ", VMS_DESC			VARCHAR(300) DEFAULT ''";		//VMS설명.		
		query	= query + ", milepost			DOUBLE DEFAULT 0";				//이정.
		query	= query + ", HORZ_PIXELS		DOUBLE DEFAULT 0";				//가로픽셀수.
		query	= query + ", VERT_PIXELS		DOUBLE DEFAULT 0";				//세로픽셀수.
		query	= query + ", COMM_MTHD_ID		VARCHAR(1) DEFAULT ''";			//통신방법코드.
		query	= query + ", VMS_TP				VARCHAR(1) DEFAULT ''";			//VMS타입.
		query	= query + ", EQUIP_IP			VARCHAR(15) DEFAULT ''";		//장비IP.
		query	= query + ", COMM_PORT			DOUBLE DEFAULT 0";				//통신PORT.
		query	= query + ", VRSN_NO			DOUBLE DEFAULT 0";				//버전번호.
		query	= query + ", USE_YN				VARCHAR(1) DEFAULT ''";			//사용여부.
		query	= query + ", ACCPT_YN			VARCHAR(1) DEFAULT ''";			//수용여부.
		query	= query + ", VMS_OPMETHOD_NO	VARCHAR(2) DEFAULT ''";			//VMS운영방식번호.
		query	= query + ", CONGSTN_ZONE_ID	VARCHAR(10) DEFAULT ''";		//정체존ID.
		query	= query + ", VDS_ID				VARCHAR(12) DEFAULT ''";		//VDS_ID.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TSM_VMS_EQUIP_CONFIG." );
		
		//(0121) 테이블 OPM_TRAFINFO : VMS 현재표출문안.

		
		
		//(0130) 테이블 TCM_VDSCONFIG : VDS 구성정보.
		try
		{
			query	= "DROP TABLE TCM_VDSCONFIG";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TCM_VDSCONFIG." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TCM_VDSCONFIG("; 
		query	= query + "VDS_ID				VARCHAR(12) DEFAULT ''";		//VDS ID.
		query	= query + ", INSTL_milepost		DOUBLE DEFAULT 0";				//설치이정.
		query	= query + ", CAMERA1_ID			VARCHAR(11) DEFAULT ''";		//카메라1 ID.
		query	= query + ", CAMERA2_ID			VARCHAR(11) DEFAULT ''";		//카메라2 ID.
		query	= query + ", LANE_CNT			INTEGER DEFAULT 0";				//차로수.
		query	= query + ", DOWNSTREAM_VDS_ID	VARCHAR(12) DEFAULT ''";		//하류 VDS ID.
		query	= query + ", SHOULDER__FLAG		VARCHAR(1) DEFAULT ''";			//갓길플래그.
		query	= query + ", SPEED_STATION_FLAG	INTEGER DEFAULT 0";				//SPEED_STATION_FLAG.
		query	= query + ", ALARM_NUM			VARCHAR(5) DEFAULT ''";			//ALARM_NUM.
		query	= query + ", INTIME				DATE";							//정보등록시간.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TCM_VDSCONFIG." );

		
		
		//(0135) 테이블 VW_TPS_VDS5MIN : VDS죤 5분통계.
		try
		{
			query	= "DROP TABLE VW_TPS_VDS5MIN";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> VW_TPS_VDS5MIN." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE VW_TPS_VDS5MIN("; 
		query	= query + "ST_YMDHM				VARCHAR(12) DEFAULT ''";		//통계년월일시분.
		query	= query + ", VDS_ID				VARCHAR(12) DEFAULT ''";		//VDS ID.
		query	= query + ", VOL				DOUBLE DEFAULT 0";				//교통량.
		query	= query + ", SPD				DOUBLE DEFAULT 0";				//속도.
		query	= query + ", OCC				DOUBLE DEFAULT 0";				//점유율.
		query	= query + ", DWEEK_CD			VARCHAR(1) DEFAULT ''";			//요일코드.
		query	= query + ", N_DATA_INUM		INTEGER DEFAULT 0";				//정상계수.
		query	= query + ", ADJ_CNT			INTEGER DEFAULT 0";				//보정계수.
		query	= query + ", TRAVL_TM			INTEGER DEFAULT 0";				//통행시간.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> VW_TPS_VDS5MIN." );

		
		
		//(0140) 테이블 CMM_CONZONE : CON죤.
		try
		{
			query	= "DROP TABLE CMM_CONZONE";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_CONZONE." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_CONZONE("; 
		query	= query + "CONGSTN_ZONE_ID		VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", ROUTE_NO			VARCHAR(4) DEFAULT ''";			//노선번호.
		query	= query + ", LINK_LEN			INTEGER DEFAULT 0";				//존길이.
		query	= query + ", BUSLANE_YN			VARCHAR(1) DEFAULT ''";			//버스전용차로유무.
		query	= query + ", UPDOWN_DIV			VARCHAR(1) DEFAULT ''";			//방향구분코드.
		query	= query + ", START_NODE_ID		VARCHAR(13) DEFAULT ''";		//시작노드ID.
		query	= query + ", END_NODE_ID		VARCHAR(13) DEFAULT ''";		//종료노드ID.
		query	= query + ", LANE_CNT			INTEGER DEFAULT 0";				//차로수.
		query	= query + ", RESTRCT_SPD		DOUBLE DEFAULT 0";				//제하속도.
		query	= query + ", ROUTE_CONF_SERIALNUM	INTEGER DEFAULT 0";			//노선구성 일련번호.
		query	= query + ", CONZONE_NM			VARCHAR(50) DEFAULT ''";		//정체존명.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_CONZONE." );
		
		//(0140-2) 테이블 CMM_ConZone2VDS : ConZone_VDS 매핑정보.
		try
		{
			query	= "DROP TABLE CMM_ConZone2VDS";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_ConZone2VDS." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_ConZone2VDS("; 
		query	= query + "CONGSTN_ZONE_ID		VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", VDS_ID				VARCHAR(12) DEFAULT ''";		//VDS ID.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_ConZone2VDS." );

		
		
		//(0141) 테이블 TPG_CONZONEEMIN : CON죤 소통현황.
		try
		{
			query	= "DROP TABLE TPG_CONZONEEMIN";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TPG_CONZONEEMIN." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TPG_CONZONEEMIN("; 
		query	= query + "CONGSTN_ZONE_ID		VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", ANAL_DTMC			VARCHAR(14) DEFAULT ''";		//분석시각.
		query	= query + ", SPD				DOUBLE DEFAULT 0";				//속도.
		query	= query + ", VOL				DOUBLE DEFAULT 0";				//교통량.
		query	= query + ", TRAVL_TM			INTEGER DEFAULT 0";				//여행시간.
		query	= query + ", TRFICS_GRADE		INTEGER DEFAULT 0";				//소통등급.
		query	= query + ", CONGSTN_LEN		DOUBLE DEFAULT 0";				//정체길이.
		query	= query + ", COLCTR_TP_CD		VARCHAR(2) DEFAULT ''";			//수집원유형코드.	
		query	= query + ", DTCT_NO			INTEGER DEFAULT 0";				//정체감시번호.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TPG_CONZONEEMIN." );

		
		
		//(0142) 테이블 TPG_CONZONELTYPEMIN : CON죤 차로유형소통현황.
		try
		{
			query	= "DROP TABLE TPG_CONZONELTYPEMIN";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TPG_CONZONELTYPEMIN." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TPG_CONZONELTYPEMIN("; 
		query	= query + "CONGSTN_ZONE_ID		VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", LANE_TP_CD			VARCHAR(1) DEFAULT ''";			//차로유형코드.	
		query	= query + ", ANAL_DTMC			VARCHAR(14) DEFAULT ''";		//분석시각.
		query	= query + ", SPD				DOUBLE DEFAULT 0";				//속도.
		query	= query + ", VOL				DOUBLE DEFAULT 0";				//교통량.
		query	= query + ", TRAVL_TM			INTEGER DEFAULT 0";				//여행시간.
		query	= query + ", TRFICS_GRADE		INTEGER DEFAULT 0";				//소통등급.
		query	= query + ", CONGSTN_LEN		DOUBLE DEFAULT 0";				//정체길이.
		query	= query + ", COLCTR_TP_CD		VARCHAR(2) DEFAULT ''";			//수집원유형코드.	
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TPG_CONZONELTYPEMIN." );

		
		
		//(0143) 테이블 CMM_HWSTDLINK : 고속도로 표준링크 매칭.
		try
		{
			query	= "DROP TABLE CMM_HWSTDLINK";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_HWSTDLINK." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_HWSTDLINK("; 
		query	= query + "CONZONE_ID			VARCHAR(10) DEFAULT ''";		//정체존 ID.
		query	= query + ", STD_LINK_ID		VARCHAR(10) DEFAULT ''";		//표준링크ID.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_HWSTDLINK." );

		
		
		//(0150) 테이블 CMM_DSRCLINK : DSRC_구간.
		try
		{
			query	= "DROP TABLE CMM_DSRCLINK";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_DSRCLINK." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_DSRCLINK("; 
		query	= query + "DSRC_SECT_ID			VARCHAR(10) DEFAULT ''";		//DSRC구간ID.
		query	= query + ", START_RSE_ID		VARCHAR(13) DEFAULT ''";		//시작RSEID.
		query	= query + ", END_RSE_ID			VARCHAR(13) DEFAULT ''";		//종료RSEID.
		query	= query + ", LINK_LEN			DOUBLE DEFAULT 0";				//링크길이.
		query	= query + ", DSRC_SECT_TP_CD	VARCHAR(2) DEFAULT ''";			//DSRC구간유형코드.
		query	= query + ", ROUTE_CONF_SERIALNUM	INTEGER DEFAULT 0";			//노선구성일련번호.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_DSRCLINK." );
		
		//(0150-1) 테이블 CMM_LINKDSRC : DSRC구간구성.
		try
		{
			query	= "DROP TABLE CMM_LINKDSRC";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_LINKDSRC." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_LINKDSRC("; 
		query	= query + "DSRC_SECT_ID			VARCHAR(10) DEFAULT ''";		//DSRC구간ID.
		query	= query + ", CONGSTN_ZONE_ID	VARCHAR(10) DEFAULT ''";		//CONZONE_ID.
		query	= query + ", CONZONE_APPRATE	DOUBLE DEFAULT 0";				//CONZONE적용율.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_LINKDSRC." );
		
		//(0150-2) 테이블 TCM_DSRC_MGT_RSE : 노변기지국정보.
		try
		{
			query	= "DROP TABLE TCM_DSRC_MGT_RSE";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TCM_DSRC_MGT_RSE." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TCM_DSRC_MGT_RSE("; 
		query	= query + "RSE_ID				VARCHAR(13) DEFAULT ''";		//RSE_ID.
		query	= query + ", POS_NM				VARCHAR(20) DEFAULT ''";		//위치명.
		query	= query + ", ROAD_milepost		DOUBLE DEFAULT 0";				//도로이정.
		query	= query + ", RSE_INSTL_POS_DIV_CD	VARCHAR(1) DEFAULT ''";		//RSE위치구분.
		query	= query + ", ROUTE_NO			INTEGER DEFAULT 0";				//노선번호.
		query	= query + ", POS_SHORTNM		VARCHAR(20) DEFAULT ''";		//위치단축명.
		query	= query + ", LATD				DOUBLE DEFAULT 0";				//위도.
		query	= query + ", LONGD				DOUBLE DEFAULT 0";				//경도.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TCM_DSRC_MGT_RSE." );

		
		
		//(0151) 테이블 TPG_DSRCTRAVELTIME : DSRC구간통행시간정보.
		try
		{
			query	= "DROP TABLE TPG_DSRCTRAVELTIME";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TPG_DSRCTRAVELTIME." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TPG_DSRCTRAVELTIME("; 
		query	= query + "ANAL_DTMC			VARCHAR(14) DEFAULT ''";		//분석시각.
		query	= query + ", DSRC_SECT_ID		VARCHAR(10) DEFAULT ''";		//DSRC구간ID.
		query	= query + ", BUS_GEN_DIV		VARCHAR(1) DEFAULT ''";			//버스일반구분.
		query	= query + ", AVG_TRAVL_TM		INTEGER DEFAULT 0";				//평균통행시간.
		query	= query + ", MAX_TRAVL_TM		INTEGER DEFAULT 0";				//최대통행시간.
		query	= query + ", MIN_TRAVL_TM		INTEGER DEFAULT 0";				//최소통행시간.
		query	= query + ", MED_TRAVL_TM		INTEGER DEFAULT 0";				//중위통행시간.
		query	= query + ", ALLDATA_CNT		INTEGER DEFAULT 0";				//전체데이터수.
		query	= query + ", USEDATA_CNT		INTEGER DEFAULT 0";				//사용데이터수.
		query	= query + ", SPD				DOUBLE DEFAULT 0";				//속도.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TPG_DSRCTRAVELTIME." );

		
		
		//(0180) 테이블 TPG_STDLINKOFFERTRFICS : 표준링크 제공소통정보.
		try
		{
			query	= "DROP TABLE TPG_STDLINKOFFERTRFICS";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TPG_STDLINKOFFERTRFICS." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TPG_STDLINKOFFERTRFICS("; 
		query	= query + "COLCT_DTMC			VARCHAR(14) DEFAULT ''";		//수집시각.
		query	= query + ", STD_LINK_ID		VARCHAR(10) DEFAULT ''";		//표준링크ID.
		query	= query + ", SPD				DOUBLE DEFAULT 0";				//속도.
		query	= query + ", VOL				DOUBLE DEFAULT 0";				//교통량.
		query	= query + ", TRAVL_TM			INTEGER DEFAULT 0";				//통행시간.
		query	= query + ", OCC				DOUBLE DEFAULT 0";				//점유율.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TPG_STDLINKOFFERTRFICS." );

		
		
		//(0181) 테이블 CMM_INTERCITYROUTE : 도시간경로.
		try
		{
			query	= "DROP TABLE CMM_INTERCITYROUTE";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_INTERCITYROUTE." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_INTERCITYROUTE("; 
		query	= query + "CITY_PATH_NO			VARCHAR(6) DEFAULT ''";			//도시경로번호.
		query	= query + ", CITY_TRAVL_NO		VARCHAR(4) DEFAULT ''";			//도시통행번호.
		query	= query + ", PATH_NM			VARCHAR(40) DEFAULT ''";		//경로명.
		query	= query + ", PATH_LEN			DOUBLE DEFAULT 0";				//경로길이.
		query	= query + ", EXT_CONND_PATH_NO	VARCHAR(2) DEFAULT ''";			//외부연계경로번호.
		query	= query + ", EXT_CONND_DIR_NO	VARCHAR(2) DEFAULT ''";			//외부연계방향번호.
		query	= query + ", EXT_CONND_REPRE_PATH_YN	VARCHAR(1) DEFAULT ''";		//외부연계대표경로여부.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_INTERCITYROUTE." );
		
		//(0181-1) 테이블 TPG_INTERCITYTRAVELTIME : 도시간통행시간.
		try
		{
			query	= "DROP TABLE TPG_INTERCITYTRAVELTIME";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> TPG_INTERCITYTRAVELTIME." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE TPG_INTERCITYTRAVELTIME("; 
		query	= query + "CITY_PATH_NO			VARCHAR(6) DEFAULT ''";			//도시경로번호.
		query	= query + ", ANAL_DTMC			VARCHAR(14) DEFAULT ''";		//분석시각.
		query	= query + ", TRAVL_TM			INTEGER DEFAULT 0";				//통행시간.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> TPG_INTERCITYTRAVELTIME." );

		
		
		//(0182) 테이블 CMM_INTERCITY_ROUTE_MAPPING : 도시간경로_노선매핑정보.
		try
		{
			query	= "DROP TABLE CMM_INTERCITY_ROUTE_MAPPING";
			//out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>테이블 삭제 --> CMM_INTERCITY_ROUTE_MAPPING." );
		}
		catch( Exception e ) { };

		query	= "CREATE TABLE CMM_INTERCITY_ROUTE_MAPPING("; 
		query	= query + "CITY_PATH_NO			VARCHAR(6) DEFAULT ''";			//도시경로번호.
		query	= query + ", ROUTE_NO			VARCHAR(4) DEFAULT ''";			//노선번호.
		query	= query + ", ROAD_GRADE			VARCHAR(5) DEFAULT ''";			//도로등급.
		query	= query + " ) ";
		//out.println( "<br>[QUERY] " + query );
		db.exec_update( query );
		out.println( "<br>테이블 생성 --> CMM_INTERCITY_ROUTE_MAPPING." );
		*/

		
		
		
		//트랜잭션 Commit.
		db.tran_commit();	
		
		//완료 메시지.
		out.println( "<br><br>성공적으로 데이터베이스를 초기화 했습니다." );
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();

		//완료 메시지.
		out.println( "<br><br>데이터베이스를 초기화 하는 과정에서 오류가 발생 했습니다." );
		out.println( e.toString() );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
	<br><br>
	<a href="setup_db_main.jsp">돌아가기</a>
</body>
</html>