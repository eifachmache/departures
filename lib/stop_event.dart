class StopEvent {
  final String? stopPointRef;
  final String? stopPointName;
  final DateTime? timetabledTime;
  final int? stopSeqNumber;
  final String? lineRef;
  final String? directionRef;
  final String? ptMode;
  final String? tramSubmode;
  final String publishedLineName;
  final String? originStopPointRef;
  final String? originText;
  final String? destinationStopPointRef;
  final String destinationText;

  StopEvent({
    required this.stopPointRef,
    required this.stopPointName,
    required this.timetabledTime,
    required this.stopSeqNumber,
    required this.lineRef,
    required this.directionRef,
    required this.ptMode,
    required this.tramSubmode,
    required this.publishedLineName,
    required this.originStopPointRef,
    required this.originText,
    required this.destinationStopPointRef,
    required this.destinationText,
  });
}
