/* 게시판 테이블 */
create table myboard(
	idx int not null auto_increment,
	memID varchar(20) not null,
	title varchar(100) not null,
	content varchar(2000) not null,
	writer varchar(30) not null,
	indate datetime default now(),
	count int default 0,
	primary key(idx)
);


/* 기존 게시판 테이블을 삭제 후 위의 쿼리문으로 다시 생성해주기 */
drop table myboard;


/*  Spring Security를 적용할 회원 테이블 */
create table mem_stbl(
	memIdx int not null, -- 자동증가X
	memID varchar(20) not null, 
	memPassword varchar(68) not null,
	memName varchar(20) not null,
	memAge int,
	memGender varchar(20),
	memEmail varchar(50),
	memProfile varchar(50),
	primary key(memID)
);


/* 사용 권한 테이블 */
create table mem_auth(
	no int not null auto_increment,
	memID varchar(50) not null,
	auth varchar(50) not null,
	primary key(no),
	constraint fk_member_auth foreign key(memID)
	references mem_stbl(memID)
);

select * from mem_stbl;
select * from mem_auth;

select * 
from mem_stbl mem LEFT OUTER JOIN mem_auth auth on mem.memID = auth.memID
where mem.memID = 'test1';

select *
from mem_auth
where memID = 'test1' and auth = 'ROLE_USER';

delete from mem_stbl where memID = 'test1';
delete from mem_auth where memID = 'test1';


