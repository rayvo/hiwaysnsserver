<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import ="java.util.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.lang.String.*"%>
<%@ page import="java.lang.Integer.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Locale"%>
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="kr.co.ex.hiwaysns.*"%>
<%@ page import="java.text.*"%>
<%@	page import ="kr.co.ex.hiwaysns.lib.*"	%>
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page"/>
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>사용자 랭킹 현황</title>
</head>
<script type="text/javascript">
//<!--
//-->
</script>

<%
	//입력정보 수신.
	int		count		= 0;
	int		sort_order	= 0;
	
	String	strParam	= "";
	strParam	= param.get_input_param( request.getParameter("sort_order") );

%>
<body>
		<table width="1250">
		<tr height="4"><td colspan="21" background="images/dot.gif"></td></tr>
		<tr><td colspan="21" align="center"><strong>사용자 랭킹 현황</strong></td></tr>
		<tr height="4"><td colspan="21" background="images/dot.gif"></td></tr>
		<tr>
		<td>
			<table border width="600">
			<tr>
				<td colspan=4 align="center"><strong>사용자 현황  최대속도 기준</strong></td>
			</tr>
			<tr>
				<td align="center">UserID</td>
				<td align="center">닉네임</td>
				<td align="center">총 로그인 회수</td>
				<td align="center">최대속도</td>
			</tr>
<%
	try
	{
		//DB 연결.
		db.db_open();
		List<String>	user_id	= new ArrayList<String>();
		List<String>   nickname = new ArrayList<String>();
		List<Integer>	speed	= new ArrayList<Integer>();
		
		//데이터베이스에서 Active 사용자 목록의 개수 읽어오기.
		String	query;

		query	= "SELECT user_id, max(speed),nickname FROM troasis_log";
		query	= query + " WHERE speed >170 AND speed<250";
		query	= query + " GROUP BY user_id";
		query   = query + " ORDER BY speed DESC";
		query	= query + " Limit 10";
		db.exec_query( query );
		
		while(db.mDbRs.next())
		{
			user_id.add(db.mDbRs.getString("user_id"));	
			speed.add(db.mDbRs.getInt("max(speed)"));
			nickname.add(db.mDbRs.getString("nickname"));
		}
	
			for ( int i = 0; i < 10; i++ )
			{

				int		db_max_login =0;
				
				query	= "SELECT count(time_log_start) FROM troasis_active";
				query	= query + " WHERE user_id ='" + user_id.get(i)+ "'";
				db.exec_query( query );
		
				if(db.mDbRs.next())
				{
					db_max_login=db.mDbRs.getInt(1);
				}
%>

					<tr>
						<td align="left"><%=user_id.get(i) %></td>
						<td align="center"><%=nickname.get(i) %></td>
						<td align="center"><%=db_max_login %></td>
						<td align="center"><%=speed.get(i)%></td>
					</tr>
<%	
		}
			
%>
					</table>
				</td>
			<td>
				<table width="50">
				</table>
			</td>
			<td>
				<table border width="600">		
				<tr>
					<td colspan=4 align="center"><strong>사용자 현황  최대 로그인 회수 기준</strong></td>
				</tr>
				<tr>
					<td align="center">UserID</td>
					<td align="center">닉네임</td>
					<td align="center">총 로그인 회수</td>
					<td align="center">최대속도</td>
				</tr>		
<%

		List<String>	uid	= new ArrayList<String>();
		List<String>   nname = new ArrayList<String>();
		List<Integer>	kspeed	= new ArrayList<Integer>();
		
		//데이터베이스에서 Active 사용자 목록의 개수 읽어오기.
		String	query1;
		int Clogin =0;
		
		query1	= "SELECT user_id, speed, nickname FROM troasis_active";
		query1	= query1 + " GROUP BY user_id";
		query1   = query1 + " ORDER BY count(time_log_start) DESC";
		query1	= query1 + " Limit 10";
		db.exec_query( query1 );
		
		while(db.mDbRs.next())
		{
			uid.add(db.mDbRs.getString("user_id"));	
			kspeed.add(db.mDbRs.getInt("speed"));
			nname.add(db.mDbRs.getString("nickname"));
		}
	
			for ( int i = 0; i < 10; i++ )
			{

				int		db_max_login =0;
				
				query1	= "SELECT count(time_log_start) FROM troasis_active";
				query1	= query1 + " WHERE user_id ='" + user_id.get(i)+ "'";
				db.exec_query( query1 );
		
				if(db.mDbRs.next())
				{
					Clogin=db.mDbRs.getInt(1);
				}
%>
				<tr>
					<td align="left"><%=uid.get(i) %></td>
					<td align="center"><%=nname.get(i) %></td>
					<td align="center"><%=Clogin %></td>
					<td align="center"><%=speed.get(i)%></td>
				</tr>						

<%
			}
		}
	catch( Exception e )
	{
		//완료 메시지.
		out.println( "<br><br>사용자 현황을 읽어오는 과정에서 오류가 발생 했습니다." );
		System.out.println( e );
	}
	finally
	{
		//DB 연결 닫기.
		db.db_close();
	}
%>
			</table>
		</td>
	</tr>
	</table>
</body>
</html>