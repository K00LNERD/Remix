// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./TransferHelper.sol";


interface oracleInterface {
    function latestAnswer() external view returns (int256);
}
interface Token{
    function decimals() external view returns(uint256);
    function symbol() external view returns(string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract CMNPublicSale is Ownable{
    using SafeMath for uint256;
    
    uint256 decimalFactor;
    uint256 public ICoStartTimeStamp;
    
    address public tokenContractAddress= 0x2dFBedC45A8a1FA0A14CAcacC0c1cbd88946326c;
    address public adminAddress=0x31e2886174b4974066566209f0b3265810b35d23;
    address public BUSDContractAddress= 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public BNBOracleAddress=0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    address public BUSDOracleAddress=0xcBb98864Ef56E9042e7d2efef76141f15731B82f;
    uint256 ICOTokens=3000000;
    uint256 public ICOPeriod=30 days;
    
    address public IEO=0xe02828d957eE07505Fc6F87Bbf08c041545FEB80;
    address public EcoMarketingSystem=0x0b8F27F1637E8fF7B3be14A4343bB5fC11282428;
    uint256 public tokenPrice=80;// in 10**2..
    uint256 referrelCommissionPercentage=500;// in 10**2
    uint256 tokenSold;
    bool isTransferedLeftICO=false;
    bool isTransferedLeftMarketing=false;
    
    event BuyTokenEvent(address indexed userAdress, uint256 tokenAmount, uint256 inputAmount, uint8 indexed currencyType, uint256 timestamp);
    event ReferralEvent(address indexed userAdress, uint256 referralCommision, address fromAddress, uint256 timestamp);
    
    struct UserInfo{
        address referralAddress;
        bool isReferralPaid;
        bool isRegistered;
    }
    mapping(address=>UserInfo) public userMapping;
    
    constructor(){
        decimalFactor=10**Token(tokenContractAddress).decimals();
        ICoStartTimeStamp=block.timestamp;
    }
    
    function registerUser(address refferalAddress) external{
        require(userMapping[refferalAddress].isRegistered || refferalAddress==address(0), "Referral address is not registered.");
        require(!userMapping[msg.sender].isRegistered, "This address is already registered.");
        UserInfo memory uInfo= UserInfo({
            referralAddress:refferalAddress,
            isReferralPaid:false,
            isRegistered:true
        });
        userMapping[msg.sender]=uInfo;
    }
    
    function buyTokens(uint8 currencyType, uint256 amount) external payable{
        //currencyType--> 1=BNB, currencyType-->2=BUSD
        require(userMapping[msg.sender].isRegistered, "This address is not registered.");
        require(block.timestamp<=ICoStartTimeStamp.add(ICOPeriod), "ICO Ended");
        require(tokenSold<ICOTokens.mul(decimalFactor),"ICO Ended");
        uint256 noOfTOkens;
        uint256 referralCommision;
        uint256 inputAmount;
        if(currencyType==1){
            inputAmount=msg.value;
        }else{
            Token tokenObj = Token(BUSDContractAddress);
            require(tokenObj.balanceOf(msg.sender) >= amount, "You do not have enough BUSD balance");
            require(tokenObj.allowance(msg.sender,address(this)) >= amount, 
                                            "Please allow smart contract to spend on your behalf");
            inputAmount=amount;
        }
        (noOfTOkens,referralCommision)=calculateToken(currencyType,inputAmount);
        require(noOfTOkens<=Token(tokenContractAddress).balanceOf(address(this)),"Not enough tokens available to buy.");
        require(noOfTOkens.add(tokenSold)<=ICOTokens.mul(decimalFactor),"Do not have enough token in ICO");
        if(currencyType==1){
            TransferHelper.safeTransferETH(adminAddress,msg.value);
        }else{
            TransferHelper.safeTransferFrom(BUSDContractAddress, msg.sender,adminAddress,amount);
        }
        if(userMapping[msg.sender].referralAddress==address(0)){
            TransferHelper.safeTransfer(tokenContractAddress,msg.sender, noOfTOkens);
        }else{
            TransferHelper.safeTransfer(tokenContractAddress,msg.sender, noOfTOkens);
            if(!(userMapping[msg.sender].isReferralPaid)){
                TransferHelper.safeTransfer(tokenContractAddress,userMapping[msg.sender].referralAddress,referralCommision);
                userMapping[msg.sender].isReferralPaid=true;
                emit ReferralEvent(userMapping[msg.sender].referralAddress,referralCommision,msg.sender,block.timestamp);
            }
        }
        tokenSold=tokenSold.add(noOfTOkens);
        emit BuyTokenEvent(msg.sender,noOfTOkens,inputAmount,currencyType, block.timestamp);
    }
    function calculateToken(uint8 currencyType, uint256 amount) public view returns(uint256, uint256){
        //currencyType--> 1=BNB, currencyType-->2=BUSD
        require(amount>0,"Please enter amount greater than 0.");
        uint256 amountInUSD;
        uint256 decimalValue;
        if(currencyType==1){
            amountInUSD=(uint256)(oracleInterface(BNBOracleAddress).latestAnswer());
            decimalValue=10**18;
        }else{
            amountInUSD=(uint256)(oracleInterface(BUSDOracleAddress).latestAnswer());
            decimalValue=10**Token(BUSDContractAddress).decimals();
        }
        uint256 tokenAmount=((amountInUSD.mul(10**2).mul(decimalFactor).mul(amount)).div(tokenPrice.mul(decimalValue).mul(10**8)));
        uint256 referralCommission=(referrelCommissionPercentage.mul(tokenAmount)).div(10**4);
        return (tokenAmount,referralCommission);
    }
    function transferTokenToIEOOnICUEnd() external onlyOwner{
        if(block.timestamp>ICoStartTimeStamp.add(ICOPeriod) || tokenSold==ICOTokens.mul(decimalFactor)){
            uint256 icoLeft=(ICOTokens.mul(decimalFactor)).sub(tokenSold);
            uint256 returnToMarketing=(Token(tokenContractAddress).balanceOf(address(this))).sub(icoLeft);
            if(IEO!=address(0) && (!isTransferedLeftICO)){
                TransferHelper.safeTransfer(tokenContractAddress,IEO, icoLeft);
                isTransferedLeftICO=true;
            }
            if(EcoMarketingSystem!=address(0) && (!isTransferedLeftMarketing)){
                TransferHelper.safeTransfer(tokenContractAddress,EcoMarketingSystem, returnToMarketing);
                isTransferedLeftMarketing=true;
            }
        }
    }
    function tokenLeft() external view returns(uint256){
        return ((ICOTokens.mul(decimalFactor)).sub(tokenSold));
    }
    function updateTokenAddress(address _tokenContractAddress) external onlyOwner{
        tokenContractAddress=_tokenContractAddress;
    }
    function updateBUSDContractAddress(address _BUSDContractAddress) external onlyOwner{
        BUSDContractAddress=_BUSDContractAddress;
    }
    function updateBNBOracleAddress(address _BNBOracleAddress) external onlyOwner{
        BNBOracleAddress=_BNBOracleAddress;
    }
    function updateBUSDOracleAddress(address _BUSDOracleAddress) external onlyOwner{
        BUSDOracleAddress=_BUSDOracleAddress;
    }
    function updateAdminAddress(address _adminAddress) external onlyOwner{
        adminAddress=_adminAddress;
    }
    function updateIEOAddress(address _IEO) external onlyOwner{
        IEO=_IEO;
    }
    function updateEcoMarketingSystem(address _EcoMarketingSystem) external onlyOwner{
        EcoMarketingSystem=_EcoMarketingSystem;
    }
}
