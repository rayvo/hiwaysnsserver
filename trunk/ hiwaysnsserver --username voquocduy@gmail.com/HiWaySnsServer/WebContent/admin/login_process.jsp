<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@	page	import ="kr.co.ex.hiwaysns.lib.*"	%>
<% LoginManager loginManager = LoginManager.getInstance(); %>
<%
	request.setCharacterEncoding("utf-8");
	 
	String userID = request.getParameter("user_id");
	String userPW = request.getParameter("user_passwd");
	//System.out.println( "user_id=" + userID + ", user_passwd=" + userPW);
	 
	if( loginManager.isValid(userID, userPW) )
	{
		if( !loginManager.isUsing(userID) )
		{
			loginManager.setSession(session, userID);
			response.sendRedirect("../admin/index.jsp");
		}
		else
		{
			//throw new Exception("이미 로그인중");
			response.sendRedirect("../admin/index.jsp");
		}
	}
	else
	{
		//throw new Exception("ID/PW 이상");
		response.sendRedirect("../admin/index.jsp");
	}
%>
