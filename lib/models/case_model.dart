class CaseModel {
  String id;
  String title;
  String description;
  String caseType;
  String workflowStatus;
  int votesCount;
  int exceptionVotesCount;

  CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.caseType,
    required this.workflowStatus,
    this.votesCount = 0,
    this.exceptionVotesCount = 0,
  });
}