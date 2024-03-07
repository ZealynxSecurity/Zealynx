# How can Fuzzing and Formal Verification improve Security Reviews?
Fuzzing and Formal Verification are the perfect companions for Manual Security Reviews and the best way to improve and complement your testing suite to mathematically prove its code correctness and protect it from non-obvious vulnerabilities.

## Fuzzing 
With Fuzzing is like hiring a large amount of testers that would sit down 24/7 to randomly test all the features and functions of your contracts. 

You need to consider that using a tool for fuzzing will run in seconds a very large amount of possible sequences randomly to try to break the logic. Hence, the time and money saved is ridiculously big.

## Formal Verification
With that handbook (docs and theory) by hand, allows one to mathematically guarantee the correctness of the code. It uses mathematical models to simulate every conceivable way someone could interact with this contract. If the verification process shows that the contract's logic holds under all these scenarios - never locking up funds accidentally, always distributing rewards correctly, etc. - then we have a mathematical guarantee of its correctness.

Often, software fails under conditions the developers didn't anticipate. A mathematical guarantee ensures that the software has been tested (in theory) against every possible input or scenario it might encounter, not just the ones thought of by the developers.

## The best of two worlds
Bring together the brute force of Fuzzing with the intellectuality of Formal Verification because each has its benefits and gaps which combined and mixed with Manual Security Review will take you a step further to secure your smart contracts.