
class CallInfo {
  // Variables
  final String callID;
  final String userId;
  final String userProfileName;
  final String userProfilePhoto;
  final bool isCaller;
  final String callType;
  final String callTitle;

  CallInfo(
      {required this.callID,
      required this.userId,
      required this.userProfileName,
      required this.userProfilePhoto,
      required this.isCaller,
      required this.callType,
      required this.callTitle});

  factory CallInfo.fromMap(Map<String, dynamic> info) {
    return CallInfo(
        callID: info['call_id'],
        userId: info['user_id'],
        userProfileName: info['user_profile_name'],
        userProfilePhoto: info['user_profile_photo'],
        isCaller: info['is_caller'],
        callType: info['call_type'],
        callTitle: info['call_title']);
  }
}

Map<String, dynamic> callInfoToMap(CallInfo callInfo) {
  return {
    'call_id': callInfo.callID,
    'user_id': callInfo.userId,
    'user_profile_name': callInfo.userProfileName,
    'user_profile_photo': callInfo.userProfilePhoto,
    'is_caller': callInfo.isCaller,
    'call_type': callInfo.callType,
    'call_title': callInfo.callTitle
  };
}
