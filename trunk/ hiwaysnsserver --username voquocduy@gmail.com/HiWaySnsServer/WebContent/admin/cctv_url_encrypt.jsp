<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer"
	scope="page" />
<jsp:useBean id="param"
	class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc"
	scope="page" />
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="java.io.*"%>
<%@	page import="java.text.DateFormat"%>
<%@	page import="java.text.SimpleDateFormat"%>
<%@	page import="java.util.*"%>
<%@page import="kr.co.ex.hiwaysns.Encrypter"%>

<%
	LoginManager loginManager = LoginManager.getInstance();
%>
<%
	if (loginManager.isLogin(session.getId()) == false) //세션 아이디가 로그인 중이 아니라면
	{
		response.sendRedirect("../admin/index.jsp");
		if (true)
			return;
	}
%>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>새로운 버전 등록</title>
</head>
<script type="text/javascript">
	
</script>


<%
	/* try {

		db.db_open();

		String strQuery;
		String android_client = "Android";
		String iphone_client = "iPhone";

		int android_ver_code = 0;
		String android_deployed_date = "";
		String android_ver_name = "";

		int iphone_ver_code = 0;
		String iphone_deployed_date = "";
		String iphone_ver_name = "";

		//Android 사용자
		strQuery = "SELECT ver_code, ver_name, deployed_date";
		strQuery = strQuery + " FROM " + strTableVer;
		strQuery = strQuery + " WHERE is_latest = 1";
		strQuery = strQuery + " AND is_Android = 1"; // Android

		//System.out.println( "strQuery=" + strQuery );
		db.exec_query(strQuery);

		while (db.mDbRs.next()) {
			android_ver_name = db.mDbRs.getString("ver_name");
			android_ver_code = db.mDbRs.getInt("ver_code");
			android_deployed_date = db.mDbRs.getString("deployed_date");
		}

		//iphone 사용자
		strQuery = "SELECT ver_code, ver_name, deployed_date";
		strQuery = strQuery + " FROM " + strTableVer;
		strQuery = strQuery + " WHERE is_latest = 1";
		strQuery = strQuery + " AND is_Android = 0"; // iphone

		//System.out.println( "strQuery=" + strQuery );
		db.exec_query(strQuery);

		while (db.mDbRs.next()) {
			iphone_ver_name = db.mDbRs.getString("ver_name");
			iphone_ver_code = db.mDbRs.getInt("ver_code");
			iphone_deployed_date = db.mDbRs.getString("deployed_date");
		} */
%>

<body>
	<table cellpadding="0" cellspacing="0" border="0" width="1050">
		<!-- 	(시작) 헤더.	-->
		<%@ include file="../admin/common_header.jsp"%>
		<!-- 	(끝) 헤더.	-->

		<tr height="600">
			<!-- 	(시작) 메뉴영역.	-->
			<%
				//System.out.println( "loginManager.mRole=" + loginManager.mRole );
				if (loginManager.mRole < 1) {
					//운영자 메뉴 표현.
			%>
			<!-- 	(시작) 운영자 메뉴.	-->
			<%@ include file="../admin/common_left_menu.jsp"%>
			<!-- 	(끝) 운영자 메누.	-->

			<%
				} else {
					//관리자 메뉴 표현.
			%>
			<!-- 	(시작) 관리자 메뉴.	-->
			<%@ include file="../admin/common_left_menu_admin.jsp"%>
			<!-- 	(끝) 관리자 메누.	-->
			<%
				}
			%>
			<!-- 	(끝) 메뉴영역.	-->

			<td width="60"></td>

			<!-- 	(시작) 작업영역.	-->
			<td width="860" valign="top" align="center">
				<%
					String userID = loginManager.getUserID(session.getId());
					String userName = LoginManager.mUserName;
					DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					Date date = new Date();
					String currentTime = dateFormat.format(date);
				%> <h2><b>Encrypting URL for National CCTV</b></h2><br /> <br />

				<div id="new_version_submit">
					<form name="q" action="cctv_url_encrypt_process.jsp" method="post"
						onsubmit="return js_user_input();">
						<%
							request.setCharacterEncoding("utf-8");
							String cctv_id = request.getParameter("cctv_id");
							if (cctv_id == null) {
								cctv_id = "";
							}
						%>					

						<table>
							<tr>
								<td>CCTV ID:</td>
								<td><input type="text" id="cctv_id" name="cctv_id" value="<%=cctv_id%>">
								</td>
							</tr>

							<tr>
								<td>CORNAME:</td>
								<td><input type="text" id="corname" name="corname"
									value="excenter">
								</td>
							</tr>

							<tr>
								<td>SVCNAME:</td>
								<td><input type="text" id="svcname" name="svcname"
									value="troasis">
								</td>

							</tr>

							<tr>
								<td>DATETIME</td>
								<td><input type="text" id="datetime" name="datetime"
									value="<%=currentTime%>"></input>
								</td>
								<td>(YYYY-MM-DD HH:mm:ss)</td>
							</tr>
						</table>

						<br /> <input type="submit" value="Encrypt" /> <input
							type="reset" value="Reset!">


					</form>
				</div>
				<div>
					<%						
						String encoded_string = request.getParameter("encoded_string");
						if (encoded_string != null) {
						encoded_string = "http://cctvsec.ktict.co.kr/"+ cctv_id + "/" + encoded_string;
					%>
					Encrypted URL: <a href="<%=encoded_string%>">URL</a>
					<%
						}
					%>
				</div> <%-- 
				<table cellpadding="0" cellspacing="0" border="0" width="60%">
					<tr height="10">
						<td colspan="4"></td>
					</tr>
					<tr>
						<td colspan="4" height="10" align="center" bgcolor="#dbdbdb">
							<font style="font-sze: 11pt; color: #ff5900; line-height: 22px">현재
								최신 버전 현황</font>
						</td>
					</tr>
					<tr>
						<td align="center"><strong>클라이언트 타입</strong></td>
						<td align="center"><strong>최선 버전 이름</strong></td>
						<td align="center"><strong>버전 코드</strong></td>
						<td align="center"><strong>버전 등록 날짜</strong></td>
					</tr>

					<tr height="1">
						<td colspan="9" background="images/dot.gif"></td>
					</tr>
					<tr>
						<TD align="center"><%=android_client%></TD>
						<TD align="center"><%=android_ver_name%></TD>
						<TD align="center"><%=android_ver_code%></TD>
						<TD align="center"><%=android_deployed_date%></TD>
					</tr>

					<tr height="1">
						<td colspan="9" background="images/dot.gif"></td>
					</tr>
					<tr>
						<TD align="center"><%=iphone_client%></TD>
						<TD align="center"><%=iphone_ver_name%></TD>
						<TD align="center"><%=iphone_ver_code%></TD>
						<TD align="center"><%=iphone_deployed_date%></TD>
					</tr>

					<%
						//트랜잭션 Rollback Commit.
							db.tran_commit();
						} catch (Exception e) {
							//트랜잭션 Rollback.
							db.tran_rollback();

							//오류 메시지 출력.
							System.out.println("[USER MSG NEW]" + e.toString());
					%>

					<%
						} finally {
							//DB 연결 닫기.
							db.db_close();
						}
					%>
 --%> <!-- 	(시작) Footer.	--> <%@ include
					file="../admin/common_footer.jsp"%> <!-- 	(끝) Footer.	-->
	</table>
	</td>


	</tr>
	</table>
</body>
</html>


