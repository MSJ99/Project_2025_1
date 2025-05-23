[화면별 기능 요구사항]

[Sign_in]
    객체: ID 적는 칸, Password 적는 칸, Sign in 버튼, Sign up 버튼, Continue with Google 버튼
    Sign in 버튼: 탭하면 로그인 기능 수행하고, 로그인 성공 시 [Home] 화면으로 이동
    Sign up 버튼: 탭하면 [Register] 화면으로 이동
    Continue with Google 버튼: 탭하면 구글 계정으로 로그인하는 기능 수행 (Google Sign in API와 연동되어야 함) 

[Register]
    객체: ID 적는 칸, Password 적는 칸, Register 버튼, Already have an account? 버튼
    Register 버튼: 탭하면 회원가입 기능 수행하고, [Home]으로 이동
    Already have an account? 버튼: 탭하면 [Sign_in] 화면으로 이동

[Home]
    객체: 하단 바, 리스트, Add 버튼, 검색 바
    하단 바:
        3개의 버튼을 객체로 가지는 BottomNavigationBar
        Home 버튼: 탭하면 [Home] 화면으로 이동
        Map 버튼: 탭하면 [Map] 화면으로 이동
        Preference 버튼: 탭하면 [Preference] 화면으로 이동
    Add 버튼: 탭하면 [Add] 화면으로 이동
    리스트:
        주소, 이미지, 태그, Favorite 버튼을 포함한 카드 형식의 ListView (스크롤 가능)
        카드를 탭하면 매물 상세 화면인 [info]를 위에 띄움
        Favorite 버튼: 탭하면 isFavorite 변수의 값을 반전시키고, 버튼의 이미지를 변경
    검색 바:
        왼쪽에 Filter 버튼, 오른쪽에 Search 버튼을 가지는 SearchBar
        Search 버튼: 탭하면 검색 기능 수행 (새 화면 생성하지 않음)
        Filter 버튼: 탭하면 필터 기능 수행 (새 화면 생성하지 않음)

[Info]
    객체: [Home] 화면의 리스트 내에 있는 카드 (확대됨), Edit 버튼, Undo 버튼
    [Info] 화면은 [Home] 화면의 위 또는 [Map] 화면의 위에 표시되는 창 화면이다
    Edit 버튼: 탭하면 [Edit] 화면으로 이동
    Undo 버튼: 탭하면 이전 화면으로 이동

[Edit]
    객체: (이미지 첨부 버튼, 주소 적는 칸, 종류 적는 칸, 층수 적는 칸, 평수 적는 칸, 가격 적는 칸, 옵션 적는 칸, 연락처 적는 칸, 태그 적는 칸)을 포함하는 스크롤 가능한 화면, Edit 버튼, Delete 버튼, Undo 버튼
    Edit 버튼: 탭하면 기존 매물 정보를 수정 및 저장하고, 이전 화면으로 이동
    Delete 버튼: 탭하면 매물 정보를 삭제하고, 이전 화면으로 이동
    Undo 버튼: 탭하면 이전 화면으로 이동

[Add]
    객체: (이미지 첨부 버튼, 주소 적는 칸, 종류 적는 칸, 층수 적는 칸, 평수 적는 칸, 가격 적는 칸, 옵션 적는 칸, 연락처 적는 칸, 태그 적는 칸)을 포함하는 스크롤 가능한 화면, Add 버튼, Undo 버튼
    Add 버튼: 탭하면 새 매물 정보를 저장하고, 이전 화면으로 이동
    Undo 버튼: 탭하면 이전 화면으로 이동

[Map]
    객체: 하단 바, 지도, 검색 버튼
    하단 바:
        3개의 버튼을 객체로 가지는 BottomNavigationBar
        Home 버튼: 탭하면 [Home] 화면으로 이동
        Map 버튼: 탭하면 [Map] 화면으로 이동
        Preference 버튼: 탭하면 [Preference] 화면으로 이동
    지도:
        지도 화면을 표시하는 지도 객체, Naver Map API와 연동되어야 함, Naver Map API의 기능 중 마커 표시, 마커 클릭 시 매물 상세 화면인 [info]를 위에 띄움
    검색 버튼: 탭하면 [Search_Address] 화면으로 이동

[Search_Address]
    객체: 검색 바
    검색 바:
        오른쪽에 Search 버튼을 가지는 SearchBar
        Search 버튼: 탭하면 도로명주소를 검색하면 해당 주소로 지도 화면을 이동시키는 기능 수행

[Preference]
    객체: 하단 바, 사용자 프로필, Log Out 버튼
    하단 바:
        3개의 버튼을 객체로 가지는 BottomNavigationBar
        Home 버튼: 탭하면 [Home] 화면으로 이동
        Map 버튼: 탭하면 [Map] 화면으로 이동
        Preference 버튼: 탭하면 [Preference] 화면으로 이동
    사용자 프로필:
        사용자 프로필 이미지, 사용자 이름, 사용자 이메일 정보를 포함하는 카드 형식의 위젯
    Log Out 버튼: 탭하면 로그아웃 기능 수행