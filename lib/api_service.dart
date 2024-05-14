import 'dart:convert';

import 'package:departures/stop_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// https://sschueller.github.io/posts/vbz-fahrgastinformation/
class ApiService {
  final String _baseUrl = 'https://api.opentransportdata.swiss';
  static late final String _apiKey;

  static initialize() async {
    await dotenv.load(fileName: ".env");
    _apiKey = dotenv.env['API_KEY']!;
  }

  Future<List<StopEvent>> fetchStopEvents(int stopPointRef) async {
    String xmlData = '''<?xml version="1.0" encoding="UTF-8"?>
<Trias version="1.1"
    xmlns="http://www.vdv.de/trias"
    xmlns:siri="http://www.siri.org.uk/siri"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<ServiceRequest>
<siri:RequestTimestamp>2024-05-13T20:01:06.488Z</siri:RequestTimestamp>
<siri:RequestorRef>API-Explorer</siri:RequestorRef>
<RequestPayload>
<StopEventRequest>
<Location>
<LocationRef>
<StopPointRef>$stopPointRef</StopPointRef>
</LocationRef>
<DepArrTime>${DateTime.now()}</DepArrTime>
</Location>
<Params>
<NumberOfResults>4</NumberOfResults>
<StopEventType>departure</StopEventType>
<IncludePreviousCalls>false</IncludePreviousCalls>
<IncludeOnwardCalls>false</IncludeOnwardCalls>
<IncludeRealtimeData>true</IncludeRealtimeData>
</Params>
</StopEventRequest>
</RequestPayload>
</ServiceRequest>
</Trias>''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/trias2020'),
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'text/XML',
        },
        body: xmlData,
      );

      if (response.statusCode == 200) {
        var decodedBody = utf8.decode(response.bodyBytes);

        final document = xml.XmlDocument.parse(decodedBody);
        return _parseStopEvents(document);
      } else {
        throw Exception('Failed to load data: ${response.reasonPhrase}');
      }
    } catch (error) {
      debugPrint('Error: $error');
    }
    return [];
  }

  List<StopEvent> _parseStopEvents(xml.XmlDocument document) {
    final stopEvents = <StopEvent>[];

    final stopEventResults = document.findAllElements('trias:StopEventResult');

    for (var result in stopEventResults) {
      String findText(xml.XmlElement element, String tagName) {
        return element.findAllElements(tagName).single.findElements('trias:Text').single.innerText;
      }

      // Safely get the first matching element or return null if not found
      String? safeFindText(xml.XmlElement element, String tagName) {
        try {
          return element
              .findAllElements(tagName)
              .single
              .findElements('trias:Text')
              .single
              .innerText;
        } catch (e) {
          return null; // Return null or a default value
        }
      }

      DateTime? safeParseDateTime(String? dateTimeStr) {
        try {
          return dateTimeStr != null ? DateTime.parse(dateTimeStr) : null;
        } catch (e) {
          return null;
        }
      }

      int? safeParseInt(String? intStr) {
        try {
          return intStr != null ? int.parse(intStr) : null;
        } catch (e) {
          return null;
        }
      }

      String? getElementText(String tagName) {
        return result.findAllElements(tagName).map((e) => e.innerText).firstOrNull;
      }

      stopEvents.add(
        StopEvent(
          stopPointRef: getElementText('trias:StopPointRef'),
          stopPointName: safeFindText(result, 'trias:StopPointName'),
          timetabledTime: safeParseDateTime(getElementText('trias:TimetabledTime')),
          stopSeqNumber: safeParseInt(getElementText('trias:StopSeqNumber')),
          lineRef: getElementText('trias:LineRef'),
          directionRef: getElementText('trias:DirectionRef'),
          ptMode: getElementText('trias:PtMode'),
          tramSubmode: getElementText('trias:TramSubmode'),
          publishedLineName: findText(result, 'trias:PublishedLineName'),
          originStopPointRef: getElementText('trias:OriginStopPointRef'),
          originText: safeFindText(result, 'trias:OriginText'),
          destinationStopPointRef: getElementText('trias:DestinationStopPointRef'),
          destinationText: findText(result, 'trias:DestinationText'),
        ),
      );
    }

    return stopEvents;
  }
}
