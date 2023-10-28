class StakeInfo {
  StakeInfo({
    required this.biddingBalance,
    required this.biddingStakers,
    required this.balance,
    required this.currentStake,
    required this.totalStaked,
    required this.totalUnstaked,
    required this.totalEarned,
    required this.totalClaimed,
  });

  double biddingBalance;
  String biddingStakers;
  double balance;
  int currentStake;
  int totalStaked;
  int totalUnstaked;
  double totalEarned;
  double totalClaimed;

  factory StakeInfo.fromJson(Map<String, dynamic> json) => StakeInfo(
    biddingBalance: json["biddingBalance"].toDouble(),
    biddingStakers: json["biddingStakers"],
    balance: json["balance"].toDouble(),
    currentStake: json["currentStake"],
    totalStaked: json["totalStaked"],
    totalUnstaked: json["totalUnstaked"],
    totalEarned: json["totalEarned"].toDouble(),
    totalClaimed: json["totalClaimed"].toDouble(),
  );

}

class StakeList {
  StakeList({
    required this.indexId,
    required this.unstaketime,
    required this.staketime,
    required this.amount,
    required this.reward,
    required this.realtimeRewardPerBlock,
    required this.harvestreward,
    required this.persecondreward,
    required this.withdrawan,
    required this.unstaked,
  });

  int indexId;
  String unstaketime;
  String staketime;
  int amount;
  double reward;
  double realtimeRewardPerBlock;
  double harvestreward;
  double persecondreward;
  int withdrawan;
  int unstaked;


  factory StakeList.fromJson(Map<String, dynamic> json) => StakeList(
    indexId: json["id"],
    unstaketime: json["unstaketime"],
    staketime: json["staketime"],
    amount: json["amount"],
    reward: json["reward"].toDouble(),
    realtimeRewardPerBlock: json["realtimeRewardPerBlock"].toDouble(),
    harvestreward: json["harvestreward"].toDouble(),
    persecondreward: json["persecondreward"].toDouble(),
    withdrawan: json["withdrawan"] == true ? 1 : 0,
    unstaked: json["unstaked"] == true ? 1 : 0,
  );

  Map<String, dynamic> toJson() => {
    "id": indexId,
    "unstaketime": unstaketime,
    "staketime": staketime,
    "amount": amount,
    "reward": reward,
    "realtimeRewardPerBlock": realtimeRewardPerBlock,
    "harvestreward": harvestreward,
    "persecondreward": persecondreward,
    "withdrawan": withdrawan,
    "unstaked": unstaked,
  };
}

