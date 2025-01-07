import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class AddEventScreen extends StatefulWidget {
  final EventService eventService;
  final Function onEventAdded;

  const AddEventScreen(
      {super.key, required this.eventService, required this.onEventAdded});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _latitude;
  double? _longitude;
  String? _location;

  final MapController _mapController = MapController(
      initMapWithUserPosition:
          const UserTrackingOption(enableTracking: true, unFollowUser: false));

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _addEvent() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _latitude != null &&
        _longitude != null &&
        _location != null) {
      final String formattedTime = _selectedTime!.format(context);
      final newEvent = Event(
        title: _titleController.text,
        date: _selectedDate!,
        time: formattedTime,
        location: _location!,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      widget.eventService.addEvent(newEvent);
      widget.onEventAdded();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete all fields and select a location!')));
    }
  }

  void _onMapTap(GeoPoint point) {
    setState(() {
      _latitude = point.latitude;
      _longitude = point.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : 'Date: ${_selectedDate!.toLocal().toIso8601String().split('T').first}',
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _selectDate, child: const Text('Select Date')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No time selected'
                          : 'Time: ${_selectedTime!.format(context)}',
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _selectTime, child: const Text('Select Time')),
                ],
              ),
              const SizedBox(height: 16),
              // Location Text Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                _latitude == null || _longitude == null
                    ? 'No location selected'
                    : 'Selected Location: Lat: $_latitude, Lon: $_longitude',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: OSMFlutter(
                  controller: _mapController,
                  onMapIsReady: (isReady) {
                    if (isReady) {
                      _mapController.listenerMapSingleTapping.addListener(() {
                        GeoPoint? point =
                            _mapController.listenerMapSingleTapping.value;
                        if (point != null) {
                          _onMapTap(point);
                        }
                      });
                    }
                  },
                  osmOption: OSMOption(
                    enableRotationByGesture: true,
                    zoomOption: const ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.double_arrow,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  mapIsLoading:
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                    onPressed: _addEvent, child: const Text('Add Exam')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
