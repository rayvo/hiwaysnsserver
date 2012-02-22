<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) == false )	//세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if ( true )	return;
	}
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>TrOASIS 운영 및 관리 홈페이지 - 시스템 운영상태</title>
</head>
<script type="text/javascript">
//<!--
//-->
</script>
<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"  %>
		<!-- 	(끝) 헤더.	-->
		
		<tr height="600">
			<!-- 	(시작) 메뉴영역.	-->
		<%
			//System.out.println( "loginManager.mRole=" + loginManager.mRole );
			if ( loginManager.mRole < 1 )
			{
				//운영자 메뉴 표현.
		%>
			<!-- 	(시작) 운영자 메뉴.	-->
			<%@ include file="../admin/common_left_menu.jsp"  %>
			<!-- 	(끝) 운영자 메누.	-->

		<%
			}
			else
			{
				//관리자 메뉴 표현.
		%>
			<!-- 	(시작) 관리자 메뉴.	-->
			<%@ include file="../admin/common_left_menu_admin.jsp"  %>
			<!-- 	(끝) 관리자 메누.	-->
		<%
			}
		%>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="40"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top">
				<table align="left" border="0" cellpadding="0" cellspacing="0">
					<tr height="20"><td></td></tr>
					<tr>
						<td>
							<h3><a href="active_user_list.jsp">Active 사용자 현황</a></h3>
						</td>
					</tr>
					<tr>
						<td>
							<h3><a href="user_log_list.jsp">사용자의 로그 현황</a></h3>
						</td>
					</tr>
					<!--tr>
						<td>
							<h3><a href="traffic_info_list.jsp">교통정보 현황</a></h3>
						</td>
					</tr-->
					<!--tr>
						<td>
							<h3><a href="car_flow_list.jsp">사용자 소통현황</a></h3>
						</td>
					</tr-->
					<tr>
						<td>
							<h3><a href="user_msg_list.jsp">사용자 메시지 현황</a></h3>
						</td>
					</tr>
					<!--tr>
						<td>
							<h3><a href="pos_log_list.jsp">사용자 주행기록 현황</a></h3>
						</td>
					</tr-->
					
					<!--	(3) 테이블 형식			-->
					<tr>
						<td width="860"></td>
					</tr>
				</table>
			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"  %>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
</html>