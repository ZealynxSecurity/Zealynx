// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {OLAS} from "../OLAS.sol";
import {veOLAS} from "../veOLAS.sol";


contract veOLASTest is Test {
    OLAS public olas;
    veOLAS public veolas;

    address public alice;
    address public bob; //owner
    address public seco; //owner

    uint256 constant oneOLABalance = 1; // 1 OLAS, ajusta según sea necesario
    uint256 constant twoOLABalance = 2; // 1 OLAS, ajusta según sea necesario
    uint256 constant tenOLABalance = 10; // 10 OLAS, ajusta según sea necesario
    uint256 constant oneWeek = 1 weeks; // Duración del bloqueo de una semana
    uint256 constant initialMint = 1000000;


    function setUp() public {
        olas = new OLAS();

        address randomId1 = address(olas);
        string memory randomId2 = "name";
        string memory randomId3 = "symbol";

        alice = vm.addr(1);
        bob = vm.addr(2);
        seco = vm.addr(3);
        vm.prank(bob);
        veolas = new veOLAS(randomId1,randomId2,randomId3);
        olas.mint(bob, initialMint);

    }

    function check_testFuzz3(uint256 amount, uint256 unlockTime) public {
        veolas.createLock(amount,unlockTime);

    }

// =======================================================   
            //            //  
            // Balance y supply //
            //            //    

// Copy Hardhat Test
    function testBalanceAndSupply() public {

        vm.prank(bob);
        // Transferir 10 OLAS a account
        olas.transfer(alice, tenOLABalance);
        vm.prank(bob);

        // Aprobar OLAS para el contrato veOLAS
        olas.approve(address(veolas), oneOLABalance);
        vm.prank(alice); // Impersonar account para la aprobación
        olas.approve(address(veolas), tenOLABalance);

        // Verificar suministro inicial
        assertEq(veolas.totalSupply(), 0, "El suministro total inicial no es 0");

        uint256 lockDuration = oneWeek; // Duración de 1 semana
        vm.prank(bob);
        // Crear bloqueos
        veolas.createLock(oneOLABalance, lockDuration);
        vm.prank(alice); // Impersonar account para crear bloqueo
        veolas.createLock(twoOLABalance, lockDuration);

        // Verificar suministro y balance
        uint256 balanceDeployer = veolas.getVotes(address(bob));
        uint256 balanceAccount = veolas.getVotes(alice);
        uint256 supply = veolas.totalSupplyLocked();
        uint256 sumBalance = balanceAccount + balanceDeployer;
        assertEq(supply, sumBalance, "El suministro total no coincide con la suma de los balances");

        uint256 blockNumber = block.number; // Número de bloque actual en Foundry

        // Verificar balance en un bloque específico
        balanceDeployer = veolas.balanceOfAt(address(bob), blockNumber);
        balanceAccount = veolas.balanceOfAt(alice, blockNumber);
        supply = veolas.totalSupplyAt(blockNumber);
        sumBalance = balanceAccount + balanceDeployer;
        assertEq(supply, sumBalance, "El suministro total en el bloque no coincide con la suma de los balances");
    }

// NO correcto, Revisar
    // function testFuzz_BalanceAndSupply(uint256 ttenOLABalance1, uint256 toneOLABalance1,uint256 ttwoOLABalance1, uint256 oneWeek1) public {

    //     uint256 tenOLABalance1 = _between(ttenOLABalance1, 1, type(uint96).max);
    //     uint256 oneOLABalance1 = _between(toneOLABalance1, 1, type(uint96).max);
    //     uint256 twoOLABalance1 = _between(ttwoOLABalance1, 1, type(uint96).max);

    //     vm.assume(tenOLABalance1 >= oneOLABalance1 + twoOLABalance1);
        
    //     vm.prank(bob);
    //     // Transferir 10 OLAS a account
    //      bool succes = olas.transfer(alice, tenOLABalance1);
    //      require (succes);
    //     vm.prank(bob);

    //     // Aprobar OLAS para el contrato veOLAS
    //     olas.approve(address(veolas), oneOLABalance1);
    //     vm.prank(alice); // Impersonar account para la aprobación
    //     olas.approve(address(veolas), tenOLABalance1);

    //     // Verificar suministro inicial
    //     assertEq(veolas.totalSupply(), 0, "El suministro total inicial no es 0");

    //     uint256 lockDuration = oneWeek1; // Duración de 1 semana
    //     vm.assume(lockDuration != 0);
    //     vm.expectRevert(bytes("UnlockTimeIncorrect"));

    //     vm.prank(bob);
    //     // Crear bloqueos
    //     veolas.createLock(oneOLABalance1, lockDuration);
    //     vm.prank(alice); // Impersonar account para crear bloqueo
    //     veolas.createLock(twoOLABalance1, lockDuration);

    //     // Verificar suministro y balance
    //     uint256 balanceDeployer = veolas.getVotes(address(bob));
    //     uint256 balanceAccount = veolas.getVotes(alice);
    //     uint256 supply = veolas.totalSupplyLocked();
    //     uint256 sumBalance = balanceAccount + balanceDeployer;
    //     assertEq(supply, sumBalance, "El suministro total no coincide con la suma de los balances");

    //     uint256 blockNumber = block.number; // Número de bloque actual en Foundry

    //     // Verificar balance en un bloque específico
    //     balanceDeployer = veolas.balanceOfAt(address(bob), blockNumber);
    //     balanceAccount = veolas.balanceOfAt(alice, blockNumber);
    //     supply = veolas.totalSupplyAt(blockNumber);
    //     sumBalance = balanceAccount + balanceDeployer;
    //     assertEq(supply, sumBalance, "El suministro total en el bloque no coincide con la suma de los balances");
    // }

// =======================================================   
            //            //  
            // DEPOSITFOR //
            //            //    

// Copy Hardhat Test
    function test_depositFor() public {
        // PRECONDITIONS:
        uint256 originalLocked = veolas.balanceOf(alice);

        vm.startPrank(bob);
        olas.transfer(address(alice), tenOLABalance);
        olas.approve(address(veolas), oneOLABalance);
        vm.stopPrank();

        vm.prank(alice);
        olas.approve(address(veolas), oneOLABalance);

        vm.prank(bob);
        veolas.createLock(oneOLABalance, oneWeek);

        uint256 supplyBefore = veolas.totalSupply();

        // ACTION:
        vm.prank(alice); // Impersonar account para realizar el depósito
        veolas.depositFor(bob, oneOLABalance);

        // POSTCONDITIONS:
        uint256 supplyAfter = veolas.totalSupply();
        uint256 updatedLocked = veolas.balanceOf(alice);

        // 1. La suma de supply debe ser igual a la suma de todos los LockedBalance.amount
        assertEq(supplyAfter, supplyBefore + oneOLABalance, "Invariant: Supply consistency");
        // 3. Verifica que supply aumente con depósitos positivos
        assertGt(supplyAfter, supplyBefore, "Invariant: Supply increment on deposit");
        // 4. Verifica consistencia en la creación o extensión de bloqueos
        // assertEq(updatedLocked, originalLocked + oneOLABalance, "Invariant: Locked amount consistency");
    }

//Revisar
    // function testFuzz_depositFor(uint256 rawAmount) public {
    //     // Asegurar que rawAmount no sea cero
    //     vm.assume(rawAmount > 0);

    //     // Ajustar rawAmount para que sea un valor razonable
    //     uint256 amount = _between(rawAmount, 1, type(uint96).max);

    //     uint256 PaliceBalance = veolas.balanceOf(alice);
    //     uint256 tries = 0; // Para evitar un bucle infinito

    //     uint256 amountA = 0;
    //     // Asegura que 'amount' sea menor o igual al saldo de Alice
    //     while (amount > PaliceBalance && tries < 100) {

    //         vm.startPrank(bob);
    //         olas.transfer(alice, amount);
    //         amountA = (amount - 1);
    //         olas.approve(address(veolas), amountA);
    //         vm.stopPrank();

    //         uint256 SaliceBalance = olas.balanceOf(alice); // Actualizar el saldo de Alice
    //         tries++;
    //     }
    //     uint256 TaliceBalance = olas.balanceOf(alice);


    //     // Verifica que se haya encontrado un 'amount' válido
    //     if (amountA <= TaliceBalance) {
    //         vm.startPrank(alice);
    //         olas.approve(address(veolas), amountA);
            
    //         vm.stopPrank();

    //         vm.startPrank(bob);
    //         vm.expectRevert(); //@audit 
    //         veolas.createLock(amountA, oneWeek); // Crear un bloqueo para Bob
    //         vm.stopPrank();

    //         uint256 supplyBefore = veolas.totalSupply();

    //         // Acción: Alice deposita para Bob
    //         vm.startPrank(alice);
    //         uint256 cant =  olas.balanceOf(alice);
    //         uint256 cantw =  olas.balanceOf(bob);

    //         uint256 updatedLocked = olas.balanceOf(alice);
    //         uint256 updatedLockedy = veolas.balanceOf(alice);
    //         uint256 updatedLockedxx = olas.balanceOf(bob);
    //         uint256 updatedLockedyy = veolas.balanceOf(bob);

    //         veolas.depositFor(bob, amountA );
    //         vm.stopPrank();

    //         // Postcondiciones
    //         uint256 supplyAfter = veolas.totalSupply();
    //         uint256 bal = olas.balanceOf(alice);
    //         uint256 ebal = veolas.balanceOf(alice);

    //         uint256 bw = olas.balanceOf(bob);
    //         uint256 be = veolas.balanceOf(bob);

    //         // Verificar las invariantes
    //         assertEq(supplyAfter, supplyBefore + amountA, "Invariant: Supply consistency");
    //         assertGt(supplyAfter, supplyBefore, "Invariant: Supply increment on deposit");
    //         // assertEq(updatedLocked, bal - amountA , "Invariant: Locked amount consistency");
    //     }
    // }

// =======================================================   

// Copy Hardhat Test
    function test_increaseAmounLock() public {
        vm.startPrank(bob);
        olas.approve(address(veolas), tenOLABalance);

        vm.expectRevert();
        veolas.increaseAmount(oneOLABalance);

        veolas.createLock(oneOLABalance, oneWeek);
        vm.expectRevert();
        veolas.increaseAmount(0);

        uint256 overflowNum96 = 8 * 10**28;

        vm.expectRevert();
        veolas.increaseAmount(overflowNum96);

        veolas.increaseAmount(oneOLABalance);

        // Avanzar el tiempo en una semana
        vm.warp(block.timestamp + oneWeek);
        // Minar un nuevo bloque
        vm.roll(block.number + 1);

        vm.expectRevert();
        veolas.increaseAmount(oneOLABalance); 
    }


    // Bounding function similar to vm.assume but is more efficient regardless of the fuzzying framework
	// This is also a guarante bound of the input unlike vm.assume which can only be used for narrow checks     
	function _between(uint256 random, uint256 low, uint256 high) public pure returns (uint256) {
        require(random != 0);
		return low + random % (high-low);
	} 
       
    bool set;
    function init(uint amount, uint timeSkip) public {
        olas.mint(address(this), amount);
        skip(timeSkip);
        set = true;
    }

}