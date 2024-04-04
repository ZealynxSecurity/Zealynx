## 🟧 Foundry Fuzz test challenge for beginners 🟧

### Do you know why this foundry fuzz test works even if no one has funded the account that transfers ether?

```
import "forge-std/Test.sol";

contract SafeTest is Test {
    Safe safe;

    // Needed so the test contract itself can receive ether
    // when withdrawing
    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }

    function test_Withdraw() public {
        payable(address(safe)).transfer(1 ether);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + 1 ether, postBalance);
    }
}

```

Why does 'SafeTest' contract have a non-zero balance at the very start of testWithdraw()??

Shouldn't it be using "vm deal" to add some ether?

🧐🧐🧐🧐🧐🧐🧐🧐🧐🧐🧐🧐🧐

Give it a thought and try to find out!

➖➖➖➖➖➖➖➖➖➖➖➖➖

The unexpectedly high balance is due to the nature of how Foundry sets up the testing environment, particularly for contracts inheriting from forge-std/Test.sol.

Here are some key points to consider:

🟠 Initial Balance in Foundry Tests: When you run tests using Foundry, each test contract is endowed with a large amount of Ether by default. This default behavior is part of Foundry's design to simplify the testing process. It ensures that the test contracts have sufficient funds for various operations without the need for explicit funding in each test.

🟠 Understanding the Balance: The balance 79228162514264337593543950335 seen in your logs is actually 2^96 - 1 Wei, which is a deliberately chosen high value. This large balance is intended to simulate a rich account, allowing you to test transactions and interactions without worrying about running out of Ether.

🟠 Implications for Testing: When writing tests, especially those that involve Ether transfers or balance assertions, it's essential to account for this initial endowment. Tests should be designed with the understanding that the test contract starts with this high balance.

🟠 Modifying the Test for Clarity: To make the test more explicit and clear about the initial conditions, you can log the initial balance at the start of the setUp() function. This will make it evident to anyone reading the test logs that the contract starts with a non-zero balance.

🟠 Further Considerations: If the default balance behavior is not desirable for a specific test scenario, you can manipulate the starting balance by using Foundry's cheat codes, like vm. deal(address(this), amount), to set a specific balance before the test begins.

In summary, the non-zero balance is due to Foundry's testing environment setup. It's a feature, not a bug, designed to simplify testing scenarios but requires careful consideration when writing balance-related assertions in tests.