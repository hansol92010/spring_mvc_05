<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath }"/>
	<nav class="navbar navbar-default">
		<div class="container-fluid">
		    <div class="navbar-header">
		      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
		        <span class="icon-bar"></span>
		        <span class="icon-bar"></span>
		        <span class="icon-bar"></span>                        
		      </button>
		      <a class="navbar-brand" href="${contextPath}/">스프1탄</a>
		    </div>
		    
		    <!-- 위 button(data-target이 #myNavbar)을 눌렀을 때 펼쳐질, id가 myNavbar인 div -->
		    <div class="collapse navbar-collapse" id="myNavbar">
				<ul class="nav navbar-nav">
					<li class="active"><a href="${contextPath}/">Home</a></li>
					<li><a href="${contextPath}/boardMain.do">게시판</a></li>
				</ul>
			
				<!-- 로그인하지 않았을 경우 -->
				<c:if test="${empty member}" >
					<ul class="nav navbar-nav navbar-right">
						<li><a href="${contextPath}/memJoin.do"><span class="glyphicon glyphicon-user"></span> 회원가입</a></li>
						<li><a href="${contextPath}/memLoginForm.do"><span class="glyphicon glyphicon-log-in"></span> 로그인</a></li>
					</ul>
				</c:if>
		      
		      	<!-- 로그인한 경우 -->
				<c:if test="${!empty member}" >
					<ul class="nav navbar-nav navbar-right">  
						<li><a href="${contextPath}/memUpdateForm.do"><span class="glyphicon glyphicon-wrench"></span> 회원정보수정</a></li>
						<li><a href="${contextPath}/memImageForm.do"><span class="glyphicon glyphicon-picture"></span> 사진등록</a></li>
						<li><a href="${contextPath}/memLogout.do"><span class="glyphicon glyphicon-log-out"></span> 로그아웃</a></li>
					
						<!-- 로그인 상태에 따라 다른 글을 출력 -->
						<!-- 기본이미지 -->
						<c:if test="${empty member.memProfile}">
							<li><img src="${contextPath}/resources/images/person.png" class="img-circle" style="width:50px; height:50px;"/> ${member.memName}님
							(
								<c:forEach var="authVO" items="${member.authList}">
									<c:if test="${authVO.auth eq 'ROLE_USER'}">U</c:if>
									<c:if test="${authVO.auth eq 'ROLE_MANAGER'}">M</c:if>
									<c:if test="${authVO.auth eq 'ROLE_ADMIN'}">A</c:if>
								</c:forEach>
							)
							, Welcome!</li>
						</c:if>	
						<!-- 등록한 이미지 -->
						<c:if test="${!empty member.memProfile}">
							<li><img src="${contextPath}/resources/upload/${member.memProfile}" class="img-circle" style="width:50px; height:50px;"/> ${member.memName}님
							(
								<c:forEach var="authVO" items="${member.authList}">
									<c:if test="${authVO.auth eq 'ROLE_USER'}">U</c:if>
									<c:if test="${authVO.auth eq 'ROLE_MANAGER'}">M</c:if>
									<c:if test="${authVO.auth eq 'ROLE_ADMIN'}">A</c:if>
								</c:forEach>
							)
							, Welcome!</li>
						</c:if> 	      	
					</ul>
				</c:if>
		    </div>
		</div>
	</nav>
