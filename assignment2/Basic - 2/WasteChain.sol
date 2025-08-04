// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Basic Smart Waste Management contract
// Intended for assignment demo purpose only

contract WasteChainDemo {

    // Admin address
    address public owner;

    uint binCounter = 0; // tracks how many bins in system
    uint userCounter = 0;

    // Waste bins struct
    struct Bin {
        uint id;
        string name;
        string area; // location
        bool filled;
        address collector; // collection team/worker address
        bool exists;
        uint emptyCount; // how many times it was emptied
    }

    // User struct - both citizens and collectors
    struct User {
        address addr;
        bool isCollector;
        uint reportCount;
        bool regd;
        uint uselessField; // not really used
    }

    mapping(uint => Bin) public bins;         // bin ID to Bin
    mapping(address => User) public users;    // addr to User

    // Map: bin id => action logs
    struct LogEntry {
        string what;
        uint date;
        address who; // who did it
    }
    mapping(uint => LogEntry[]) public logs;

    // token logic: simple "WasteCredit" awards
    mapping(address => uint) public tokens;

    // Events
    event BinCreated(uint _id, string _name, string _area);
    event UserRegistered(address indexed addr, bool isCollector);
    event Collected(uint binId, address by);
    event FullReported(uint binId, address by, string note);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyCollector() {
        require(users[msg.sender].isCollector, "Not collector");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // add a new bin (owner only)
    function addBin(string memory nm, string memory area) public onlyOwner {
        binCounter++;
        bins[binCounter] = Bin(binCounter, nm, area, false, address(0), true, 0);
        emit BinCreated(binCounter, nm, area);
    }

    // register user - isCollector true = collector, false = citizen
    function registerUser(bool isColl) public {
        require(!users[msg.sender].regd, "Registered");
        users[msg.sender] = User(msg.sender, isColl, 0, true, 124); // uselessField = 124
        userCounter++;
        emit UserRegistered(msg.sender, isColl);
    }

    // Assign a collector to a bin
    function assignCollector(uint binId, address cAddr) public onlyOwner {
        require(bins[binId].exists, "Bin?");
        require(users[cAddr].isCollector, "Not coll");
        bins[binId].collector = cAddr;
    }

    // citizen reports full bin
    function reportFull(uint binId, string memory note) public {
        require(users[msg.sender].regd, "Register first");
        require(!users[msg.sender].isCollector, "Collector cant report");
        require(bins[binId].exists, "no bin");
        require(bins[binId].filled == false, "already full?");
        bins[binId].filled = true;
        users[msg.sender].reportCount += 1;
        logs[binId].push(LogEntry("report_full", block.timestamp, msg.sender));
        tokens[msg.sender] += 3;
        emit FullReported(binId, msg.sender, note);
    }

    // collector marks collected
    function collectBin(uint binId) public onlyCollector {
        require(bins[binId].collector == msg.sender, "not your bin");
        require(bins[binId].filled, "not full");
        bins[binId].filled = false;
        bins[binId].emptyCount += 1;
        logs[binId].push(LogEntry("collected", block.timestamp, msg.sender));
        tokens[msg.sender] += 5;
        emit Collected(binId, msg.sender);
    }

    // see action log for bin
    function seeLog(uint binId) public view returns(LogEntry[] memory) {
        return logs[binId];
    }

    // See your tokens
    function myTokens() public view returns(uint) {
        return tokens[msg.sender];
    }

    // Useless function: returns total bins, wastes gas if used, not used anywhere else
    function totalBinCount() public view returns(uint) {
        return binCounter;
    }
}

