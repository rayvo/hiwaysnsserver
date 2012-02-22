<%@page contentType="text/xml; charset=utf-8" %>
<%@ page language="java" import="java.sql.*"%>

<%



String sql;
String rtn_xml;

rtn_xml = "";

try{
	Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
	String url = "jdbc:odbc:Sample_Parkmi";
	Connection con = DriverManager.getConnection(url,"parkmi","parkmi77");
	Statement st = con.createStatement();
	String user = request.getParameter("userid");
	sql = "select loc_lat,loc_lng,loc_speed from location_info where user_id='"+user+"'";
	ResultSet rs = st.executeQuery(sql);	
	
	out.println("<?xml version='1.0' encoding='ISO-8859-1'?>");
	out.println("<user>");
	
	while (rs.next()){	
		out.println("<userpath>");
		//out.println("<userpath><lat>"+ rs.getFloat("loc_lat") + " </lat></userpath>");
		//out.println("<userpath><lng>"+ rs.getFloat("loc_lng") + " </lng></userpath>");
		out.println("<lat>" + rs.getFloat("loc_lat") + " </lat>");
		out.println("<lng>" + rs.getFloat("loc_lng") +  "</lng>");
		out.println("<speeds>"+rs.getString("loc_speed")+"</speeds>");
		out.println("</userpath>");		
	}	
	out.println("</user>");
}
catch(ClassNotFoundException cne){
	
}catch(SQLException se){
}
%>
