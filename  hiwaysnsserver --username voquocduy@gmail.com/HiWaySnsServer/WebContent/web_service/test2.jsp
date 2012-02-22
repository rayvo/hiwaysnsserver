<%@page import="kr.co.ex.hiwaysns.TroasisCCTV"%>
<%@page import="kr.co.ex.hiwaysns.TrOASISCCTVLog"%>
<%@ page language="java" contentType="text/xml; charset=utf-8" pageEncoding="utf-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="../common/config.jsp"%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />

<%@	page	import ="java.util.*"	%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"	%>

<%

	/*
	 * CCTV 변경 리스트 제공...
	*/

	int			status_code	= 0;		//작업처리결과 코드.
	String		status_msg	= "";		//작업처리결과 메시지.
	int index_m =0;
	int index_d =0;
	int change_count = 0;
	int total_changes= 0;
	
	try

	{
		/*
		 * 입력정보 처리.
		 */

		//Request 수신.
		//System.out.println( "[REQUEST CCTV CHANGE] Request received!" );
		//request.setCharacterEncoding( "utf-8" );

		String	strInputXml	= param.get_input_param( request.getParameter("xml") );
		//Request 메시지 필드목록.
		
		String[][]	inputList	=	{
										{ "active_id", "" },
										{ "user_id", "" },
										{ "number", "" },
									};

		int		INDEX_ACTIVE_ID		= 0;
		int		INDEX_USER_ID		= INDEX_ACTIVE_ID + 1;
		int		INDEX_LAST_NUMBER		= INDEX_USER_ID + 1;


		//Request 메시지 파싱.
		System.out.println( "xml=" + strInputXml );
		inputList	= xmlGen.parseInputXML( strInputXml, inputList );
		//for ( int i = 0; i < inputList.length; i++ ) System.out.println( inputList[i][0] + " = " + inputList[i][1] );
		
		String	strUserID	= inputList[INDEX_USER_ID][1];
		String	strActiveID	= inputList[INDEX_ACTIVE_ID][1];
		String  number	= inputList[INDEX_LAST_NUMBER][1];
		if (number.trim().equals("")) {
			number = "0";
		}

		// 정보 제공을 위한 리스트 선언

			String	strQuery;
			String	strTableNationalCCTVinfo	= "national_cctv_info";
			String	strTableCCTVModificationLog	= "cctv_modification_log";

			List<TrOASISCCTVLog> changed_cctv = new ArrayList<TrOASISCCTVLog>();
			
			int last_changed_number=0;
			
			int last_change =0;

						
			db.db_open();
			
			strQuery = "SELECT * FROM " + strTableCCTVModificationLog;
			strQuery = strQuery + " WHERE changed_number > " + number + " ORDER BY changed_number";			
			
			db.exec_query( strQuery );
			
			TrOASISCCTVLog troasisLog = null;
			
			while( db.mDbRs.next() ) 
			{			
				troasisLog = new TrOASISCCTVLog();
				troasisLog.setId(db.mDbRs.getInt("id"));
				troasisLog.setCctv_id(db.mDbRs.getString("cctv_id"));
				troasisLog.setChanged_type(db.mDbRs.getInt("changed_type"));
				troasisLog.setChanged_number((db.mDbRs.getInt("changed_number")));
				troasisLog.setUpdated_time(db.mDbRs.getString("updated_time"));
				changed_cctv.add(troasisLog);	
				total_changes++;
			}
			
			List<String> cctvDelList1 = new ArrayList<String>();
			Iterator<TrOASISCCTVLog> iterator = changed_cctv.iterator();
			while (iterator.hasNext()){
				TrOASISCCTVLog log = (TrOASISCCTVLog) iterator.next();
				if (log.getChanged_type() == 2) {
					
					cctvDelList1.add(log.getCctv_id());
				}
			}
			
			List<String> cctvDelList2 = new ArrayList<String>();
			iterator = changed_cctv.iterator();
			while (iterator.hasNext()){
				TrOASISCCTVLog log = (TrOASISCCTVLog) iterator.next();
				if (log.getChanged_type() == 1) {
					for (int i=0; i<changed_cctv.size(); i++) {
						TrOASISCCTVLog tmpLog = changed_cctv.get(i);
						if(log.getCctv_id().equals(tmpLog.getCctv_id()) 
								&& tmpLog.getChanged_type() == 2
								&& log.getChanged_number() < tmpLog.getChanged_number()) {
							cctvDelList2.add(tmpLog.getCctv_id());
						}
					}					
				}
			}
			
				
			//Delete Filtering
			List<TrOASISCCTVLog> finalLogList1 = new ArrayList<TrOASISCCTVLog>();
			for (int j=0; j<changed_cctv.size();j++){
				TrOASISCCTVLog log = changed_cctv.get(j);
				boolean flag = true;
				for (int i=0; i<cctvDelList2.size();i++){					
					String cctvId = cctvDelList2.get(i);
					if (log.getCctv_id().equals(cctvId))
					{
						flag = false;
						break;
					}					
				}
				if (flag) {
					finalLogList1.add(log);
				}
			}
			//Modify Filtering
			List<TrOASISCCTVLog> finalLogList2 = new ArrayList<TrOASISCCTVLog>();
			for (int z=0; z<finalLogList1.size();z++){
				TrOASISCCTVLog log1 = finalLogList1.get(z);
				boolean flag = true;
				for (int i=0; i<finalLogList2.size();i++){					
					TrOASISCCTVLog log2 = finalLogList2.get(i);
					if (log1.getCctv_id().equals(log2.getCctv_id()))
					{
						flag = false;
						if (log1.getChanged_number() > log2.getChanged_number()) {
							log2.setChanged_number(log1.getChanged_number());
						}
						break;
					}					
				}
				if (flag) {
					finalLogList2.add(log1);
				}
			}
			
			List<TroasisCCTV> finalCCTVList = new ArrayList<TroasisCCTV>();
			change_count = finalLogList2.size();
			for (int k=0; k<finalLogList2.size();k++){
				TrOASISCCTVLog log = finalLogList2.get(k);
				if (log.getChanged_type()==2){
					TroasisCCTV troasis = new TroasisCCTV();
					troasis.setCctvId(log.getCctv_id());
					finalCCTVList.add(troasis);
				} else {					
					strQuery = "SELECT * ";
					strQuery = strQuery + " FROM " + strTableNationalCCTVinfo;
					strQuery = strQuery + " WHERE cctv_id = '"+ log.getCctv_id() +"'";
		
					db.exec_query( strQuery );	
					
					while ( db.mDbRs.next() )
					{	
						TroasisCCTV troasis = new TroasisCCTV();
						
						// troasis.setId(); //Esther deleted
						troasis.setCctvId(db.mDbRs.getString("cctv_id"));
						troasis.setRoadNo(db.mDbRs.getInt("road_no"));
						troasis.setCctvLoc(db.mDbRs.getString("cctv_loc"));
						troasis.setCctvLng(db.mDbRs.getInt("cctv_lng"));
						troasis.setCctvLat(db.mDbRs.getInt("cctv_lat"));
						troasis.setCctvURL(db.mDbRs.getString("cctv_url"));						
						troasis.setCctvAddress(db.mDbRs.getString("cctv_address"));						
						
						finalCCTVList.add(troasis);
					}
				}
			}
			
			

%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<active_id><%=strActiveID%></active_id>
	<cctv_changed_total><%=total_changes%></cctv_changed_total>
	<cctv_changed_count><%=change_count%></cctv_changed_count>
	<cctv_changed_list>
<%
	for ( int i = 0; i < finalLogList2.size(); i++ )
	{
		TrOASISCCTVLog log = finalLogList2.get(i);	
		TroasisCCTV cctv = finalCCTVList.get(i);
%>
	
	
		<cctv_changed>
			 <changed_number><%=log.getChanged_number()%></changed_number>             
			 <cctv_id><%=log.getCctv_id()%></cctv_id>      
			 <changed_type><%=log.getChanged_type()%></changed_type>
			 
<%
		if (log.getChanged_type() != 2){			 
 %>
             <road_no><%=cctv.getRoadNo() %></road_no>
             <location><%=cctv.getCctvLoc()%></location>
             <cctv_lng><%=cctv.getCctvLng()%></cctv_lng>
             <cctv_lat><%=cctv.getCctvLat()%></cctv_lat>
             <url><%=cctv.getCctvURL()%></url>
             <address><%=cctv.getCctvAddress()%></address>
<%
		}
%>
		</cctv_changed>
<%
	}
%>
	</cctv_changed_list>
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
		System.out.println( "[CHANGED CCTV INFO LIST]" + status_msg );
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