
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public deadline;
    mapping(address => uint256) public contributions;
    bool public goalReached;
    bool public deadlineReached;

    event Contribution(address indexed contributor, uint256 amount);
    event GoalReached(uint256 totalAmount);
    event DeadlineReached(uint256 totalAmount);

    constructor(uint256 _goal, uint256 _durationInMinutes) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Crowdfunding is closed");
        contributions[msg.sender] += msg.value;
        emit Contribution(msg.sender, msg.value);
        checkGoalReached();
    }

    function checkGoalReached() private {
        if (!goalReached && address(this).balance >= goal) {
            goalReached = true;
            emit GoalReached(address(this).balance);
        }
        if (block.timestamp >= deadline) {
            deadlineReached = true;
            emit DeadlineReached(address(this).balance);
        }
    }

    function withdrawFunds() public {
        require(goalReached || deadlineReached, "Funds cannot be withdrawn yet");
        require(msg.sender == owner, "Only the owner can withdraw funds");
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
    }

    function getRefund() public {
        require(deadlineReached && !goalReached, "Refunds are not available");
        require(contributions[msg.sender] > 0, "You have not contributed");
        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
