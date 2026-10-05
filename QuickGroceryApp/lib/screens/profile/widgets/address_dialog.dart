import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models.dart';

/// Modal dialog for adding or editing a saved delivery address.
class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _form = GlobalKey<FormState>();
  final _fields = List.generate(8, (_) => TextEditingController());
  final _pin = TextEditingController();
  LatLng? _mapPin;
  final _labels = const [
    'Label (Home, Work)',
    'Recipient name',
    'Phone number',
    'Flat, building, street',
    'Apartment / area (optional)',
    'Landmark (optional)',
    'City',
    'State',
  ];

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    _pin.dispose();
    super.dispose();
  }

  Future<void> _pickMapPin() async {
    final selected = await showDialog<LatLng>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pin delivery location'),
          content: SizedBox(
            width: 560,
            height: 390,
            child: Column(
              children: [
                const Text(
                  'Pan and zoom to the delivery point, then tap the map.',
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter:
                          _mapPin ?? const LatLng(19.05253, 73.07351),
                      initialZoom: 15,
                      onTap: (_, point) =>
                          setDialogState(() => _mapPin = point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.qwikgrocery.app',
                        maxNativeZoom: 19,
                      ),
                      if (_mapPin != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _mapPin!,
                              width: 44,
                              height: 50,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.emeraldPrimary,
                                size: 42,
                              ),
                            ),
                          ],
                        ),
                      const SimpleAttributionWidget(
                        source: Text('© OpenStreetMap contributors'),
                        alignment: Alignment.bottomRight,
                      ),
                    ],
                  ),
                ),
                if (_mapPin != null)
                  Text(
                    '${_mapPin!.latitude.toStringAsFixed(5)}, ${_mapPin!.longitude.toStringAsFixed(5)}',
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _mapPin == null
                  ? null
                  : () => Navigator.pop(dialogContext, _mapPin),
              child: const Text('Use this pin'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _mapPin = selected);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add delivery address'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _fields[i],
                    keyboardType: i == 2
                        ? TextInputType.phone
                        : TextInputType.text,
                    decoration: InputDecoration(labelText: _labels[i]),
                    validator: (value) => i == 4 || i == 5
                        ? null
                        : (value == null || value.trim().isEmpty
                              ? 'Required'
                              : null),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickMapPin,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    _mapPin == null
                        ? 'Pin on map (optional)'
                        : 'Map pin selected',
                  ),
                ),
              ),
              TextFormField(
                controller: _pin,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'PIN code'),
                validator: (value) => value == null || value.trim().length < 5
                    ? 'Enter a valid PIN code'
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            SavedAddress(
              id: '',
              label: _fields[0].text.trim(),
              recipientName: _fields[1].text.trim(),
              phone: _fields[2].text.trim(),
              line1: _fields[3].text.trim(),
              line2: _fields[4].text.trim(),
              landmark: _fields[5].text.trim(),
              city: _fields[6].text.trim(),
              state: _fields[7].text.trim(),
              postalCode: _pin.text.trim(),
              latitude: _mapPin?.latitude,
              longitude: _mapPin?.longitude,
            ),
          );
        },
        child: const Text('Save address'),
      ),
    ],
  );
}
