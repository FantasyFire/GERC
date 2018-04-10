pragma solidity ^0.4.18;


import "./GERCAccessControl.sol";
import "./ERC20.sol";


/**
 * @title GERC token
 *
 * @dev Implementation of the level-2 distribution.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract GERC is ERC20, GERCAccessControl {

    // events
    // emit when someone register successfully
    event Register(
        address _new, uint256 _newBalance,
        address _referee, uint256 _refereeBalance,
        address _grandReferee, uint256 _grandRefereeBalance
    );

    mapping (address => mapping (address => uint256)) internal allowed;

    // todo: rename this variable
    uint256 MAX_COUNT = 2000000000;

    // @dev store the referee relationship
    mapping (address => address) referees;

    /// @notice Creates the main CryptoCards smart contract instance.   
    function GERC() public {
        // Starts paused.
        paused = true;
        
        // the creator of the contract is also the initial CEO
        ceoAddress = msg.sender;

        // todo: 怎么帮CEO注册？
    }

    /**
    * @dev Register an address with a referee, only CEO has the privilege to invoke
    * @param _new the new address which need to be registered
    * @param _referee _new's referee
    */
    function register(address _new, address _referee) public onlyCEO {
        // the _new must hasn't been registered
        require(referees[_new] == address(0));
        // todo: 是否一定需要有推荐人才能注册？
        // the _referee must has been registered
        require(referees[_referee] != address(0));
        // set _referee as _new's referee
        referees[_new] = _referee;
        // todo: 注册是否赠送GERC？
        // distributeGERC(_new, 500);
        // rebate bonus
        // level 1
        distributeGERC(_referee, _calculateRebateGERC(1));
        // level 2
        address grandReferee = referees[_referee];
        if (grandReferee != address(0)) {
            distributeGERC(grandReferee, _calculateRebateGERC(2));
        }
    }

    /**
    * @dev calculate the bonus for _level depth of distribution
    * @param _level the depth of distribution
    */
    function _calculateRebateGERC(uint16 _level) private view returns (uint256) {
        // todo: 应根据GERC剩余量及分销级数计算返利，剩余量越少返利越少，应使用什么数学模型？
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}
