package kr.board.controller;

import java.io.File;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import kr.board.entity.AuthVO;
import kr.board.entity.Member;
import kr.board.mapper.MemberMapper;

@Controller
public class MemberController {
	
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Autowired
	private MemberMapper memberMapper;

	@RequestMapping("/memJoin.do")
	public String memJoin() {
		return "member/join";
	}
	
	@RequestMapping("/memIdCheck.do")
	public @ResponseBody int memIdCheck(@RequestParam("memID") String memID) {
		Member member = memberMapper.memCheck(memID);
		if(memID.equals("") || member != null) {
			return 0;		// 이미 존재하는 회원 또는 회원 아이디가 아무것도 입력되지 않았을 경우
		} else {
			return 1;		// 사용 가능한 아이디
		}
	}
	
	@RequestMapping(value="/memRegister.do", method=RequestMethod.POST)
	public String memRegister(Member member, RedirectAttributes rttr, HttpSession session, String memPassword1, String memPassword2) {
		if(member.getMemID() == null || member.getMemID().equals("") ||
		   memPassword1== null || memPassword1.equals("") ||
		   memPassword2== null || memPassword2.equals("") ||
		   member.getMemName() == null || member.getMemName().equals("") ||
		   member.getMemAge() == 0 ||
		   member.getAuthList().size() == 0 ||
		   member.getMemGender() == null || member.getMemGender().equals("") ||
		   member.getMemEmail() == null || member.getMemEmail().equals("")) {
			   // 오류 메시지와 가지고 가기
			   // 지금까지 HttpRequestServlet 객체, HttpSession 객체, Model 객체를 이용했는데, 이번엔 RedirectAttributes 객체를 이용해 바인딩한다
			   rttr.addFlashAttribute("msgType", "실패 메시지");	// addFlashAttribute() => 세션에 저장되어 사용된 뒤에는 자동으로 삭제
			   rttr.addFlashAttribute("msg", "모든 내용을 입력하세요");
			   return "redirect:/memJoin.do";	// ${msgType}, ${msg}
		}
		
		if(!memPassword1.equals(memPassword2)) {
			 rttr.addFlashAttribute("msgType", "실패 메시지");
			 rttr.addFlashAttribute("msg", "비밀번호가 일치하지 않습니다");
			 return "redirect:/memJoin.do";	// ${msgType}, ${msg}
		}
		
		member.setMemProfile("");	// 사진이미지는 없다는 의미 ""(null이 아니라 공백없이 ""로)
		
		// 회원 테이블에 저장
		// SpringMVC05 -> 비밀번호 암호화(API)
		String encyptPwd = passwordEncoder.encode(member.getMemPassword());
		member.setMemPassword(encyptPwd);
		
		// SpringMVC05 -> register 수정
		int result = memberMapper.register(member);
		if(result > 0) {
			// SpringMVC05 -> 권한 테이블에 회원의 권한 저장
			List<AuthVO> list = member.getAuthList();
			for(AuthVO authVO : list) {
				if(authVO.getAuth() != null) {
					AuthVO saveAuth = new AuthVO();
					saveAuth.setMemID(member.getMemID());	// 회원의 아이디
					saveAuth.setAuth(authVO.getAuth());		// 회원의 권한
				
					memberMapper.authInsert(saveAuth);		// 권한 저장
				}
			}
			
			rttr.addFlashAttribute("msgType", "성공 메시지");
			rttr.addFlashAttribute("msg", "회원가입에 성공하였습니다");	   
			
			// 회원가입 성공 => 바로 로그인이 되도록 처리하기
			// SpringMVC05 -> 권한 정보도 가져와야 한다 
			Member memberVO = memberMapper.memCheck(member.getMemID());
			System.out.println(memberVO);
			session.setAttribute("member", memberVO); // ${member}
			return "redirect:/";					  // 메인 페이지에서도 로그인이 되었는지도 체크해야 할 것 => header.jsp에서 하고 있다
		} else {
			rttr.addFlashAttribute("msgType", "실패 메시지");
			rttr.addFlashAttribute("msg", "이미 존재하는 회원입니다");
			return "redirect:/memJoin.do";
		}
	}
	
	@RequestMapping("/memLogout.do")
	public String memLogout(HttpSession session) {
		session.invalidate();
		return "redirect:/";
	}
	
	@RequestMapping("/memLoginForm.do")
	public String memLoginForm() {
		return "member/memLoginForm";
	}
	
	@RequestMapping(value="/memLogin.do", method=RequestMethod.POST)
	public String memLogin(Member member, RedirectAttributes rttr, HttpSession session) {
		if(member.getMemID() == null || member.getMemID().equals("") ||
			member.getMemPassword() == null || member.getMemPassword().equals("")) {
			rttr.addFlashAttribute("msgType", "실패 메시지");
			rttr.addFlashAttribute("msg", "모든 내용을 입력해주세요");
			return "redirect:/memLoginForm.do";
		}
		
		// SpringMVC05 - memLogin()는 회원 아이디에 해당하는 회원 정보와 권한 정보를 가져온 것
		Member mvo = memberMapper.memLogin(member);
		
		// SpringMVC05 - passwordEncoder 객체의 matches() 메서드를 통해 비밀번호 일치 여부를 체크한다
		if(mvo != null && passwordEncoder.matches(member.getMemPassword(), mvo.getMemPassword())) {
			rttr.addFlashAttribute("msgType", "성공 메시지");
			rttr.addFlashAttribute("msg", "로그인에 성공하였습니다");
			session.setAttribute("member", mvo);
			return "redirect:/";
		} else {
			rttr.addFlashAttribute("msgType", "실패 메시지");
			rttr.addFlashAttribute("msg", "입력 정보가 올바르지 않습니다. 로그인을 다시 시도해주세요");
			return "redirect:/memLoginForm.do";
		}
	}
	
	@RequestMapping("/memUpdateForm.do")
	public String memUpdateForm() {
		return "member/memUpdateForm";
	}
	
	@RequestMapping("/memUpdate.do")
	public String memUpdate(Member member, RedirectAttributes rttr,  HttpSession session, String memPassword1, String memPassword2) {
		if(member.getMemID() == null || member.getMemID().equals("") ||
		   memPassword1== null || memPassword1.equals("") ||
		   memPassword2== null || memPassword2.equals("") ||
		   member.getMemName() == null || member.getMemName().equals("") ||
		   member.getMemAge() == 0 ||
		   member.getAuthList().size() == 0 ||
		   member.getMemGender() == null || member.getMemGender().equals("") ||
		   member.getMemEmail() == null || member.getMemEmail().equals("")) {
			   rttr.addFlashAttribute("msgType", "실패 메시지");
			   rttr.addFlashAttribute("msg", "모든 내용을 입력하세요");
			   return "redirect:/memUpdateForm.do";
		}
		
		if(!memPassword1.equals(memPassword2)) {
			 rttr.addFlashAttribute("msgType", "실패 메시지");
			 rttr.addFlashAttribute("msg", "비밀번호가 일치하지 않습니다");
			 return "redirect:/memUpdateForm.do";
		}
			
		// 회원 정보 수정하기
		// SpringMVC05 - 비밀번호 암호화 작업
		String encyptPwd = passwordEncoder.encode(member.getMemPassword());
		member.setMemPassword(encyptPwd);
		
		// SpringMVC05 - memUpdate의 SQL 쿼리문 수정
		int result = memberMapper.memUpdate(member);
		if(result == 1) {
			// SpringMVC05 - 기존 권한을 삭제하고 새로운 권한을 등록하는 작업을 추가한다
			List<AuthVO> list = member.getAuthList();
			memberMapper.authDelete(member.getMemID());	
			for(AuthVO authVO : list) {
				if(authVO.getAuth() != null) {
					AuthVO saveAuth = new AuthVO();
					saveAuth.setMemID(member.getMemID());	// 회원의 아이디
					saveAuth.setAuth(authVO.getAuth());		// 회원의 권한
				
					memberMapper.authInsert(saveAuth);		// 권한 저장
				}
			}
			
			Member memUpdate = memberMapper.memCheck(member.getMemID());	// 수정 후 다시 member 테이블에서 수정된 후의 회원 정보를 가져와야 한다
			rttr.addFlashAttribute("msgType", "성공 메시지");
			rttr.addFlashAttribute("msg", "회원정보 수정에 성공하였습니다");
			// 회원 수정이 성공 => 로그인 유지 + 바뀐 회원 정보를 session에.
			session.setAttribute("member", memUpdate); // ${member}
			return "redirect:/";					
		} else {
			rttr.addFlashAttribute("msgType", "실패 메시지");
			rttr.addFlashAttribute("msg", "회원 정보 수정에 실패하였습니다. 다시 시도해주세요");
			return "redirect:/memUpdateForm.do";
		}
	}
	
	@RequestMapping("/memImageForm.do")
	public String memImageForm() {
		return "member/memImageForm";
	}
	
	@RequestMapping("/memImageUpdate.do")
	public String memImageUpdate(HttpServletRequest request, RedirectAttributes rttr, HttpSession session) {
		// 파일 업로드 API => 그중 cos.jar를 사용
		
		MultipartRequest multi = null;								// 업로드를 하는 객체
		int fileMaxSize = 10 * 1024 * 1024;							// 업로드할 파일 최대 크기 10MB
		String savePath = request.getRealPath("resources/upload");	// 업로드할 경로
		try {
			// 객체를 생성할 때 request 정보, 업로드할 경로, 업로드할 크기, 인코딩 정보, 파일명이 중복될 경우 리네임을 해줄 클래스인 DefaultFileRenamePolicy 객체가 필요하다
			multi = new MultipartRequest(request, savePath, fileMaxSize, "UTF-8", new DefaultFileRenamePolicy());	// 이미지 업로드
		} catch(Exception e) {
			e.printStackTrace();
			// 예외발생(파일크기가 넘어섰을 때)
			rttr.addFlashAttribute("msgType", "실패 메시지");
			rttr.addFlashAttribute("msg", "파일의 크기는 10MB를 초과할 수 없습니다");
			return "redirect:/memImageForm.do";
		}
		
		// 정상적으로 업로드가 된 상태임 => 단, 이미지 파일 여부 체크하여 이미지 파일이 아니면 삭제 & 기존에 이미지를 등록했었을 경우 기존 이미지 삭제
		String memID = multi.getParameter("memID");	// MultipartRequest 객체로 요청 데이터를 이미 받아놓았다
		String newProfile = "";
		
		File file = multi.getFile("memProfile");	// 폼에서 memProfile를 통해 업로드된 파일에 대한 파일 객체 
		if(file != null) {
			// 확장자를 통해 이미지 파일 여부를 체크
			String ext = file.getName().substring(file.getName().lastIndexOf(".")+1);
			ext = ext.toUpperCase();
			if(ext.equals("PNG") || ext.equals("JPG") || ext.equals("GIF")) { // 이미지 파일 O
				Member mProfile = memberMapper.memCheck(memID);
				String oldProfile = mProfile.getMemProfile();
				File oldFile = new File(savePath, oldProfile);
				if(oldFile.exists()) {	// 기존에 등록한 이미지가 있다면 삭제
					oldFile.delete();
				}
				newProfile = file.getName();
			} else {														  // 이미지 파일 X
				if(file.exists()) {
					file.delete();
				}
				rttr.addFlashAttribute("msgType", "실패 메시지");
				rttr.addFlashAttribute("msg", "이미지 파일만 업로드할 수 있습니다");
				return "redirect:/memImageForm.do";
			}
		}
		
		// 업로드된 상태 O + 이미지 파일 O + 기존에 등록되었던 경우 삭제 O => 이제 DB 작업
		Member mProfile = new Member();
		mProfile.setMemID(memID);
		mProfile.setMemProfile(newProfile);
		memberMapper.memProfileUpdate(mProfile);	// 이미지 DB 업데이트
		
		// 업데이트 된 회원 정보로 세션을 새롭게 생성
		Member sMember = memberMapper.memCheck(memID);
		session.setAttribute("member", sMember);
		
		// 객체 바인딩
		rttr.addFlashAttribute("msgType", "성공 메시지");
		rttr.addFlashAttribute("msg", "사진 등록에 성공하였습니다");
		
		return "redirect:/";
	}
}
