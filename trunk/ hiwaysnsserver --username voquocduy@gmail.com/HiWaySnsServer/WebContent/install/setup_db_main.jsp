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
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>TrOASIS 운영 및 관리 홈페이지 - 데이터베이스 관리</title>
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
							<h3>데이터베이스를 초기화 합니까?</h3>
							<a href="setup_db_reset.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					<tr>
						<td>
							<h3>데이터베이스를 Upgrade 합니까?</h3>
							<a href="setup_db_upgrade.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					<tr>
						<td>
							<h3>지도 데이터를 Upload 합니까?</h3>
							<a href="setup_map_upload_excels.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					<tr>
						<td>
							<h3>FTMS Agent 데이터를 Upload 합니까?</h3>
							<a href="setup_ftms_upload_excels.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					<!--tr>
						<td>
							<h3>FTMS 데이터를 보정합니까?</h3>
							<a href="setup_ftms_upgrade_01.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr-->
					<!--tr>
						<td>
							<h3>연계서버 데이터베이스를 초기화 합니까?</h3>
							<a href="setup_if_db_reset.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr-->
					<!-- tr>
						<td>
							<h3>VMS 데이터를 초기화합니까?</h3>
							<a href="setup_vms_reset.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr-->
					<tr>
						<td>
							<h3>VMS 데이터를 Upload 합니까?</h3>
							<a href="setup_vms_upload_excels.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					
					<tr>
						<td>
							<h3>버전 관리 테이블을 만들겠습니까?</h3>
							<a href="setup_client_version_table.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr>
					
					<!--tr>
						<td>
							<h3>VMS 데이터를 보정합니까(1단계)?</h3>
							<a href="setup_vms_upgrade_01.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr-->
					<!--tr>
						<td>
							<h3>VMS 데이터를 보정합니까(2단계)?</h3>
							<a href="setup_vms_upgrade_02.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
						</td>
					</tr>
					<tr height="40"><td></td></tr-->
					<!--tr>
						<td>
							<h3>CCTV 데이터를 Upload 합니까?</h3>
							<a href="setup_cctv_upload_excels.jsp">네(Yes)</a> | <a href="../index.jsp">아니오(No)</a>
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