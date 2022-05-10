// SPDX-License-Identifier: MIT


// 컴파일러 버전 맞추기 - 왼쪽 체크 표시 확인
pragma solidity ^0.8.0;

//import "https://github.com/openzeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol";


// Context, IERC20 등 import 필요
contract ERC20 {
    mapping (address => uint256) private _balances;
    // add(지갑주소): key - uint(잔고): value 로 이루어진 자료구조, 누가 얼마 들고있다
    // mapping : 맵 자료구조 (표)


    mapping (address => mapping (address => uint256)) private _allowances;
    // value 안에 또 map 자료구조(권한 양도 상태)가 들어가있음
    // B =>  mapping(A => amount) : B 가 A의  amount 만큼의 권한을 양도 받았다


    //총 발행량 설정
    uint256 private _totalSupply = 2100000000;

    string private _name;    //NFTDAO
    string private _symbol;    //NDO

    //ETH network 배포시 생성자
    constructor (string memory name_, string memory symbol_) { //생성자
        _name = name_;
        _symbol = symbol_;
        
        //전부 나한테 전송
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        // 소숫점이하2자리수까지
        // 보통 ERC20은 18 사용
        return 2;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    // key: 지갑주소, 누가 얼마를 들고있는지를 반환해주는 함수
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
        //view : 조회만 가능하고 상태변경 x 
        // override : 물려받는 함수, 복잡, ierc20 부모 컨트렉트에 정의된것을 물려받는...
        //virtual : 여러가지 의미 
        //returns : 어떤 데이터를 돌려줄지 , 여기서는 정수 타입 리턴하겟다는 뜻
    }

     //토큰 전송 함수
     // address to : 누구한테 전송할지 변수
     // amount : 량
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        //owner : 스마트컨트랙트 내부에서 지원하는 함수 중, 이 함수를 '누가' 호출하는지 데이터를 알 수 있음.

        _transfer(msg.sender, recipient, amount);        //owner 로부터 to 한테 amount를 보낸다
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }


    //apporve 된 현황 리턴만 해줌
    //ower : 주인 spender : 권한 양도받아서 쓸 수 잇는사람 주소 
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        //조건 만족시 실행, 불만족시 출력
        //0: 소각주소
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        //_beforeTokenTransfer(from, to, amount);
        // 빈함수, 알아서 구현

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        // emit: smart contract 내 event 키워드. 이 이벤트 발생시 - 블록에 로그 생성
        // allowance와 transfer 경우 로그를 발생해서 블록에 남겨야됨
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        //allowances : map 안에 map 이 있음. 첫번째구조에 소유자, 두번째에 양도자, amount 세팅 후 끝남
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



