# GERC
GERC即GameEnternalRoleChain，基于以太坊合约实现的支持二级分销的ERC20 Token

# 目标
1. 实现ERC20标准api。
2. GERC有总量限制，暂定20亿。
3. 实现注册、二级分销功能，即用户注册后才能使用交易功能，注册时需要填写上线钱包地址，上线及上上线将获取奖励。
4. 注册时上线奖励根据GERC剩余数量动态变化。
5. 注册需先在中心服务器对用户身份进行确认，合约中仅有ceo具有调用注册接口的权限。以防止用户刷大量钱包注册获取奖励。