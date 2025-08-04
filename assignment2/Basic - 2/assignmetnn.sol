pragma solidity >=0.5.0 <0.6.0;

contract WasteManagement {
    // Entity Creation
    struct Citizen {
        string name;
        address wallet;
        uint points;
        bool isRegistered;
    }
    
    mapping(address => Citizen) public citizens;
    uint public citizenCount;
    
    // Data Submission
    struct WasteDisposal {
        address citizen;
        uint weight;
        bool recycled;
        uint timestamp;
    }
    
    WasteDisposal[] public disposals;
    
    // Token Logic (ERC20-based)
    mapping(address => uint) public balances;
    
    // Events
    event CitizenRegistered(address indexed wallet, string name);
    event WasteLogged(address indexed citizen, uint weight, bool recycled);
    event TokensAwarded(address indexed citizen, uint amount);
    
    // Modifiers
    modifier onlyRegistered() {
        require(citizens[msg.sender].isRegistered, "Not registered");
        _;
    }
    
    // Entity Registration
    function registerCitizen(string memory _name) public {
        require(!citizens[msg.sender].isRegistered, "Already registered");
        citizens[msg.sender] = Citizen(_name, msg.sender, 0, true);
        citizenCount++;
        emit CitizenRegistered(msg.sender, _name);
    }
    
    // Data Submission
    function logWaste(uint _weight, bool _recycled) public onlyRegistered {
        require(_weight > 0, "Invalid weight");
        disposals.push(WasteDisposal(msg.sender, _weight, _recycled, block.timestamp));
        
        // Reward calculation (10 tokens/kg + 50% bonus for recycling)
        uint reward = _weight * 10 * (_recycled ? 15 : 10) / 10;
        balances[msg.sender] += reward;
        citizens[msg.sender].points += reward;
        
        emit WasteLogged(msg.sender, _weight, _recycled);
        emit TokensAwarded(msg.sender, reward);
    }
    
    // Optional Token Transfer
    function transferTokens(address _to, uint _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}