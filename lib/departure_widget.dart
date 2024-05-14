import 'dart:async';
import 'package:departures/api_service.dart';
import 'package:departures/stop_event.dart';
import 'package:flutter/material.dart';

class DepartureWidget extends StatefulWidget {
  DepartureWidget({required this.stopPointRef}) : super(key: ValueKey(stopPointRef));

  final int stopPointRef;

  @override
  State<DepartureWidget> createState() => _DepartureWidgetState();
}

class _DepartureWidgetState extends State<DepartureWidget> {
  late Timer _timer;
  static const Duration _timerDuration = Duration(seconds: 30);
  List<StopEvent> _stopEvents = [];

  @override
  void didUpdateWidget(covariant DepartureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // restart timer
    _timer.cancel();
    _timer = Timer.periodic(_timerDuration, (Timer t) => _fetchData());

    if (oldWidget.stopPointRef != widget.stopPointRef) {
      _fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_timerDuration, (Timer t) => _fetchData());
    _fetchData();
  }

  void _fetchData() async {
    final apiService = ApiService();
    final stopEvents = await apiService.fetchStopEvents(widget.stopPointRef);
    if (mounted) {
      setState(() {
        _stopEvents = stopEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _stopEvents.length,
      itemBuilder: (context, index) {
        final stopEvent = _stopEvents[index];
        String departureTime = '?';
        if (stopEvent.timetabledTime != null) {
          final Duration departureDuration = stopEvent.timetabledTime!.difference(DateTime.now());
          departureTime = departureDuration.inMinutes.toString();
        }
        const textStyle = TextStyle(color: Colors.orange, fontSize: 18);
        return ListTile(
          leading: Text(
            stopEvent.publishedLineName,
            style: textStyle,
          ),
          title: Text(
            stopEvent.destinationText,
            style: textStyle,
          ),
          trailing: Text(
            departureTime,
            style: textStyle,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}
