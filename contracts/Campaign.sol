pragma solidity ^0.6.0;

//Campaign contract 

contract Campaign {
    
    /////////////
    //Variables//
    ////////////
    address public campaignOwner;
    uint public minimumContribution;
    mapping(address => bool) public contributors;
    uint public contributorCount;
    uint public totalContributions;
    
    struct Request {
        string description;
        uint value;
        address recepient;
        uint approvalCount;
        mapping(address => bool) approvals;
        bool complete;
    }
    
    Request[] public requests;
    
    ///////////////
    //constructor//
    //////////////
    constructor(uint _minimumContribution) public{
        campaignOwner = msg.sender;
        minimumContribution = _minimumContribution;
    }
    
    /////////////
    //modifiers//
    ////////////
    modifier checkContribution(){
        require(msg.value >= minimumContribution, "Should be greater than or equal to minimumContribution");
        _;
    }
    
    modifier restricted(){
        require(msg.sender == campaignOwner,"Only Campaign Owner can call the function");
        _;
    }
    
    /////////////
    //functions//
    ////////////
    
    //1. Contribute function to handle contributors//
    function contribute() public payable checkContribution {
        contributors[msg.sender] = true;
        contributorCount++;
        totalContributions +=msg.value;
    }
    
    //2. Create Request 
    function createRequest(string memory _description, uint _value, address _recepient) public restricted{
        require(_value <= totalContributions, "Should not be able send more than total amount of contributions");
        Request memory newRequest = Request({
            description: _description,
            value:_value,
            recepient: _recepient,
            approvalCount: 0,
            complete:false
        });
        
        requests.push(newRequest);
    }
    
    //3. Approve request voting mechanism 
    function approveRequest(uint _index) public {
        require(contributors[msg.sender],"Should be called by contributors only");
        require(!requests[_index].approvals[msg.sender], "Cannot approve more than once");
        
        requests[_index].approvals[msg.sender] = true;
        requests[_index].approvalCount++;
    }
    
    //4. finalise the request
    function finalizeRequest(uint _index) public restricted{
        require(!requests[_index].complete, "Should not be completed");
        require(requests[_index].approvalCount > (contributorCount /2 ), "Should be greater than 50%");
        totalContributions -= requests[_index].value;
        payable(requests[_index].recepient).transfer(requests[_index].value);
        requests[_index].complete = true;
    }
    
    
}