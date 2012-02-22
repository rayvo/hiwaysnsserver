<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	if( loginManager.isLogin(session.getId()) )		//세션 아이디가 로그인 중이면
	{
		response.sendRedirect("../admin/index_login.jsp");
		if( true )	return;
	}
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>TrOASIS 운영 및 관리 홈페이지</title>
</head>
<script type="text/javascript">
//<!--
function js_login_user()
{
	var frm_input = document.form_main;
	if ( frm_input.user_id.value == "" )
	{
		alert( "운영자 ID를 입력하세요." );
		frm_input.user_id.focus();
		return( false );
	}
	if ( frm_input.user_passwd.value == "" )
	{
		alert( "비밀번호를 입력하세요." );
		frm_input.user_passwd.focus();
		return( false );
	}
	frm_input.key.value	= 1;
	return( true );
}
//-->
</script>
<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"  %>
		<!-- 	(끝) 헤더.	-->
		
		<tr height="600">
			<!-- 	(시작) 메뉴영역.	-->
			<td width="150" valign="top">
				<table cellpadding="0" cellspacing="0" border="0" width="100%">
					<tr height="400"><td></td></tr>
				</table>
			</td>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="40"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top">
				<form id="form_main" name="form_main" method="post" action="../admin/login_process.jsp" onsubmit="return js_login_user();">
				<table align="left" border="0" cellpadding="0" cellspacing="0">
					<!--	(1) 자료 전달 영역		-->
					<tr>
						<td>
							<input type="hidden" name="cmd_option" value="1">
							<input type="hidden" name="key" value="">
						</td>
					</tr>
				
					<!--	(2) 로그인				-->
					<tr height="50"><td></td></tr>
					<tr>
						<td align="right" valign="bottom">
							<table align="center" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td colspan="2" height="40" align="center" bgcolor="#dbdbdb">
										<font style="font-size:11pt; color:#ff5900; line-height:22px">로그인</font>
									</td>
								</tr>
								<tr><td colspan="2" height="5"></td></tr>
								<tr>
									<td align="right">운영자 ID:&nbsp;</td>
									<td align="left">
										<input maxlength="16" size="14" id="user_id" name="user_id" tabindex="4" value="">
									</td>
								</tr>
								<tr>
									<td align="right">비밀번호:&nbsp;</td>
									<td align="left">
										<input type="password" maxlength="16" size="15" id="user_passwd" name="user_passwd" tabindex="5">
										<input type="submit" size="10" align="middle" name="login" value="로그인" tabindex="6" border="0">
									</td>
								</tr>
								<tr><td colspan="2" height="5"></td></tr>
								<tr>
									<td colspan="2" height="5" bgcolor="#dbdbdb"></td>
								</tr>
								<tr><td colspan="2" height="50"></td></tr>
								<tr>
									<td colspan="2" align="center">
										<a href="../admin/user_register.jsp"><font color="black">운영자 등록</font></a><br>
									</td>
								</tr>
								<tr height="1">
									<td width="170"></td>
									<td width="296"></td>
								</tr>
							</table>
						</td>
					</tr>
				
					<!--	(3) 테이블 형식			-->
					<tr>
						<td width="860"></td>
					</tr>
				</table>
				</form>
			</td>
			<!-- 	(끝) 작업영역.	-->
		</tr>
		
		<!-- 	(시작) Footer.	-->
		<%@ include file="../admin/common_footer.jsp"  %>
		<!-- 	(끝) Footer.	-->
	</table>
</body>
<script type="text/javascript">
//<!--
	document.form_main.user_id.focus();
//-->
</script>
</html>