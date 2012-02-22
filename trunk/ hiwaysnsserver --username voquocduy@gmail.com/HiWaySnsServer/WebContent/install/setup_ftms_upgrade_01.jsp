<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
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
	<title>FTMS 데이터 보정</title>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
</head>

<%@ page import	= "java.lang.*" %>
<%@ page import	= "java.lang.String.*" %>
<%@ page import	= "java.lang.Integer.*" %>
<%@ page import	= "java.sql.*" %>
<%@ page import = "java.io.*" %>

<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayDbServer" scope="page" />
<jsp:setProperty name="db" property="*" /> 

<body topmargin='20' leftmargin='20'>
<%
	out.println( "FTMS 데이터 보정!<br><br>" );

	try
	{
		//DB 연결.
		db.db_open();

		//트랜잭션 시작.
		db.tran_begin();
				
		/*
		 * 기존 데이터를 삭제하고, 신규로 데이터를 추가.
		 */
		String		query;
		
		/*
		//(1) FTMS 데이터 보정 : 현재 서버에 연결된 사용자 현황 목록
		String[]	list_ftms_data	= {
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('530','001000964','영천IC','경부고속도로','10','128951416.3','35922419.4')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('531','001004210','반포IC','경부고속도로','10','127018518.2','37503065.2')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('532','001004217','잠원IC','경부고속도로','10','127016220.6','37509227.2')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('533','0012100000','무안공항IC','무안광주고속도로','121','126390735.3','35002509.8')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('534','0014000000','고창JC','고창담양고속도로','140','126653063.3','35417178.3')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('535','0017000218','정남IC','평택오산고속도로','170','126971219.5','37184612.5')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('536','0017000271','봉담IC','평택오산고속도로','170','126956593.9','37229322.7')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('537','0020700609','장수JC','익산포항고속도로','207','129233274.5','36063269.45')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('538','0025201792','남논산TG','천안논산고속도로','252','127080250.6','36102839.8')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('539','0025202026','연무IC','천안논산고속도로','252','127060269.9','36147684.5')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('540','0025202198','서논산IC','천안논산고속도로','252','127053053.3','36224738.3')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('541','0025202198','탄천IC','천안논산고속도로','252','127067299.9','36298859.7')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('542','0025202221','탄천휴게소','천안논산고속도로','252','127070097.3','36319249.3')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('543','0025202260','이인휴게소','천안논산고속도로','252','127069674.4','36352942.8')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('544','0025202343','남공주IC','천안논산고속도로','252','127080852.3','36426532.7')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('545','0025202413','공주JC','천안논산고속도로','252','127091850.5','36485646.1')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('546','0025202513','정안휴게소','천안논산고속도로','252','128637162.6','35428471.2')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('547','0025202574','정안IC','천안논산고속도로','252','127120348.1','36625121.5')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('548','0025202718','풍세TG','천안논산고속도로','252','127157983.9','36737815.6')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('549','0025202738','남천안IC','천안논산고속도로','252','127163615.3','36748191.8')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('550','0025202763','천안JC','천안논산고속도로','252','127177228.9','36775781.4')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('551','0030000799','낙동JC','청원상주고속도로','300','128239297.3','36366139.4')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('552','0037003575','산곡JC','제2중부고속도로','370','127245454.6','37477187.2')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('553','045000000','내서JC','중부내륙고속도로','450','128515240.6','35258787.7')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('554','050002344','강릉JC','영동고속도로','500','128833692.3','37772845')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('555','060000616','조양IC','서울춘천고속도로','600','127787867.5','37756014.4')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('556','060000621','춘천JC','서울춘천고속도로','600','127793357.1','37749032.1')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('557','065000754','하조대IC','동해고속도로','650','128693509.9','38025314.1')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('558','102000186','창원JC','남해제1지선','1020','128642356.8','35275126.1')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('559','151000022','동서천JC','서천공주고속도로','1510','126772207.8','36062335.5')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('560','151000490','청양휴게소','서천공주고속도로','1510','126790822','36501791.8')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('561','151000614','서공주JC','서천공주고속도로','1510','127062488.2','36485608.2')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('562','251000539','회덕JC','호남지선','2510','127419244.1','36404568.1')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('563','300000208','비룡JC','대전남부순환선','3000','127482373.2','36345151')",
				"insert into troasis_ftms_traffic (id,agent_id,agent_name,road_name,road_no,loc_lat,loc_lng) values('564','551000082','양산JC','중앙지선','5510','129036772.3','35331762.2')",					
		};
		try
		{
			query	= "delete from troasis_ftms_traffic where id > 529";
			out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
			out.println( "<br>FTMS 보정 --> 기존 데이터 삭제." );
		}
		catch( Exception e ) { };

		for ( int i = 0; i < list_ftms_data.length; i++ )
		{
			query	= list_ftms_data[i];
			out.println( "<br>[QUERY] " + query );
			db.exec_update( query );
		}
		out.println( "<br>FTMS 보정 --> FTMS 데이터 추가." );
		*/

		 
		 
		 
		 
		
		//트랜잭션 Commit.
		db.tran_commit();

		//완료 메시지.
		out.println( "<br><br>성공적으로 FTMS 데이터를 보정했습니다." );
	}
	catch( Exception e )
	{
		//트랜잭션 Rollback.
		db.tran_rollback();

		//완료 메시지.
		out.println( "<br><br>FTMS 데이터를 보정하는 과정에서 오류가 발생 했습니다." );
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