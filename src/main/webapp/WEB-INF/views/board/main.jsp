<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Spring MVC05</title>
	
	<!-- bootstrap, jQuery -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

	<script>
		$(document).ready(function() {
			loadList();
		})
		
		var csrfHeaderName = "${_csrf.headerName}";
		var csrfTokenValue = "${_csrf.token}";
		
		function loadList() {
			// 서버와 통신 : 게시판 리스트 가져오기
			$.ajax({
				url : "<c:url value='/board/all' />",
				type : "get",
				dataType : "json",
				success : makeView,		// 성공했을 경우 콜백함수 호출(json 형태의 데이터는 이 과정에 자바스크립트 객체 리터럴로 변환되는 듯하다)
				error : function() {
					alert("errer");
				}
			});
		}
		
		function makeView(data) {
			// console.log(data);
			var listHtml = "<table class='table table-bordered table-hover'>";
					listHtml += "<tr>";
						listHtml +=	"<th>번호</th>";
						listHtml +=	"<th>제목</th>";
						listHtml +=	"<th>작성자</th>";
						listHtml +=	"<th>작성일</th>";
						listHtml +=	"<th>조회수</th>";
					listHtml += "</tr>";
				$.each(data, function(index, board) {
					listHtml += "<tr>";
						listHtml += "<td>"+board.idx+"</td>";
						listHtml += "<td id='t"+board.idx+"'><a href='javascript:goContent("+board.idx+")'>"+board.title+"</a></td>"; // goContent()에 게시물 번호를 넘겨, 해당 함수 내에서 게시물 번호를 id로 값는 tr만 보이도록 만든다
						listHtml += "<td>"+board.writer+"</td>";
						listHtml += "<td>"+board.indate.split(' ')[0]+"</td>";
						listHtml += "<td id='cnt"+board.idx+"'>"+board.count+"</td>";		
					listHtml += "</tr>";
					listHtml += "<tr style='display:none;' id='c"+board.idx+"'>"; // id에 고유한 식별자를 주기 위해 게시물 번호를 이용해야 한다
						listHtml += "<td>내용</td>";
						listHtml += "<td colspan='4'>";
							listHtml += "<textarea rows='7' class='form-control' id='ta"+board.idx+"' readonly></textarea>";
							if("${member.memID}" == board.memID) {
								listHtml += "<br />"
								listHtml += "<span id='ub"+board.idx+"'><button type='button' class='btn btn-success btn-default' onClick='goUpdateForm("+board.idx+")'>수정</button></span>&nbsp;";			
								listHtml +=	"<button type='reset' class='btn btn-danger btn-default' onClick='goDelete("+board.idx+")'>삭제</button>"
							} else {
								listHtml += "<br />"
								listHtml += "<span id='ub"+board.idx+"'><button type='button' class='btn btn-success btn-default' onClick='goUpdateForm("+board.idx+")' disabled>수정</button></span>&nbsp;";			
								listHtml +=	"<button type='reset' class='btn btn-danger btn-default' onClick='goDelete("+board.idx+")' disabled>삭제</button>"
							}
							listHtml += "</td>";
					listHtml += "</tr>";
				});
				listHtml += "</table>";
			$("#view").html(listHtml);
			
			$("#view").css("display", "block");
			$("#writeForm").css("display", "none");
		}
		
		function goForm() {
			$("#view").css("display", "none");
			$("#writeForm").css("display", "block");
		}
		
		function goList() {
			$("#view").css("display", "block");
			$("#writeForm").css("display", "none");
		}
		
		function goInsert() {
			var fData = $("#frm").serialize();	// 예) title=111&content=111&writer=111
			// console.log(fData);
			$.ajax({
				url : "<c:url value='/board/new' />",
				type : "post",
				data : fData,
				beforeSend : function(xhr) {	// CSRF token 작업 필요
					xhr.setRequestHeader(csrfHeaderName, csrfTokenValue)
				},
				success : loadList,
				error : function() {
					alert("error");
				}
			});
			
			// 폼 데이터 초기화
			/* $("#title").val("");
			$("#content").val("");
			$("#writer").val(""); */
			$("#fclear").trigger("click");
		}
		
		function goContent(idx) {
			// alert(idx);
			if($("#c"+idx).css("display") == "none"){	// none이라면 열리고, none이 아니라면 안 보이도록
				$.ajax({
					url : "<c:url value='/board/"+idx+"' />",
					type : "get",
					data : {"idx" :  idx},
					success : function(data) {
						$("#ta"+idx).val(data.content);
					},
					error: function() {
						alert("error");
					}
				});
				$("#c"+idx).css("display", "table-row");
				$("#ta"+idx).attr("readonly", true);
			} else {
				$("#c"+idx).css("display", "none");
				$.ajax({
					url : "<c:url value='/board/count/"+idx+"' />",
					type : "put",
					data : {"idx" :  idx},
					dataType : "json",
					beforeSend : function(xhr) {	// CSRF token 작업 필요
						xhr.setRequestHeader(csrfHeaderName, csrfTokenValue)
					},
					success : function(data) {
						$("#cnt"+idx).text(data.count);
					},
					error: function() {
						alert("error");
					}
				});				
			}
		}
		
		function goDelete(idx) {
			$.ajax({
				url : "<c:url value='/board/"+idx+"' />",
				type : "delete",
				data : {"idx":  idx},
				beforeSend : function(xhr) {	// CSRF token 작업 필요
					xhr.setRequestHeader(csrfHeaderName, csrfTokenValue)
				},
				success : loadList,
				error : function() {
					alert("error");
				}
			})
		}
		
		function goUpdateForm(idx) {
			// textarea의 읽기전용을 풀기
			$("#ta"+idx).attr("readonly", false);	// readonly X
			
			// title부분에 input태그를 추가하여 수정 가능하도록 만들기
			var title = $("#t"+idx).text();
			var newInput = "<input type='text' id='nt"+idx+"' class='form-control' value='"+title+"'/>";
			$("#t"+idx).html(newInput);
			
			// '수정'버튼이 '수정완료'로 바뀌기
			var newButton = "<button class='btn btn-primary btn-sm' onClick='goUpdate("+idx+")'>수정완료</button>"
			$("#ub"+idx).html(newButton);
		}
		
		function goUpdate(idx) {
			var title = $("#nt"+idx).val();
			var content = $("#ta"+idx).val();
			
			$.ajax({
				url : "<c:url value='/board/update' />",
				type : "put",
				contentType : "application/json;charset=utf-8",
				data : JSON.stringify({
					"idx" : idx,
					"title" : title,
					"content" : content
				}),
				beforeSend : function(xhr) {	// CSRF token 작업 필요
					xhr.setRequestHeader(csrfHeaderName, csrfTokenValue)
				},
				success : loadList,
				error : function() {
					alert("error");
				}
			});
		}
	</script>

</head>
<body>
	<div class="container">
		<jsp:include page="../common/header.jsp" />
	 	<h3></h3>
		<div class="panel panel-default">
			<div class="panel-heading" style="font-weight:bold; font-size:large;">회원 게시판
				
				<!-- 로그인을 한 경우에만 '글쓰기' 버튼이 나타난다 -->
				<c:if test="${!empty member}">
					<button class="btn btn-xs pull-right btn-primary" onClick="goForm()">게시물 쓰기</button>
				</c:if>
				
			</div>
			
			<!-- 게시물 상세보기 -->
		  	<div class="panel-body" id="view"></div>
		  	
		  	<!-- 게시물 쓰기 -->
		  	<div class="panel-body" id="writeForm" style="display: none;">
				<form id="frm">
					<input type="hidden" name="memID" value="${member.memID }" />
					<div class="form-group">
						<label for="title">제목</label>
						<input type="text" class="form-control" id="title" name="title" />
					</div>
					<div class="form-group">
						<label for="contents">내용</label>
						<textarea rows="7" class="form-control" id="content" name="content" ></textarea>
					</div>
					<div class="form-group">
						<label for="writer">작성자</label>
						<input type="text" class="form-control" id="writer" name="writer" value="${member.memName}" readonly/>
					</div>
					<div class="form-group" style="text-align: center;">
						<button type="button" class="btn btn-success btn-default" onClick="goInsert()">등록</button>				
						<button type="reset" class="btn btn-danger btn-default" id="fclear">취소</button>
						<button type="button" class="btn btn-warning btn-default" onClick="goList()">리스트</button>
					</div>
				</form>				  
		  	</div>
		  	<div class="panel-footer">인프런_스프1탄</div>
		</div>
	</div>
</body>
</html>