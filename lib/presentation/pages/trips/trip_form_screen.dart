import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_manager/presentation/l10n/app_localizations.dart';
import 'package:travel_manager/presentation/providers/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager/core/app_constants.dart';

class TripFormScreen extends StatefulWidget {
  final Map<String, dynamic>? tripData;
  
  const TripFormScreen({super.key, this.tripData});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _tripId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.tripData != null) {
      // Editing existing trip
      _nameController.text = widget.tripData![AppConstants.tripName] ?? '';
      _destinationController.text = widget.tripData![AppConstants.tripDestination] ?? '';
      _budgetController.text = widget.tripData![AppConstants.tripBudget]?.toString() ?? '';
      _notesController.text = widget.tripData![AppConstants.tripNotes] ?? '';
      
      if (widget.tripData![AppConstants.tripStartDate] != null) {
        _startDate = DateTime.parse(widget.tripData![AppConstants.tripStartDate]);
      }
      
      if (widget.tripData![AppConstants.tripEndDate] != null) {
        _endDate = DateTime.parse(widget.tripData![AppConstants.tripEndDate]);
      }
      
      _tripId = widget.tripData![AppConstants.tripId];
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate?.add(const Duration(days: 1)) ?? DateTime.now())),
      firstDate: isStartDate 
        ? DateTime(2020)
        : (_startDate ?? DateTime(2020)),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, update it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate dates
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).startDateRequired)),
      );
      return;
    }
    
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).endDateRequired)),
      );
      return;
    }
    
    // Create trip data using AppConstants
    final tripData = {
      AppConstants.tripName: _nameController.text,
      AppConstants.tripDestination: _destinationController.text,
      AppConstants.tripStartDate: _startDate!.toIso8601String(),
      AppConstants.tripEndDate: _endDate!.toIso8601String(),
      AppConstants.tripNotes: _notesController.text,
    };
    
    // Parse budget if provided
    if (_budgetController.text.isNotEmpty) {
      try {
        tripData[AppConstants.tripBudget] = _budgetController.text;
      } catch (e) {
        tripData[AppConstants.tripBudget] = '0.0';
      }
    }
    
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    bool success;
    
    if (_isEditing && _tripId != null) {
      // Update existing trip
      success = await tripProvider.updateTrip(_tripId!, tripData);
    } else {
      // Add new trip
      success = await tripProvider.addTrip(tripData);
    }
    
    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tripProvider.errorMessage ?? AppLocalizations.of(context).errorOccurred)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTrip : l10n.addTrip),
      ),
      body: tripProvider.isLoading
      ? const Center(child: CircularProgressIndicator())
      : Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trip name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.tripName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.tripName + ' ' + l10n.required;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Destination field
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: l10n.destination,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.destination + ' ' + l10n.required;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Start date field
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: l10n.startDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _startDate != null
                          ? DateFormat('dd.MM.yyyy').format(_startDate!)
                          : '',
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // End date field
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: l10n.endDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _endDate != null
                          ? DateFormat('dd.MM.yyyy').format(_endDate!)
                          : '',
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Budget field
                TextFormField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: l10n.budget,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monetization_on),
                  ),
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                // Notes field
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notes,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                
                const SizedBox(height: 24),
                
                // Save button
                ElevatedButton.icon(
                  onPressed: _saveTrip,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.save),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  
                  // Delete button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.deleteTrip),
                          content: Text(l10n.deleteConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.delete),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ) ?? false;
                      
                      if (confirmed && mounted && _tripId != null) {
                        final success = await tripProvider.deleteTrip(_tripId!);
                        
                        if (mounted) {
                          if (success) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tripProvider.errorMessage ?? l10n.errorOccurred)),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(l10n.delete),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
} 