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


		
		// 정보 제공을 위한 리스트 선언

		List<String>	list_changed_cctv_id	= new ArrayList<String>();		
		List<String>	list_cctv_loc			= new ArrayList<String>();
	 	List<Integer>	list_cctv_lat			= new ArrayList<Integer>();
	 	List<Integer>	list_cctv_lng			= new ArrayList<Integer>();
		List<Integer>	list_changed_type		= new ArrayList<Integer>();
		List<Integer>	list_road_no  			= new ArrayList<Integer>();
		List<String>	list_cctv_address		= new ArrayList<String>();
	 	List<Integer>	list_changed_count		= new ArrayList<Integer>();
		List<String>	list_cctv_url			= new ArrayList<String>();
		List<Integer>	list_cctv_status		= new ArrayList<Integer>();
		List<Integer>	list_changed_number		= new ArrayList<Integer>();
		List<Integer>	list_deleted_number		= new ArrayList<Integer>();
		List<Integer>	list_deleted_type		= new ArrayList<Integer>();
		List<String>	list_deleted_cctv_id	= new ArrayList<String>();	
		

	
		//(1) User ID가 unique 하지 않은 경우.
	
		if ( db.isValidActiveID(strUserID, strActiveID) == false )
		{
			status_code	= db.status_code;
			status_msg	= db.status_msg;
		}
		else	
		{
			String	strQuery;
			String	strTableNationalCCTVinfo	= "national_cctv_info";
			String	strTableCCTVModificationLog	= "cctv_modification_log";
			String[]	changed_cctv_id	 = new String[60];
			String[]    deleted_cctv_id     =  new String[60];
			int last_changed_number=0;
			
			int total_changes = 0;
			int last_change =0;

						
			db.db_open();
					
			strQuery = "SELECT count(*) ";
			strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
			
			db.exec_query( strQuery );
			
			if( db.mDbRs.next() ) 
			{
				total_changes = db.mDbRs.getInt(1);
			}
		
			last_changed_number =  Integer.parseInt(number);
		
			
			strQuery = "SELECT count(DISTINCT cctv_id)";
			strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
			strQuery = strQuery + " WHERE changed_number >= " + last_changed_number; 
			strQuery = strQuery + " AND changed_number <= " + total_changes; 
			db.exec_query( strQuery );
			
			if( db.mDbRs.next() ) 
			{
				change_count = db.mDbRs.getInt(1);
			}
			
			change_count = total_changes - last_changed_number;
		
			
			System.out.println( "total  :" + total_changes);
			System.out.println( "change count  :" + change_count);

			if (change_count==0)  // 변경이 없는 경우
			{
				status_msg = "Your cctv list is newest one, no need to update~!";
			}
			
			else if (change_count >0) //변경이 있는 경우
			{	
				
				
				///////////////// 기존의 cctv_id 가 삭제된 경우  /////////////////////////////////////
				strQuery = "SELECT DISTINCT cctv_id";
				strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
				strQuery = strQuery + " WHERE changed_number > " + last_changed_number; 
				strQuery = strQuery + " AND changed_number <= " + total_changes; 
				strQuery = strQuery + " AND changed_type = 2"; 
				db.exec_query( strQuery );
				
				while( db.mDbRs.next() ) 
				{
					index_d++;
					deleted_cctv_id[index_d] =  db.mDbRs.getString(1);
					
				}
				
				///////////////////////////기존의 cctv 정보가 변경 및 추가 된 겨우
				strQuery = "SELECT DISTINCT cctv_id";
				strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
				strQuery = strQuery + " WHERE changed_number >= " + last_changed_number; 
				strQuery = strQuery + " AND changed_number <= " + total_changes; 
				strQuery = strQuery + " AND changed_type = 1 OR changed_type =3"; 
				
				db.exec_query( strQuery );

				while(db.mDbRs.next())
				{
					index_m ++;
					changed_cctv_id[index_m] =  db.mDbRs.getString(1);		
					
				}

			}
			
			else
			{
				status_code =2;
				status_msg = "Request Error~!";
			}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	

			for (int g=0; g<=index_m; g++)
			{
				
				strQuery = "SELECT changed_number, changed_type";
				strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
				strQuery = strQuery + " WHERE cctv_id = '"+ changed_cctv_id[g] +"'";
	
				db.exec_query( strQuery );	
				
				while ( db.mDbRs.next() )
				{	
					int changed_number = 0;
					int changed_type = 0;
					
					changed_number=db.mDbRs.getInt("changed_number");
					changed_type=db.mDbRs.getInt("changed_type");
					
					list_changed_number.add(changed_number);
					list_changed_type.add(changed_type);
				}
								
				strQuery = "SELECT * ";
				strQuery = strQuery + " FROM " + strTableNationalCCTVinfo;
				strQuery = strQuery + " WHERE cctv_id = '"+ changed_cctv_id[g] +"'";
	
				db.exec_query( strQuery );	
				
				while ( db.mDbRs.next() )
				{	
					String cctv_id = "";
					int cctv_lat = 0;
					int cctv_lng =0;
					int road_no =0;
					int cctv_status = 0;
					String cctv_loc ="";
					String cctv_address="";
					String cctv_url="";
				
					cctv_id			= db.mDbRs.getString( "cctv_id");
					cctv_lat	= db.mDbRs.getInt( "cctv_lat" );
					cctv_lng	= db.mDbRs.getInt( "cctv_lng" );
					road_no	    =  db.mDbRs.getInt( "road_no") ;
					cctv_url		= db.mDbRs.getString( "cctv_url");
					cctv_loc		= db.mDbRs.getString( "cctv_loc" );
					cctv_address		= db.mDbRs.getString( "cctv_address");
					cctv_status 	= db.mDbRs.getInt("status");
	
					list_changed_cctv_id.add( cctv_id );
					list_cctv_url.add( cctv_url );
					list_cctv_loc.add( cctv_loc);
					list_cctv_lng.add( cctv_lng );
					list_cctv_lat.add( cctv_lat );
					list_road_no.add( road_no );
					list_cctv_address.add( cctv_address );
					list_road_no.add( road_no );
					list_cctv_status.add(cctv_status);
	
				}
			}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			for (int k=0; k<=index_d; k++)
			{
				
				strQuery = "SELECT changed_number, changed_type";
				strQuery = strQuery + " FROM " + strTableCCTVModificationLog;
				strQuery = strQuery + " WHERE cctv_id = '"+ deleted_cctv_id[k] +"'";
				strQuery = strQuery + " AND changed_type = 2";
				
				db.exec_query( strQuery );	
				
				while ( db.mDbRs.next() )
				{	
					int changed_number = 0;
					int changed_type = 0;
	
					changed_number=db.mDbRs.getInt("changed_number");
					changed_type=db.mDbRs.getInt("changed_type");
					
					list_deleted_cctv_id.add( deleted_cctv_id[k]);
					list_deleted_number.add(changed_number);
					list_deleted_type.add(changed_type);
				}								
			}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			
			if ( status_code != 0 )	System.out.println( status_msg );
		}

%>

<?xml version="1.0" encoding="UTF-8"?>
<troasis>
	<status_code><%=status_code%></status_code>
	<status_msg><%=status_msg%></status_msg>
	<active_id><%=strActiveID%></active_id>
	<cctv_changed_count><%=change_count%></cctv_changed_count>
	<cctv_changed_list>
<%
	for ( int i = 0; i < index_m; i++ )
	{
%>

		<cctv_changed>
			 <cctv_id><%=list_changed_cctv_id.get(i)%></cctv_id>      
             <road_no><%=list_road_no.get(i) %></road_no>
             <location><%=list_cctv_loc.get(i)%></location>
             <cctv_lng><%=list_cctv_lng.get(i)%></cctv_lng>
             <cctv_lat><%=list_cctv_lat.get(i)%></cctv_lat>
             <url><%=list_cctv_url.get(i)%></url>
             <cctv_status><%=list_cctv_status.get(i)%></cctv_status>
             <address><%=list_cctv_address.get(i)%></address>
             <changed_number><%=list_changed_type.get(i)%></changed_number>
             <changed_type><%=list_changed_type.get(i)%></changed_type>                                                
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