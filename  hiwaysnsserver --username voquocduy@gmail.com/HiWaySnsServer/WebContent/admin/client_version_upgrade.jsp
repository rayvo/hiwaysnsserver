<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="db" class="kr.co.ex.hiwaysns.HiWayCommServer" scope="page" />
<jsp:useBean id="param" class="kr.co.ex.hiwaysns.lib.TrOasisParamPassing" scope="page" />
<jsp:useBean id="xmlGen" class="kr.co.ex.hiwaysns.lib.TrOasisXmlProc" scope="page" />
<%@	page import="kr.co.ex.hiwaysns.lib.*"%>
<%@	page import="java.io.*"%>
<%@	page import="java.util.*"%>
<%@	page import="kr.co.ex.hiwaysns.lib.TrOasisConstants"%>

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

<%
	String strTableVer = "client_version_info";
	String query = "";
	db.db_open();

	query = "SELECT ver_code";
	query = query + " FROM " + strTableVer;

	db.exec_query(query);
	if (db.mDbRs.next() == false) // 버전 등록이 처음인 경우
	{
		response.sendRedirect("../admin/first_version.jsp");
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
function js_user_input()
{
	var frm_input = document.q;
	if ( frm_input.ver_name.value == "")
	{
		alert( "버전 이름이 입력되지 않았습니다." );
		frm_input.ver_name.focus();
		return( false );
	}
	if ( frm_input.client_type.value == "" )
	{
		alert( "안드로이드인지 아이폰인지 선택하여 주세요." );
		frm_input.is_Android_data.focus();
		return( false );
	}
	if ( frm_input.deployed_data.value == "" )
	{
		alert( "업데이트 날짜가 입력되지 않았습니다." );
		frm_input.deployed_data.focus();
		return( false );
	}
	return( true );
}
</script>


<%
	try {

		db.db_open();

		String strQuery;
		String android_client= "Android";
		String iphone_client= "iPhone";
		
		int android_ver_code =0;
		String android_deployed_date="";
		String android_ver_name="";

		
		int iphone_ver_code =0;
		String iphone_deployed_date="";
		String iphone_ver_name="";
		
		//Android 사용자
		strQuery = "SELECT ver_code, ver_name, deployed_date";
		strQuery = strQuery + " FROM " + strTableVer;
		strQuery = strQuery + " WHERE is_latest = 1";
		strQuery = strQuery + " AND is_Android = 1"; // Android

		//System.out.println( "strQuery=" + strQuery );
		db.exec_query(strQuery);
		
		while (db.mDbRs.next()) 
		{		
			android_ver_name = db.mDbRs.getString("ver_name");
			android_ver_code = db.mDbRs.getInt("ver_code");
			android_deployed_date =db.mDbRs.getString("deployed_date");
		}
		
		//iphone 사용자
		strQuery = "SELECT ver_code, ver_name, deployed_date";
		strQuery = strQuery + " FROM " + strTableVer;
		strQuery = strQuery + " WHERE is_latest = 1";
		strQuery = strQuery + " AND is_Android = 0"; // iphone

		//System.out.println( "strQuery=" + strQuery );
		db.exec_query(strQuery);
		
		while (db.mDbRs.next()) 
		{		
			iphone_ver_name = db.mDbRs.getString("ver_name");
			iphone_ver_code = db.mDbRs.getInt("ver_code");
			iphone_deployed_date =db.mDbRs.getString("deployed_date");
		}
		
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
				%>

				<form name="q" action="client_version_upgrade_process.jsp" method="post" onsubmit="return js_user_input();">
					<div id="new_version_submit">
						<b>새로운 버전 업데이트</b><br /> <br />

						<table cellpadding="0" cellspacing="0" border="0" width="60%">
							<tr height="10">
								<td colspan="4"></td>
							</tr>
							<tr>
								<td colspan="4" height="10" align="center" bgcolor="#dbdbdb">
									<font style="font-sze: 11pt; color: #ff5900; line-height: 22px">현재 최신 버전 현황</font></td>
							</tr>
							<tr>
								<td align="center"><strong>클라이언트 타입</strong>
								</td>
								<td align="center"><strong>최선 버전 이름</strong>
								</td>
								<td align="center"><strong>버전 코드</strong>
								</td>
								<td align="center"><strong>버전 등록 날짜</strong>
								</td>
							</tr>

							<%
								//데이터베이스 내용 출력
							%>

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


							<br /> 버전 이름 :
							<input type="text" id="ver_name" name="ver_name"></input>
							<br />
							
							<p>
									사용자 플렛폼 타입： <select name="client_type">
									<option value="Android" selected="selected">Android</option>
									<option value="iPhone">iPhone</option>
								</select>
							</p>
							버전 업데이트 날짜:
							<input type="text" id="deployed_date" name="deployed_date"></input>
							(기본으로 오늘날짜 입력 됨)
							<br />
							<br />
							
							<input type="submit" value="업데이트 하기" />
							
							</div>
							<br />
							<br />
							</form>
							</td>
							<!-- 	(끝) 작업영역.	-->
							</tr>


							<%
								//System.out.println("version_code, version_name, deployed_date, msg_i"
									//+ version_code + "," + version_name + "," + deployed_date + "," + msg_i);
							%>
							
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

							<!-- 	(시작) Footer.	-->
							<%@ include file="../admin/common_footer.jsp"%>
							<!-- 	(끝) Footer.	-->
						</table>
</body>
</html>


